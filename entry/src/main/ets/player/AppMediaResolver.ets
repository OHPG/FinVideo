import { MediaResolver, MediaResolveResult, PlaybackParamsTool, PlaybackParams } from '@ohpg/player'
import { avSession } from '@kit.AVSessionKit'
import { Repository } from '../data/Repository'

/**
 * FinVideo 媒体解析器。
 * 通过 AVPlayerKit.setMediaResolver() 全局注册，
 * 负责将队列项中的 assetId 解析为真实播放 URL，并注入外挂字幕。
 */
export class AppMediaResolver implements MediaResolver {

  private readonly repository: Repository

  constructor(repository: Repository) {
    this.repository = repository
  }

  async resolve(item: avSession.AVQueueItem): Promise<MediaResolveResult> {
    let assetId = item.description?.assetId ?? ''
    let source = await this.repository.getMediaSource(assetId)

    // 将外挂字幕写入 PlaybackParams（prepared 后由基类自动加载）
    if (source.sub && source.sub.length > 0) {
      let params: PlaybackParams = PlaybackParamsTool.fromExtras(item) ?? {}
      params.subtitles = source.sub.map((sub) => sub.url)
      PlaybackParamsTool.toExtras(item, params)
    }

    let result: MediaResolveResult = {
      url: source.url
    }
    return result
  }
}
