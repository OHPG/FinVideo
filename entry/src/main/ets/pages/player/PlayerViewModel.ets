import { BaseItemDto, BaseItemKind } from "@ohpg/jellyfin";
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
  itemDto?: BaseItemDto

  /**
   * 媒体列表，剧集才有
   */
  itemDtoArray?: Array<BaseItemDto>

  constructor(context: Context, args: PlayerArgs) {
    super(context)
    this.args = args
  }

  async loadData(): Promise<BaseItemDto> {
    if (this.itemDto) {
      return this.itemDto
    }
    if (this.args.type === BaseItemKind.Movie) {
      this.itemDto = await this.repository.loadMovie(this.args.id)

    } else if (this.args.type === BaseItemKind.Episode) {
      this.itemDto = await this.repository.getEpisode(this.args.id)
      this.itemDtoArray = await this.repository.getEpisodes(this.itemDto.SeasonId!, this.itemDto.SeasonId!)
    } else {
      throw new Error("Unsupported type " + this.args.type)
    }
    return this.itemDto!
  }

}