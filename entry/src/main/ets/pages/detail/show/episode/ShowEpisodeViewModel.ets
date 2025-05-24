import { BaseItemDto } from "@ohpg/jellyfin";
import { DetailViewModel } from "../../DetailViewModel";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/23 20:23
 * @Version V1.0
 * @Description
 */
export class ShowEpisodeViewModel extends DetailViewModel {

  constructor(context: Context, args: BaseItemDto) {
    super(context, {
      id: args.Id!,
      name: args.Name!
    })
    this.userItemDto = args.UserData
  }

}