import { AVMediaResolver, AVMediaResolveResult, PlaybackParams } from '@ohpg/player'
import { avSession } from '@kit.AVSessionKit'
import { Repository } from '../data/Repository'
import { AppPrefer } from '../prefer/AppPrefer'
import { FinItemSource } from '../entity/FinItemSource'
import { FinSubSource } from '../entity/FinSubSource'
import { VersionPickerSheet } from '../sheet/VersionPickerSheet'
import { VersionSelectMode } from './VersionSelectMode'
import { VersionSelectStrategy } from './VersionSelectStrategy'

/**
 * FinVideo 媒体解析器。
 * 通过 AVPlayerKit.setMediaResolver() 全局注册，
 * 职责：
 * 1. 获取版本列表（getMediaSource 返回数组）
 * 2. 多版本时弹框让用户选择
 * 3. 断点续播位置填充：从服务端 getItemData 获取进度
 *
 * 时序保证：onPlaybackStart 在 onPrepared 钩子中上报（resolve 完成后），
 * 不会与 getItemData 产生竞争导致服务端进度被清零。
 */
export class AppMediaResolver implements AVMediaResolver {

  private readonly repository: Repository

  private readonly appPrefer: AppPrefer

  private readonly uiContext: UIContext

  constructor(uiContext: UIContext, repository: Repository, appPrefer: AppPrefer) {
    this.uiContext = uiContext
    this.repository = repository
    this.appPrefer = appPrefer
  }

  async resolve(item: avSession.AVQueueItem): Promise<AVMediaResolveResult> {
    const assetId = item.description?.assetId ?? ''

    // 播放历史查询与版本列表请求并行，互不依赖
    const historyPromise = this.appPrefer.enableHistory()
      ? this.repository.getItemData(assetId).catch(() => undefined)
      : Promise.resolve(undefined)

    // ─── 1. 获取版本列表 ──────────────────────────────────────────────────────
    const sources = await this.repository.getMediaSource(assetId)

    // ─── 2. 版本选择 ──────────────────────────────────────────────────────────
    let selected: FinItemSource
    if (sources.length === 1) {
      selected = sources[0]
    } else {
      const preferredId = item.description?.extras?.['preferredSourceId'] as string | undefined
      if (preferredId) {
        selected = sources.find((s: FinItemSource): boolean => s.id === preferredId) ?? sources[0]
      } else {
        const mode = this.appPrefer.getVersionSelectMode()
        if (mode === VersionSelectMode.Ask) {
          selected = await this.pickVersion(sources)
        } else {
          selected = VersionSelectStrategy.select(sources, mode)
        }
      }
    }

    // ─── 3. 构建 PlaybackParams ───────────────────────────────────────────────
    let params: PlaybackParams = {}

    // 外挂字幕
    if (selected.sub && selected.sub.length > 0) {
      params.subtitles = selected.sub.map((sub: FinSubSource) => sub.url)
    }

    // 断点续播位置
    const itemData = await historyPromise
    if (itemData?.playedPositionTicks && itemData.playedPositionTicks > 0) {
      params.startPosition = itemData.playedPositionTicks
    }

    return { url: selected.url, params: params }
  }

  // ─── 版本选择 ──────────────────────────────────────────────────────────────

  private async pickVersion(sources: FinItemSource[]): Promise<FinItemSource> {
    return new Promise<FinItemSource>((resolve) => {
      try {
        const names = sources.map((s: FinItemSource): string => s.name ?? s.id ?? s.url)
        const sheet = new VersionPickerSheet(
          this.uiContext,
          names,
          (index: number) => { resolve(sources[index] ?? sources[0]) },
          () => { resolve(sources[0]) },
        )
        sheet.show()
      } catch (_e) {
        resolve(sources[0])
      }
    })
  }
}
