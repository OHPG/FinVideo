import { AVWidgetPlaybackManager } from '@ohpg/widget'
import { FinItem } from '@ohpg/fin-core'

/**
 * FinVideo 播放器管理器。
 * 继承 AVWidgetPlaybackManager，路由和播放调度由基类处理。
 * 播放上下文通过 AVPlayerKit.setContextFactory() 注册的工厂创建。
 */
export class AppPlayerManager extends AVWidgetPlaybackManager {

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
