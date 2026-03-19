import { MpvPlayer } from "@ohpg/mpv";
import { Repository } from "../data/Repository";
import { FinItemSource } from "../entity/FinItemSource";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2026/3/19 21:36
 * @Version V1.0
 * @Description 应用自定义播放器
 */
export class AppPlayer extends MpvPlayer {

  private readonly repository: Repository

  private appSource?: FinItemSource

  constructor(context: Context) {
    super(context)
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