import { BaseItemKind } from "@ohpg/jellyfin";
import { DetailArgs } from "../detail/DetailArgs";
import { router } from "@kit.ArkUI";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/19 23:18
 * @Version V1.0
 * @Description
 */
export class MediaRouter {

  public static openDetail(type: BaseItemKind, args: DetailArgs) {
    if (type === BaseItemKind.Movie) {
      router.push({url: "pages/detail/movie/MoviePage", params: args})
    } else if (type === BaseItemKind.Series) {
      router.push({url: "pages/detail/show/ShowPage", params: args})
    } else {

    }
  }

}