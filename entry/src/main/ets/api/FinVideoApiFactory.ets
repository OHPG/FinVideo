import { EmbyFinApi } from "./emby/EmbyFinApi";
import { JellyfinFinApi } from "./jellyfin/JellyfinFinApi";
import { ApiFactory, CoreApi, ServerType } from "@ohpg/fin-core";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/11/14 22:33
 * @Version V1.0
 * @Description
 */
export class FinVideoApiFactory extends ApiFactory {

  constructor(context: Context) {
    super(context, "FinVideo")
  }

  protected onCreateApi<T extends CoreApi>(serverType: ServerType): T {
    if (serverType === ServerType.JELLYFIN) {
      return new JellyfinFinApi(this.context, this.clientInfo, this.deviceInfo) as ESObject as T
    } else if (serverType === ServerType.EMBY) {
      return new EmbyFinApi(this.context, this.clientInfo, this.deviceInfo) as ESObject as T
    }
    throw new Error(serverType + " not implemented.");
  }

}