import { BaseItemDto, BaseItemKind } from "@ohpg/jellyfin";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/6/16 23:03
 * @Version V1.0
 * @Description
 */
export interface SectionInfo {

  type: BaseItemKind

  items?: Array<BaseItemDto>

}