import { MpvPlayer } from "@ohpg/mpv";
import { Repository } from "../data/Repository";

export class AppPlayer extends MpvPlayer {

  private readonly repository: Repository

  constructor(context: Context) {
    super(context)
    this.repository = AppStorage.get(Repository.REPOSITORY)!
  }

  public async setData(url: string, header?: Record<string, string> | undefined): Promise<void> {
    let source = await this.repository.getMediaSource(url)
    return super.setData(source.url, header)
  }

}