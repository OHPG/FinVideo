import { UserItemDataDto } from "@ohpg/jellyfin";
import { AppViewModel } from "../common/AppViewModel";
import { DetailArgs } from "./DetailArgs";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/21 21:08
 * @Version V1.0
 * @Description
 */
export class DetailViewModel extends AppViewModel {

  protected readonly args: DetailArgs

  protected userItemDto?: UserItemDataDto = undefined

  constructor(context: Context, args: DetailArgs) {
    super(context)
    this.args = args
  }

  protected getUserItem(): Promise<UserItemDataDto> {
    return this.repository.getUserItem(this.args.id)
      .then((dto) => {
        this.userItemDto = dto
        return dto
      })
  }

  isFinished(): boolean {
    return this.userItemDto?.Played === true
  }

  async finishOrNot(): Promise<boolean> {
    if (this.userItemDto?.Played) {
      this.userItemDto = await this.repository.unmarkPlayed(this.args.id)
    } else {
      this.userItemDto = await this.repository.markPlayed(this.args.id)
    }
    return this.userItemDto!.Played!
  }

  isFavourite(): boolean {
    return this.userItemDto?.IsFavorite === true
  }

  async favouriteOrNot(): Promise<boolean> {
    if (this.userItemDto?.IsFavorite) {
      this.userItemDto = await this.repository.unmarkFavorite(this.args.id)
    } else {
      this.userItemDto = await this.repository.markFavorite(this.args.id)
    }
    return this.userItemDto!.IsFavorite!
  }

}