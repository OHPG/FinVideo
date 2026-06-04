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

  /** 视频宽度（px），用于版本自动选择策略 */
  width?: number

  /** 视频高度（px），用于版本自动选择策略 */
  height?: number

  /** 码率（bps），用于版本自动选择策略 */
  bitrate?: number

  /** 视频编码，如 h264 / hevc / av1 / vp9，用于版本自动选择策略 */
  videoCodec?: string

}