import { router } from "@kit.ArkUI";
import { FinItem, FinItemType } from "@ohpg/fin-core";
import { DetailArgs } from "../detail/DetailArgs";
import { MediaListArgs } from "../media/MediaListArgs";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/19 23:18
 * @Version V1.0
 * @Description
 */
export class MediaRouter {

  public static openDetail(item: FinItem) {
    if (item.type === FinItemType.Movie) {
      let args: DetailArgs = {
        id: item.id,
        name: item.name
      }
      router.pushUrl({url: "pages/detail/movie/MoviePage", params: args})
    } else if (item.type === FinItemType.Series) {
      let args: DetailArgs = {
        id: item.id,
        name: item.name
      }
      router.pushUrl({url: "pages/detail/show/ShowPage", params: args})
    } else {
      let newArgs: MediaListArgs = {
        id: item.id,
        name: item.name,
        type: item.collectionType
      }
      router.pushUrl({url: "pages/media/MediaListPage", params: newArgs})
    }
  }

}