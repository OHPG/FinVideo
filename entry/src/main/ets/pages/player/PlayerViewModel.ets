import { FinItem, FinItemType } from "@ohpg/fin-core";
import { AppViewModel } from "../common/AppViewModel";
import { PlayerArgs } from "./PlayerArgs";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/20 22:01
 * @Version V1.0
 * @Description
 */
export class PlayerViewModel extends AppViewModel {

  private readonly args: PlayerArgs

  /**
   * 目标媒体
   */
  itemDto?: FinItem

  /**
   * 媒体列表，剧集才有
   */
  itemDtoArray?: Array<FinItem>

  constructor(context: Context, args: PlayerArgs) {
    super(context)
    this.args = args
  }

  async loadData(): Promise<FinItem> {
    if (this.itemDto) {
      return this.itemDto
    }
    if (this.args.type === FinItemType.Movie) {
      this.itemDto = await this.repository.getMovie(this.args.id)

    } else if (this.args.type === FinItemType.Episode) {
      this.itemDto = await this.repository.getEpisode(this.args.id)
      this.itemDtoArray = await this.repository.getEpisodes(this.itemDto.seasonId!, this.itemDto.seasonId!)
    } else {
      throw new Error("Unsupported type " + this.args.type)
    }
    return this.itemDto!
  }

}