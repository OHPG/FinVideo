import { FinItemType } from "@ohpg/fin-core";
import { DetailArgs } from "../detail/DetailArgs";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/24 12:01
 * @Version V1.0
 * @Description
 */
export interface PlayerArgs extends DetailArgs {

  type: FinItemType

  /**
   * 用户在详情页选中的版本 ID。
   * 不传时由 AppMediaResolver 按版本选择策略自动决定。
   */
  preferredSourceId?: string

}
