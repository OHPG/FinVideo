import { promptAction, window } from '@kit.ArkUI'
import { WebTool } from '@ohpg/fin-core'
import { CommonConstants, ToolBar } from '@ohpg/fin-framework'
import { pasteboard } from '@kit.BasicServicesKit'

@Entry
@Component
struct AboutPage {

  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  build() {

    Column({space: CommonConstants.SPACE_8}) {
      ToolBar({
        title: $r('app.string.prefer_about')
      })

      Text($r('app.string.prefer_about_desc'))
        .fontSize(16)
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          left: CommonConstants.SPACE_16,
          right: CommonConstants.SPACE_16
        })

      Blank()

      Row({space: CommonConstants.SPACE_4}) {
        Text($r('app.string.prefer_about_qq_group'))
        .fontSize(16)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))

        Text($r('app.string.prefer_about_qq_group_value'))
          .fontSize(16)
          .fontColor($r('sys.color.ohos_id_color_component_activated'))
          .onClick(() => {
            let text = getContext().resourceManager
              .getStringSync($r('app.string.prefer_about_qq_group_value'))
            const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
            const systemPasteboard = pasteboard.getSystemPasteboard();
            systemPasteboard.setData(pasteboardData);
            this.getUIContext().getPromptAction().showToast({message: $r('app.string.prefer_about_qq_group_copied')})
          })
      }

      Row({space: CommonConstants.SPACE_4}) {
        Text($r('app.string.prefer_about_official_web'))
        .fontSize(16)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))

        Text($r('app.string.prefer_about_official_web_value'))
        .fontSize(16)
        .fontColor($r('sys.color.ohos_id_color_component_activated'))
          .onClick(() => {
            WebTool.openBrowser(getContext()
              , getContext().resourceManager
                .getStringSync($r('app.string.prefer_about_official_web_value')))
          })
      }

      Stack()
        .width(CommonConstants.FULL_PERCENT)
        .height(48)

    }
    .padding({
      bottom: px2vp(this.avoidArea?.bottomRect.height)
    })
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)

  }

}