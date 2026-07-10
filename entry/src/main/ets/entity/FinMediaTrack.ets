/**
 * 媒体轨道信息（视频轨 / 音频轨 / 字幕轨）
 */
export interface FinMediaTrack {

  /** 轨道类型：Video / Audio / Subtitle */
  type: 'Video' | 'Audio' | 'Subtitle'

  /** 轨道标题（如 "4K AV1 HDR"、"English - AAC - 5.1"、"简体中文"） */
  title: string

  /** 编码（如 av1, hevc, aac, flac, srt, ass） */
  codec?: string

  /** 语言 */
  language?: string

  /** 宽度（仅视频） */
  width?: number

  /** 高度（仅视频） */
  height?: number

  /** 帧率（仅视频） */
  frameRate?: number

  /** 比特率 bps */
  bitrate?: number

  /** 动态范围类型（如 HDR10, SDR, HLG, Dolby Vision） */
  videoRangeType?: string

  /** 像素比（如 "1.85:1"） */
  aspectRatio?: string

  /** 编码配置（如 "Main 12"） */
  profile?: string

  /** 位深（如 10） */
  bitDepth?: number

  /** 颜色格式（如 "yuv420p10le"） */
  pixelFormat?: string

  /** 声道数（仅音频） */
  channels?: number

  /** 声道布局（如 "5.1"）（仅音频） */
  channelLayout?: string

  /** 采样率（仅音频） */
  sampleRate?: number

  /** 是否默认轨 */
  isDefault?: boolean

  /** 是否外挂（仅字幕） */
  isExternal?: boolean

  /** 是否强制（仅字幕） */
  isForced?: boolean
}
