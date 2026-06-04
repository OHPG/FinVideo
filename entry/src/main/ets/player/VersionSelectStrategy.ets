import { deviceInfo } from '@kit.BasicServicesKit'
import { connection } from '@kit.NetworkKit'
import { display } from '@kit.ArkUI'
import { FinItemSource } from '../entity/FinItemSource'
import { VersionSelectMode, versionSelectModeName } from './VersionSelectMode'
import BuildProfile from 'entry/BuildProfile';

/**
 * 多版本自动选择策略
 *
 * 设计目标：无平台依赖，可直接复制到其他项目使用。
 * 唯一依赖：
 *   - FinItemSource（需携带 width / height / bitrate / videoCodec 字段）
 *   - HarmonyOS SDK：@kit.BasicServicesKit、@kit.NetworkKit、@kit.ArkUI
 */
export class VersionSelectStrategy {

  private static readonly TAG = 'VersionSelectStrategy'

  // ─── 码率阈值（移动数据下） ──────────────────────────────────────────────────
  /** 移动数据下大屏设备码率上限 bps，超出则降档 */
  private static readonly CELLULAR_LARGE_SCREEN_BITRATE_LIMIT = 12_000_000
  /** 移动数据下小屏设备码率上限 bps */
  private static readonly CELLULAR_MOBILE_BITRATE_LIMIT = 8_000_000

  // ─── 编码打分 ────────────────────────────────────────────────────────────────
  /**
   * 编码加分
   * h264/avc、h265/hevc 均支持硬解，命中即加分；av1/vp9 软解降权。
   */
  private static readonly CODEC_BONUS: Record<string, number> = {
    'hevc': 10,
    'h265': 10,
    'h264': 10,
    'avc':  10,
    'av1':  -20,
    'vp9':  -20,
  }

  /**
   * 根据 mode 从 sources 中选出最合适的版本。
   *
   * @param sources  版本列表（至少1条）
   * @param mode     选择模式
   * @returns        选中的版本，保证非空
   */
  public static select(sources: FinItemSource[], mode: VersionSelectMode): FinItemSource {
    if (sources.length === 1) {
      return sources[0]
    }
    let selected: FinItemSource
    switch (mode) {
      case VersionSelectMode.Highest:
        selected = VersionSelectStrategy.selectByScore(sources, false)
        break
      case VersionSelectMode.Lowest:
        selected = VersionSelectStrategy.selectByScore(sources, true)
        break
      case VersionSelectMode.Auto:
        selected = VersionSelectStrategy.selectAuto(sources)
        break
      default:
        selected = sources[0]
        break
    }
    if (BuildProfile.DEBUG) {
      console.info(
        `[${VersionSelectStrategy.TAG}] select mode=${versionSelectModeName(mode)} result="${selected.name}" `
        + `[${selected.width ?? '?'}x${selected.height ?? '?'} `
        + `${selected.videoCodec ?? '?'} `
        + `${selected.bitrate != undefined ? Math.round(selected.bitrate / 1000) + 'kbps' : '?'}]`
      )
    }
    return selected
  }

  // ─── Auto 策略 ──────────────────────────────────────────────────────────────

  private static selectAuto(sources: FinItemSource[]): FinItemSource {
    const deviceType = deviceInfo.deviceType
    const isCellular = VersionSelectStrategy.isCellular()
    const screenLongEdge = VersionSelectStrategy.getScreenLongEdge()

    if (BuildProfile.DEBUG) {
      console.info(`[${VersionSelectStrategy.TAG}] auto params: deviceType=${deviceType} cellular=${isCellular} screenLongEdge=${screenLongEdge}px`)
    }

    let best = sources[0]
    let bestScore = Number.MIN_SAFE_INTEGER

    for (const source of sources) {
      const score = VersionSelectStrategy.calcAutoScore(source, deviceType, isCellular, screenLongEdge)
      if (BuildProfile.DEBUG) {
        console.info(
          `[${VersionSelectStrategy.TAG}]   candidate "${source.name}" `
          + `[${source.width ?? '?'}x${source.height ?? '?'} `
          + `${source.videoCodec ?? '?'} `
          + `${source.bitrate != undefined ? Math.round(source.bitrate / 1000) + 'kbps' : '?'}] `
          + `score=${score}`)
      }
      if (score > bestScore) {
        bestScore = score
        best = source
      }
    }
    return best
  }

  /**
   * Auto 模式打分：分辨率匹配（主权重）+ 编码加分（次权重）+ 码率（辅助权重）
   *
   * 分辨率分档：2160p(4K)=4  1080p=3  720p=2  480p=1  其他=0
   *
   * deviceType 目标档位：
   *   tv / car          → 4K(4)，固定大屏优先最高质量
   *   2in1              → 跟随屏幕分辨率
   *   tablet（横屏）    → 跟随屏幕分辨率
   *   其他              → 1080p(3)
   *
   * 命中目标档：+100；每低一档：-40；每高一档：-20（浪费带宽无收益）
   * 移动数据超码率上限：-200（强降权）
   */
  private static calcAutoScore(
    source: FinItemSource,
    deviceType: string,
    isCellular: boolean,
    screenLongEdge: number,
  ): number {
    const resolutionTier = VersionSelectStrategy.resolutionTier(source.width, source.height)
    const targetTier = VersionSelectStrategy.targetTier(deviceType, screenLongEdge)

    // 分辨率匹配分
    const diff = resolutionTier - targetTier
    let score = diff === 0 ? 100 : diff < 0 ? 100 + diff * 40 : 100 - diff * 20

    // 编码加分
    const codec = (source.videoCodec ?? '').toLowerCase()
    score += VersionSelectStrategy.CODEC_BONUS[codec] ?? 0

    // 移动数据码率惩罚
    if (isCellular && source.bitrate) {
      const isLargeScreen = deviceType === 'tv' || deviceType === 'car' || deviceType === '2in1'
      const limit = isLargeScreen
        ? VersionSelectStrategy.CELLULAR_LARGE_SCREEN_BITRATE_LIMIT
        : VersionSelectStrategy.CELLULAR_MOBILE_BITRATE_LIMIT
      if (source.bitrate > limit) {
        score -= 200
      }
    }

    // 码率辅助加分（同档位时优先高码率，最多 +10）
    if (source.bitrate) {
      score += Math.min(source.bitrate / 1_000_000, 10)
    }

    return score
  }

  // ─── Highest / Lowest 策略 ──────────────────────────────────────────────────

  private static selectByScore(sources: FinItemSource[], lowest: boolean): FinItemSource {
    const sorted = [...sources].sort((a, b) => {
      const heightDiff = (b.height ?? 0) - (a.height ?? 0)
      if (heightDiff !== 0) return heightDiff
      return (b.bitrate ?? 0) - (a.bitrate ?? 0)
    })
    return lowest ? sorted[sorted.length - 1] : sorted[0]
  }

  // ─── 设备 & 网络辅助方法 ─────────────────────────────────────────────────────

  private static isCellular(): boolean {
    try {
      const handle = connection.getDefaultNetSync()
      if (!handle) {
        return false
      }
      const caps = connection.getNetCapabilitiesSync(handle)
      const bearerTypes = caps?.bearerTypes
      if (bearerTypes) {
        return bearerTypes.indexOf(connection.NetBearType.BEARER_CELLULAR) >= 0
      }
    } catch (_e) {
      // 获取失败时保守处理，不限制
    }
    return false
  }

  /** 返回屏幕长边像素，用于分辨率档位判断（横竖屏均取最大边，反映实际播放上限） */
  private static getScreenLongEdge(): number {
    try {
      const d = display.getDefaultDisplaySync()
      return Math.max(d.width, d.height)
    } catch (_e) {
      return 1920
    }
  }

  // ─── 分辨率档位 ──────────────────────────────────────────────────────────────

  /** 将视频分辨率映射到档位：4K=4  1080p=3  720p=2  480p=1  其他=0，取宽高较大值判断 */
  private static resolutionTier(width?: number, height?: number): number {
    const size = Math.max(width ?? 0, height ?? 0)
    if (size >= 3840) return 4
    if (size >= 1920) return 3
    if (size >= 1280) return 2
    if (size >= 854)  return 1
    return 0
  }

  /**
   * 根据 deviceType 和屏幕短边得出目标档位
   *
   * deviceType 官方值：phone / default / wearable / liteWearable /
   *                    tablet / tv / car / smartVision / 2in1
   */
  private static targetTier(deviceType: string, screenLongEdge: number): number {
    if (deviceType === 'tv' || deviceType === 'car') {
      return 4
    }
    if (deviceType === '2in1') {
      return VersionSelectStrategy.screenTier(screenLongEdge)
    }
    if (deviceType === 'tablet') {
      try {
        const d = display.getDefaultDisplaySync()
        if (d.width >= d.height) {
          return VersionSelectStrategy.screenTier(screenLongEdge)
        }
      } catch (_e) {
        // ignore
      }
    }
    // phone / default / wearable / liteWearable / smartVision / tablet竖屏 及其他
    return 3
  }

  /** 将屏幕长边像素映射到目标档位 */
  private static screenTier(screenLongEdge: number): number {
    if (screenLongEdge >= 3840) return 4
    if (screenLongEdge >= 1920) return 3
    return 2
  }
}
