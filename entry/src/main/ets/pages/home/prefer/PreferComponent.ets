import { HomeToolBar } from "../../../widget/bar/HomeToolBar"
import { CommonConstants } from "../../common/CommonConstants"
import { ActiveInfo, AppStorageKeys, CommentTool, MarketUtil } from '@ohpg/fin-core'
import { FinRouter, FinWebTool } from '@ohpg/fin-framework'
import { pasteboard } from "@kit.BasicServicesKit"
import { groupAttributeModifier, itemDividerBuilder } from '../../../style/Modifier'
import { PreferItem } from '../../../widget/comp/PreferItem'
import { common } from '@kit.AbilityKit'
import BuildProfile from 'entry/BuildProfile'

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/7 20:27
 * @Version V1.0
 * @Description Prefer
 */
@Component
export struct PreferComponent {

  @StorageLink(AppStorageKeys.KEY_ACTIVE_INFO) activeInfo?: ActiveInfo = undefined

  @Consume("bottomOffset") bottomOffset: number

  build() {
    Column() {
      HomeToolBar({
        title: $r('app.string.home_prefer')
      })

      Scroll() {
        Column({ space: CommonConstants.SPACE_12 }) {


          // ===== Group 1: 服务器和用户信息 =====
          Column() {
            PreferItem({
              icon: $r('sys.symbol.externaldrive'),
              title: $r('app.string.prefer_server'),
              tips: this.activeInfo?.serverInfo.serverName ?? '',
              callback: () => { FinRouter.editServer(this.getUIContext()) }
            })
            itemDividerBuilder()
            PreferItem({
              icon: $r('sys.symbol.worldclock'),
              title: $r('app.string.prefer_address'),
              tips: this.activeInfo?.addressInfo.address ?? '',
              callback: () => { FinRouter.editAddress(this.getUIContext()) }
            })
            itemDividerBuilder()
            PreferItem({
              icon: $r('sys.symbol.person'),
              title: $r('app.string.prefer_user'),
              tips: this.activeInfo?.userInfo.userName ?? '',
              callback: () => { FinRouter.editUser(this.getUIContext()) }
            })
          }
          .attributeModifier(groupAttributeModifier)

          // ===== Group 2: 界面到字幕 =====
          Column() {
            PreferItem({
              icon: $r('sys.symbol.satellite_map_fill'),
              title: $r('app.string.prefer_interface'),
              callback: () => { this.getUIContext().getRouter().pushUrl({ url: "pages/interface/InterfacePage" }) }
            })
            itemDividerBuilder()
            PreferItem({
              icon: $r('sys.symbol.play_video'),
              title: $r('app.string.prefer_video'),
              callback: () => { this.getUIContext().getRouter().pushUrl({ url: "pages/setting/VideoSettingPage" }) }
            })
            itemDividerBuilder()
            PreferItem({
              icon: $r('sys.symbol.play_hexagon'),
              title: $r('app.string.prefer_video_codec_prefer'),
              callback: () => { this.getUIContext().getRouter().pushUrl({ url: "pages/setting/CodecSettingPage" }) }
            })
            itemDividerBuilder()
            PreferItem({
              icon: $r('sys.symbol.hand_scribble'),
              title: $r('app.string.prefer_gesture'),
              callback: () => { this.getUIContext().getRouter().pushUrl({ url: "pages/setting/GestureSettingPage" }) }
            })
            itemDividerBuilder()
            PreferItem({
              icon: $r('sys.symbol.ellipsis_bubble'),
              title: $r('app.string.prefer_subtitle'),
              callback: () => { this.getUIContext().getRouter().pushUrl({ url: "pages/setting/SubtitleSettingPage" }) }
            })
          }
          .attributeModifier(groupAttributeModifier)

          // ===== Group 3: 关于等 =====
          Column() {
            PreferItem({
              icon: $r('sys.symbol.message'),
              title: $r('app.string.prefer_about'),
              callback: () => { this.getUIContext().getRouter().pushUrl({ url: "pages/about/AboutPage" }) }
            })
            itemDividerBuilder()
            PreferItem({
              icon: $r('sys.symbol.doc_plaintext'),
              title: $r('app.string.prefer_privacy'),
              callback: () => {
                FinWebTool.open(this.getUIContext()
                  , $r('app.string.prefer_privacy')
                  , "https://agreement-drcn.hispace.dbankcloud.cn/index.html?lang=zh&agreementId=1571961528242951104")
              }
            })
            itemDividerBuilder()
            PreferItem({
              icon: $r('sys.symbol.message_on_message'),
              title: $r('app.string.prefer_rate'),
              callback: () => {
                CommentTool.showComment(this.getUIContext().getHostContext() as common.UIAbilityContext)
              }
            })
            itemDividerBuilder()
            PreferItem({
              icon: $r('sys.symbol.bag'),
              title: $r('app.string.prefer_version'),
              tips: `V${BuildProfile.VERSION_NAME}(${BuildProfile.VERSION_CODE})`,
              callback: () => {
                MarketUtil.gotoMarket(this.getUIContext().getHostContext() as common.UIAbilityContext)
              }
            })
          }
          .attributeModifier(groupAttributeModifier)

          // QQ群
          Row({ space: CommonConstants.SPACE_4 }) {
            Text($r('app.string.prefer_about_qq_group'))
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))

            Text($r('app.string.prefer_about_qq_group_value'))
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_component_activated'))
              .onClick(() => {
                let text = getContext().resourceManager
                  .getStringSync($r('app.string.prefer_about_qq_group_value'))
                const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
                const systemPasteboard = pasteboard.getSystemPasteboard();
                systemPasteboard.setData(pasteboardData);
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.prefer_about_qq_group_copied') })
              })
          }
          .padding({ top: CommonConstants.SPACE_8 })

          // ICP 备案
          Row({ space: CommonConstants.SPACE_4 }) {
            Text("ICP备案：")
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))

            Text("豫ICP备2025110731号-2A")
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_component_activated'))
              .onClick(() => {
                FinWebTool.open(this.getUIContext(), "ICP备案", "https://beian.miit.gov.cn")
              })
          }
          .padding({ bottom: CommonConstants.SPACE_16 })
        }
        .constraintSize({
          minHeight: "100%"
        })
      }
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Fade)
      .width(CommonConstants.FULL_PERCENT)
      .height('auto')
      .layoutWeight(1)
      .padding({ bottom: this.bottomOffset })
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

}
