import { ComponentContent } from "@kit.ArkUI";
import { ShowEpisodePage } from "../pages/detail/show/episode/ShowEpisodePage";
import { Sheet } from "@ohpg/fin-framework";
import { deviceInfo } from "@kit.BasicServicesKit";
import { FinItem } from "@ohpg/fin-core";
import { PlayerArgs } from "../pages/player/PlayerArgs";
import { AppRouter } from "../router/AppRouter";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/23 19:27
 * @Version V1.0
 * @Description
 */
export class ShowEpisodeSheet extends Sheet {

  private readonly args: FinItem

  private playArgs?: PlayerArgs

  private readonly callback: Callback<PlayerArgs> = (args) => {
    this.playArgs = args
    this.dismiss(true)
  }

  constructor(context: UIContext, args: FinItem) {
    super(context)
    this.args = args
    this.options.width = deviceInfo.deviceType === 'phone' ? '100%' : "60%"
  }

  protected onCreateContent(): ComponentContent<object> {
    return new ComponentContent(this.uiContext, wrapBuilder(ShowEpisodeComponent), [this.args, new LocalStorage(), this.callback])
  }

  protected onDidDisappear(): void {
    if (this.playArgs) {
      AppRouter.goToPlayer(this.uiContext, this.playArgs)
    }
    this.playArgs = undefined
  }

}

@Builder
function ShowEpisodeComponent(params: [FinItem, LocalStorage, Callback<PlayerArgs>]) {
  ShowEpisodePage({
    episodeDto: params[0],
    storage: params[1],
    callback: params[2]
  }, params[1])
}