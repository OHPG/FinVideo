import { FinSubSource } from "./FinSubSource"

export interface FinItemSource {

  /**
   * 数据源唯一标识（用于多版本选择时匹配 preferredSourceId）
   */
  id?: string

  /**
   * 数据源名称（用于多版本选择弹窗展示）
   */
  name?: string

  url: string

  sdr: boolean

  sub?: Array<FinSubSource>

}