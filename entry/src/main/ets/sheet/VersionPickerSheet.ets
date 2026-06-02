import { ComponentContent, UIContext } from '@kit.ArkUI'
import { Sheet } from '@ohpg/fin-framework'

/**
 * 版本选择底部弹窗的数据参数
 */
interface VersionPickerArgs {
  items: string[]
  onSelect: (index: number) => void
  onCancel: () => void
  sheet: Sheet
}

@Builder
function versionPickerBuilder(args: VersionPickerArgs) {
  Column({ space: 0 }) {
    // 标题
    Text($r('app.string.version_picker_title'))
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })

    Divider()
      .color($r('sys.color.ohos_id_color_list_separator'))
      .width('100%')

    // 选项列表
    List() {
      ForEach(args.items, (item: string, index: number) => {
        ListItem() {
          Stack({ alignContent: Alignment.TopEnd }) {
            Text(item)
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .width('100%')
              .padding({ left: 20, right: 20, top: 20, bottom: 20 })
              .onClick(() => {
                args.onSelect(index)
                args.sheet.dismiss(true)
              })

            // 右上角"默认" tag，仅第0个显示
            Text($r('app.string.version_picker_default'))
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ right: 12, top: 2 })
              .hitTestBehavior(HitTestMode.None)
              .visibility(index === 0 ? Visibility.Visible : Visibility.Hidden)
          }
          .width('100%')
        }
      })
    }
    .width('100%')
    .height('auto')
    .constraintSize({ maxHeight: 400 })
    .scrollBar(BarState.Off)
    .divider({
      strokeWidth: 0.5,
      color: $r('sys.color.ohos_id_color_list_separator'),
    })

    // 取消按钮
    Text($r('app.string.version_picker_cancel'))
      .fontSize(16)
      .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      .width('100%')
      .textAlign(TextAlign.Center)
      .padding({ top: 16, bottom: 16 })
      .onClick(() => {
        args.onCancel()
        args.sheet.dismiss(true)
      })
  }
  .width('100%')
}

/**
 * 版本选择底部 Sheet
 * - 从底部弹出，竖排列表，路径完整显示
 * - 第0个选项显示斜角"默认" badge
 * - setCancelable(false) 禁止下滑手势关闭，只能选中或点取消
 */
export class VersionPickerSheet extends Sheet {

  private args: VersionPickerArgs

  constructor(uiContext: UIContext, items: string[],
    onSelect: (index: number) => void, onCancel: () => void) {
    super(uiContext)
    this.setCancelable(false)
    this.args = {
      items: items,
      onSelect: onSelect,
      onCancel: onCancel,
      sheet: this,
    }
  }

  protected onCreateContent(): ComponentContent<object> {
    return new ComponentContent(this.uiContext, wrapBuilder(versionPickerBuilder), this.args)
  }
}
