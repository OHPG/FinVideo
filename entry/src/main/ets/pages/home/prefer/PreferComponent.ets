import { HomeToolBar } from "../../../widget/bar/HomeToolBar"
import { CommonConstants } from "../../common/CommonConstants"
import { ActiveInfo, AppStorageKeys, WebTool} from '@ohpg/fin-core'
import { FinRouter} from '@ohpg/fin-framework'
import router from "@ohos.router"
import { pasteboard } from "@kit.BasicServicesKit"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/7 20:27
 * @Version V1.0
 * @Description Prefer
 */
@Component
export struct PreferComponent {

  @StorageProp(AppStorageKeys.KEY_ACTIVE_INFO) activeInfo?: ActiveInfo = undefined

  @Builder
  preferItemBuilder(icon: Resource, title: ResourceStr, callback: Callback<void>) {
    Row({space: CommonConstants.SPACE_12}) {
      SymbolGlyph(icon)
        .fontSize(24)
        .fontColor([$r('sys.color.ohos_id_color_text_primary')])
      Text(title)
        .fontSize(18)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
      Blank()
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(48)
    .padding({
      left: CommonConstants.SPACE_16,
      right: CommonConstants.SPACE_16
    })
    .onClick(() => {
      callback()
    })
  }

  build() {
    Column({space: CommonConstants.SPACE_8}) {
      HomeToolBar({
        title: $r('app.string.home_prefer')
      })

      Column({ space: CommonConstants.SPACE_12}) {
        Row() {
          Text($r('app.string.prefer_current_server'))
          Text(this.activeInfo?.serverInfo.serverName)
        }
        Row() {
          Text($r('app.string.prefer_current_address'))
          Text(this.activeInfo?.addressInfo.address)
        }
        Row() {
          Text($r('app.string.prefer_current_user'))
          Text(this.activeInfo?.userInfo.userName)
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: CommonConstants.SPACE_16,
        right: CommonConstants.SPACE_16
      })

      this.preferItemBuilder($r('sys.symbol.externaldrive'), $r('app.string.prefer_server'), () => {
        FinRouter.editServer()
      })

      this.preferItemBuilder($r('sys.symbol.worldclock'), $r('app.string.prefer_address'), () => {
        FinRouter.editAddress()
      })

      this.preferItemBuilder($r('sys.symbol.person'), $r('app.string.prefer_user'), () => {
        FinRouter.editUser()
      })

      this.preferItemBuilder($r('sys.symbol.play_video'), $r('app.string.prefer_video'), () => {
        router.push({url: "pages/setting/VideoSettingPage"})
      })

      this.preferItemBuilder($r('sys.symbol.message'), $r('app.string.prefer_about'), () => {
        router.push({url: "pages/about/AboutPage"})
      })

      this.preferItemBuilder($r('sys.symbol.doc_plaintext'), $r('app.string.prefer_privacy'), () => {
        WebTool.openBrowser(getContext(), "https://agreement-drcn.hispace.dbankcloud.cn/index.html?lang=zh&agreementId=1571961528242951104")
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
        Text("ICP备案：")
          .fontSize(16)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))

        Text("豫ICP备2025110731号-2A")
          .fontColor($r('sys.color.ohos_id_color_component_activated'))
          .onClick(() => {
            WebTool.openBrowser(getContext(), "https://beian.miit.gov.cn")
          })
      }
      .margin(CommonConstants.SPACE_16)

    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

}

