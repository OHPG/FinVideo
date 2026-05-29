import {
  AVPlayerContext,
  PlayData,
  AVPlayerKit,
  PlaybackState,
  PlaybackParams,
  PlaybackParamsTool
} from '@ohpg/player'
import { avSession } from '@kit.AVSessionKit'
import { FinItem, FinItemType } from '@ohpg/fin-core'
import { Repository } from '../data/Repository'

interface PlayAllArgs {
  items: Array<FinItem>
  index: number
}

/**
 * FinVideo 的播放上下文实现。
 * 继承 AVPlayerContext 基类，实现：
 * - 服务端播放进度上报（start/progress/stop）
 */
export class AppPlayerContext extends AVPlayerContext {

  private readonly repository: Repository

  /** 上报状态 */
  private reportingPlayback = false

  private reportPosition?: number = undefined

  constructor(uiContext: UIContext, repository: Repository) {
    let playerPrefer = AVPlayerKit.getPrefer()
    let config = playerPrefer.toPlayerConfig()
    super(uiContext, config)
    this.control.setCastEnabled(true)
    this.repository = repository
  }

  // ─── 抽象方法实现 ──────────────────────────────────────────────────────────

  protected buildPlayData(args: Object): PlayData {
    let playArgs = args as PlayAllArgs
    let items = this.buildQueue(playArgs.items)
    let startId = playArgs.items[playArgs.index].id
    return { items: items, startId: startId }
  }

  protected async onHistorySave(assetId: string, state: PlaybackState, _notify: boolean): Promise<void> {
    this.reportPlaybackUpdate(assetId, state.position, false)
  }

  // ─── 覆写方法 ──────────────────────────────────────────────────────────────

  protected onAssetChanged(assetId: string, _description: avSession.AVMediaDescription): void {
    this.reportPlaybackStop()
    this.reportPosition = undefined
    this.reportPlaybackStart(assetId)
  }

  resetItemState(): void {
    this.reportPlaybackStop()
  }

  // ─── 内部方法 ──────────────────────────────────────────────────────────────

  /**
   * 构建播放队列
   */
  private buildQueue(items: Array<FinItem>): Array<avSession.AVQueueItem> {
    let queueItems = new Array<avSession.AVQueueItem>()

    items.forEach((item: FinItem, i: number) => {
      let extra: Record<string, Object> = {}

      // 构建 PlaybackParams
      let params: PlaybackParams = {}
      if (item.data?.playedPositionTicks && item.runtimeTicks
        && item.runtimeTicks - item.data.playedPositionTicks > 5000) {
        params.startPosition = item.data.playedPositionTicks
      }
      extra[PlaybackParamsTool.KEY] = params

      queueItems.push({
        itemId: i,
        description: {
          assetId: item.id,
          title: item.name,
          mediaUri: item.id,
          mediaImage: item.type === FinItemType.Episode
            ? item.image?.primary : item.image?.backdrop,
          mediaType: 'video',
          duration: item.runtimeTicks,
          startPosition: item.data?.playedPositionTicks,
          extras: extra
        }
      })
    })

    return queueItems
  }

  // ─── 服务端上报 ────────────────────────────────────────────────────────────

  private reportPlaybackStart(assetId: string) {
    if (this.reportingPlayback) return
    this.reportingPlayback = true
    this.repository.onPlaybackStart(assetId)
      .then(() => { this.reportingPlayback = false })
      .catch((_e: Error) => { this.reportingPlayback = false })
  }

  private reportPlaybackUpdate(assetId: string, position: number, force: boolean) {
    if (!force && Math.abs(position - (this.reportPosition || 0)) < 5000) return
    this.reportingPlayback = true
    this.reportPosition = position
    this.repository.onPlaybackProgress(assetId, position, this.control.isPlaying())
      .then(() => { this.reportingPlayback = false })
      .catch((_e: Error) => { this.reportingPlayback = false })
  }

  private reportPlaybackStop() {
    if (!this.currentAssetId) return
    this.reportingPlayback = true
    this.repository.onPlaybackStopped(this.currentAssetId, this.reportPosition || 0)
      .then(() => { this.reportingPlayback = false })
      .catch((_e: Error) => { this.reportingPlayback = false })
  }

  // ─── 销毁 ──────────────────────────────────────────────────────────────────

  async destroy(): Promise<void> {
    this.reportPlaybackStop()
    await super.destroy()
  }
}
