import { CollectionType } from "@ohpg/jellyfin";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/19 22:32
 * @Version V1.0
 * @Description List args
 */
export interface MediaListArgs {

  id: string,

  name: string,

  type?: CollectionType

}