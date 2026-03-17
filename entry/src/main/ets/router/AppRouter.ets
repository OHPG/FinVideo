import { FinItem, FinItemType } from "@ohpg/fin-core";
import { FinRepository, ProgressDialog } from "@ohpg/fin-framework";
import { Repository } from "../data/Repository";
import { PlayerArgs } from "../pages/player/PlayerArgs";
import { AppPlayer } from "../player/AppPlayer";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2026/1/18 22:50
 * @Version V1.0
 * @Description
 */
export class AppRouter {

  /**
   * 跳转到播放页
   * @param context
   * @param args
   */
  public static async goToPlayer(context: UIContext, args: PlayerArgs) {
    let appPlayer: AppPlayer = AppStorage.get(AppPlayer.APP_PLAYER)!
    if (appPlayer?.hasPlayerInstance()) {
      context.getPromptAction().showToast({message: $r('app.string.global_operation_busy')})
      return
    }
    let dialog = new ProgressDialog(context)
    await dialog.show()
    try {
      let repository: Repository = AppStorage.get(FinRepository.REPOSITORY)!;
      let itemDtoArray: Array<FinItem>;
      let itemIndex: number = 0
      if (args.type === FinItemType.Movie) {
        let itemDto: FinItem = await repository.getMovie(args.id)
        itemDtoArray = new Array()
        itemDtoArray.push(itemDto)
      } else if (args.type === FinItemType.Episode) {
        let itemDto = await repository.getEpisode(args.id)
        itemDtoArray = await repository.getEpisodes(itemDto.seasonId!, itemDto.seasonId!)
        itemIndex = itemDtoArray.findIndex((item) => item.id === args.id)
        itemIndex = itemIndex < 0 ? 0 : itemIndex
      } else {
        throw new Error("Unsupported type " + args.type)
      }
      appPlayer.playAll(itemDtoArray, itemIndex)
    } catch (e) {
      context.getPromptAction().showToast({message: e["message"] || "加载出错。"})
      throw e as Error
    }
    finally {
      await dialog.dismiss(true)
    }
    context.getRouter().pushUrl({url: "pages/player/PlayerPage"})
  }

}