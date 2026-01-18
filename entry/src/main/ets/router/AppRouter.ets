import { PlayerArgs } from "../pages/player/PlayerArgs";

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
  public static goToPlayer(context: UIContext, args: PlayerArgs) {
    context.getRouter().pushUrl({url: "pages/player/PlayerPage", params: args})
  }

}