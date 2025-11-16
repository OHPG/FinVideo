import { FinItem, FinItemType } from "@ohpg/fin-core";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/6/16 23:03
 * @Version V1.0
 * @Description
 */
export interface SectionInfo {

  type: FinItemType

  items?: Array<FinItem>

}