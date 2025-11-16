import { FinItem } from "@ohpg/fin-core";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/11 22:28
 * @Version V1.0
 * @Description
 */
export interface GroupInfo {

  type: 'Continue' | 'Next' | 'Normal'

  group?: FinItem

  items?: Array<FinItem>

  favourite?: boolean

}