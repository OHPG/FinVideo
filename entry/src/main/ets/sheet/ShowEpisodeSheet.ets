import { ComponentContent } from "@kit.ArkUI";
import { ShowEpisodePage } from "../pages/detail/show/episode/ShowEpisodePage";
import { Sheet } from "@ohpg/fin-framework";
import { deviceInfo } from "@kit.BasicServicesKit";
import { FinItem } from "@ohpg/fin-core";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/23 19:27
 * @Version V1.0
 * @Description
 */
export class ShowEpisodeSheet extends Sheet {

  private readonly args: FinItem

  constructor(context: UIContext, args: FinItem) {
    super(context)
    this.args = args
    this.options.width = deviceInfo.deviceType === 'phone' ? '100%' : "60%"
  }

  protected onCreateContent(): ComponentContent<object> {
    return new ComponentContent(this.uiContext, wrapBuilder(ShowEpisodeComponent), [this.args, new LocalStorage()])
  }

}

@Builder
function ShowEpisodeComponent(params: [FinItem, LocalStorage]) {
  ShowEpisodePage({
    episodeDto: params[0],
    storage: params[1]
  }, params[1])
}