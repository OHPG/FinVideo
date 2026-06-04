import { CommonConstants } from '@ohpg/fin-framework'
import { AppPrefer } from '../../prefer/AppPrefer'
import { VersionSelectMode } from '../../player/VersionSelectMode'
import { OperationItem } from './OperationItem'

/**
 * 版本选择策略设置组
 *
 * 包含：
 *   - 标题行
 *   - 策略下拉选择（每次询问 / 自动选择 / 最高质量 / 最低质量）
 *   - 当前策略描述
 */
@Component
export struct VersionSettingGroup {

  private appPrefer: AppPrefer = AppStorage.get(AppPrefer.PREFER)!

  @State private mode: VersionSelectMode = VersionSelectMode.Auto

  private readonly options: SelectOption[] = [
    {
      value: $r('app.string.prefer_version_mode_ask'),
      icon: $r('sys.symbol.ellipsis_bubble')
    },
    {
      value: $r('app.string.prefer_version_mode_auto'),
      icon: $r('sys.symbol.play_video')
    },
    {
      value: $r('app.string.prefer_version_mode_highest'),
      icon: $r('sys.symbol.arrow_up_circle')
    },
    {
      value: $r('app.string.prefer_version_mode_lowest'),
      icon: $r('sys.symbol.arrow_down_circle')
    },
  ]

  private readonly descriptions: Resource[] = [
    $r('app.string.prefer_version_mode_ask_desc'),
    $r('app.string.prefer_version_mode_auto_desc'),
    $r('app.string.prefer_version_mode_highest_desc'),
    $r('app.string.prefer_version_mode_lowest_desc'),
  ]

  aboutToAppear(): void {
    this.mode = this.appPrefer.getVersionSelectMode()
  }

  build() {
    Column() {

      // ── 策略选择行 ────────────────────────────────────────────────────────────
      OperationItem({
        icon: $r('sys.symbol.discover_circle_fill'),
        title: $r('app.string.prefer_version_select_mode'),
      }) {
        Select(this.options)
          .selected(this.mode)
          .value(this.options[this.mode].value!)
          .onSelect((index: number) => {
            this.mode = index as VersionSelectMode
            this.appPrefer.setVersionSelectMode(this.mode)
          })
      }

      Text(this.descriptions[this.mode])
        .fontSize(14)
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          left: CommonConstants.SPACE_16,
          right: CommonConstants.SPACE_16,
          bottom: CommonConstants.SPACE_8
        })
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}
