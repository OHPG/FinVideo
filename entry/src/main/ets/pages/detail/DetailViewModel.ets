import { DetailArgs } from "./DetailArgs";
import { FinItemData } from "@ohpg/fin-core";
import { AppViewModel } from "../common/AppViewModel";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/21 21:08
 * @Version V1.0
 * @Description
 */
export class DetailViewModel extends AppViewModel {

  protected readonly args: DetailArgs

  protected userItemDto?: FinItemData = undefined

  constructor(context: Context, args: DetailArgs) {
    super(context)
    this.args = args
  }

  protected getUserItem(): Promise<FinItemData> {
    return this.repository.getItemData(this.args.id)
      .then((dto) => {
        this.userItemDto = dto
        return dto
      })
  }

  isFinished(): boolean {
    return this.userItemDto?.played === true
  }

  async finishOrNot(): Promise<boolean> {
    if (this.userItemDto?.played) {
      await this.repository.markUnplayedItem(this.args.id)
      this.userItemDto.played = false
    } else {
      await this.repository.markPlayedItem(this.args.id)
      this.userItemDto!.played = true
    }
    return this.userItemDto!.played!
  }

  isFavourite(): boolean {
    return this.userItemDto?.isFavorite === true
  }

  async favouriteOrNot(): Promise<boolean> {
    if (this.userItemDto?.isFavorite) {
      await this.repository.unmarkFavoriteItem(this.args.id)
      this.userItemDto.isFavorite = false
    } else {
      await this.repository.markFavoriteItem(this.args.id)
      this.userItemDto!.isFavorite = true
    }
    return this.userItemDto!.isFavorite!
  }

}