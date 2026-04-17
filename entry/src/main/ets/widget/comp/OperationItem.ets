import { CommonConstants } from '@ohpg/fin-framework'

const PREFER_ITEM_HEIGHT = 56

@Component
export struct OperationItem {

  @State icon?: Resource = undefined

  @State title?: ResourceStr = undefined

  @State subtitle?: ResourceStr = undefined

  @Builder closerBuilder() {}

  @BuilderParam closer: () => void = this.closerBuilder

  build() {
    Row({ space: CommonConstants.SPACE_8 }) {
      SymbolGlyph(this.icon)
        .fontSize(24)
        .visibility(this.icon ? Visibility.Visible : Visibility.Hidden)
        .fontColor([$r('sys.color.ohos_id_color_text_primary')])

      Column() {
        Text(this.title)
          .fontSize(18)
          .width(CommonConstants.FULL_PERCENT)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))

        Text(this.subtitle)
          .fontSize(14)
          .width(CommonConstants.FULL_PERCENT)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .visibility(this.subtitle ? Visibility.Visible : Visibility.None)
      }
      .layoutWeight(1)

      this.closer()
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(PREFER_ITEM_HEIGHT)
    .padding({
      left: CommonConstants.SPACE_16,
      right: CommonConstants.SPACE_16
    })
  }

}
