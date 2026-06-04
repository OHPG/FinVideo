/**
 * 多版本自动选择模式
 */
export enum VersionSelectMode {
  /** 每次播放前弹框手动选择 */
  Ask = 0,
  /** 根据设备类型 + 网络智能自动选择（推荐） */
  Auto = 1,
  /** 总是选分辨率/码率最高的版本 */
  Highest = 2,
  /** 总是选分辨率/码率最低的版本（省流） */
  Lowest = 3,
}

export function versionSelectModeName(mode: VersionSelectMode): string {
  if (mode === VersionSelectMode.Ask) return 'Ask'
  if (mode === VersionSelectMode.Auto) return 'Auto'
  if (mode === VersionSelectMode.Highest) return 'Highest'
  return 'Lowest'
}
