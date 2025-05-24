import { BaseItemKind } from "@ohpg/jellyfin";
import { DetailArgs } from "../detail/DetailArgs";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/24 12:01
 * @Version V1.0
 * @Description
 */
export interface PlayerArgs extends DetailArgs {

  type: BaseItemKind

}