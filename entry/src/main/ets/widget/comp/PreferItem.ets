import { CommonConstants } from "../../pages/common/CommonConstants"
import { clickableModifier } from "../../style/Modifier"

const PREFER_ITEM_HEIGHT = 56

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/7 20:27
 * @Version V1.0
 * @Description 设置页通用条目组件
 */
@Component
export struct PreferItem {

  icon: Resource = $r('sys.symbol.dot_grid_2x2')

  title: ResourceStr = ''

  @Prop tips: ResourceStr = ''

  callback: Callback<void> = () => {}

  build() {
    Row({ space: CommonConstants.SPACE_12 }) {
      SymbolGlyph(this.icon)
        .fontSize(24)
        .fontColor([$r('sys.color.ohos_id_color_text_primary')])
      Text(this.title)
        .fontSize(18)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .flexShrink(0)
      Blank()
      Text(this.tips)
        .fontSize(14)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .visibility(this.tips ? Visibility.Visible : Visibility.None)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(PREFER_ITEM_HEIGHT)
    .padding({
      left: CommonConstants.SPACE_16,
      right: CommonConstants.SPACE_16
    })
    .attributeModifier(clickableModifier)
    .onClick(() => {
      this.callback()
    })
  }

}
