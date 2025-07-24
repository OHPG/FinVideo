import { ActiveInfo, FinApi, FinApis, ServerType } from "@ohpg/fin-core";
import { EmbyFinApi } from "./EmbyFinApi";
import { FinVideoApi } from "./FinVideoApi";
import { JellyfinFinApi } from "./JellyfinFinApi";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/7/6 23:29
 * @Version V1.0
 * @Description Fin Video Apis
 */
export class FinVideoApis extends FinApis {

  private finApiMap = new Map<ServerType, FinVideoApi>()

  constructor(context: Context) {
    super(context, "FinVideo")
  }

  activeFinApi(activeInfo: ActiveInfo): FinApi {
    let type = activeInfo.serverInfo.serverType
    let finApi = this.finApiMap.get(type)
    if (!finApi) {
      if (type === ServerType.JELLYFIN) {
        finApi = new JellyfinFinApi(this.context)
      } else if (type === ServerType.EMBY) {
        finApi = new EmbyFinApi(this.context)
      } else {
        throw new Error("Unsupported server type: " + type)
      }
      this.finApiMap.set(type, finApi)
    }
    // TODO
    return finApi
  }

}