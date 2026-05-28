import { AVPlayerContext, AVPlaybackManager } from '@ohpg/player'
import { FinItem } from '@ohpg/fin-core'
import { Repository } from '../data/Repository'
import { AppPlayerContext } from './AppPlayerContext'
import { PlayerRouter } from '@ohpg/widget'
import BuildProfile from 'BuildProfile'

/**
 * FinVideo 播放器管理器。
 * 继承 AVPlaybackManager，实现播放器页面生命周期和播放会话管理。
 */
export class AppPlayerManager extends AVPlaybackManager {

  private readonly repository: Repository

  constructor(context: UIContext) {
    super(context)
    this.repository = AppStorage.get(Repository.REPOSITORY)!
  }

  // ─── 抽象方法实现 ──────────────────────────────────────────────────────────

  protected createPlayerContext(): AVPlayerContext {
    return new AppPlayerContext(this.context, this.repository)
  }

  protected onPipEnter(): void {
    PlayerRouter.push(this.context)
  }

  protected onRequestExit(): void {
    PlayerRouter.back(this.context)
  }

  protected onPlayerDestroyed(): void {
  }

  protected doStartPlay(args: Object): void {
    let ctx = this.playerContext as AppPlayerContext | undefined
    if (!ctx) return
    let playArgs = args as PlayAllArgs
    ctx.play(playArgs.items, playArgs.index).catch((e: Error) => {
      if (BuildProfile.DEBUG) {
        console.error('PlayerManager startPlay ' + JSON.stringify(e))
      }
    })
  }

  protected doReplaceAndPlay(args: Object): void {
    let ctx = this.playerContext as AppPlayerContext | undefined
    if (!ctx) return
    let playArgs = args as PlayAllArgs
    ctx.replaceAndPlay(playArgs.items, playArgs.index).catch((e: Error) => {
      if (BuildProfile.DEBUG) {
        console.error('PlayerManager replaceAndPlay ' + JSON.stringify(e))
      }
    })
  }

  // ─── 业务方法 ──────────────────────────────────────────────────────────────

  /**
   * 播放列表
   * @param items 播放列表
   * @param index 起始索引
   * @returns true=可以跳转播放页，false=当前繁忙
   */
  public playAll(items: Array<FinItem>, index: number = 0): boolean {
    let args: PlayAllArgs = { items: items, index: index }
    return this.dispatchPlay(args)
  }
}

interface PlayAllArgs {
  items: Array<FinItem>
  index: number
}
