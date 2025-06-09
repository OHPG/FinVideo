import { router } from "@kit.ArkUI";
import { BaseItemDto, BaseItemKind } from "@ohpg/jellyfin";
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

  public static openDetail(item: BaseItemDto) {
    if (item.Type === BaseItemKind.Movie) {
      let args: DetailArgs = {
        id: item.Id!,
        name: item.Name!
      }
      router.pushUrl({url: "pages/detail/movie/MoviePage", params: args})
    } else if (item.Type === BaseItemKind.Series) {
      let args: DetailArgs = {
        id: item.Id!,
        name: item.Name!
      }
      router.pushUrl({url: "pages/detail/show/ShowPage", params: args})
    } else {
      let newArgs: MediaListArgs = {
        id: item.Id!,
        name: item.Name!,
        type: item.CollectionType
      }
      router.pushUrl({url: "pages/media/MediaListPage", params: newArgs})
    }
  }

}