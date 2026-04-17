import { AVCodecType, AVRenderType } from '@ohpg/player'
import { ProxyPlayer } from 'entry/ProxyPlayer'
import { Repository } from '../data/Repository'
import { FinItemSource } from '../entity/FinItemSource'

export class AppPlayer extends ProxyPlayer {

  private readonly repository: Repository

  private appSource?: FinItemSource

  constructor(context: Context, type: AVRenderType, codecPrefer?: AVCodecType) {
    super(context, type, codecPrefer)
    this.repository = AppStorage.get(Repository.REPOSITORY)!
  }

  public async setData(url: string, header?: Record<string, string> | undefined): Promise<void> {
    this.appSource = await this.repository.getMediaSource(url)
    return super.setData(this.appSource.url, header)
  }

  public getAppSource(): FinItemSource | undefined {
    return this.appSource
  }

  async reset(): Promise<void> {
    this.appSource = undefined
    await super.reset()
  }

  async release(): Promise<void> {
    this.appSource = undefined
    await super.release()
  }

}
