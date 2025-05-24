import { CommonConstants } from "../../pages/common/CommonConstants"

@Component
export struct HomeToolBar {

  @Require @Prop title: ResourceStr

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.float.header_font_size'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .fontFamily(CommonConstants.HARMONY_HEITI_BOLD_FONT_FAMILY)
        .margin({ right: $r('app.float.sm_padding_margin') })

      // Search({ placeholder: $r('app.string.search_title') })
      //   .focusable(false)
      //   .fontColor($r('sys.color.ohos_id_color_text_primary'))
      //   .textFont({ size: $r('app.float.large_text_size') })
      //   .width($r('app.float.search_width'))
      //   .height($r('app.float.search_height'))
      //   .onClick(() => {
      //     this.getUIContext().getRouter().pushUrl({
      //       url: "pages/search/SearchPage"
      //     })
      //   })
    }
    .padding({
      left: $r('app.float.xxl_padding_margin'),
      right: $r('app.float.lg_padding_margin'),
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.top_navigation_height'))
  }

}