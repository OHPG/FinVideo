import { window } from '@kit.ArkUI'
import { CommonConstants, ToolBar } from '@ohpg/fin-framework'
import { MarketUtil } from '@ohpg/fin-core'
import { common } from '@kit.AbilityKit'
import { AVPlayerKit, AVPlayerPrefer } from '@ohpg/player'
import { AVPlaybackSettingGroup, AVNavigationSettingGroup } from '@ohpg/widget'
import { groupAttributeModifier, windowAttributeModifier } from '../../style/Modifier'

@Entry
@Component
struct VideoSettingPage {

  @StorageProp('currentAvoidArea') avoidArea?: window.AvoidArea = undefined

  private playerPrefer: AVPlayerPrefer = AVPlayerKit.getPrefer()

  build() {
    Column({ space: CommonConstants.SPACE_8 }) {
      ToolBar({ title: $r('app.string.prefer_video') })

      Scroll() {
        Column({ space: CommonConstants.SPACE_8 }) {

          // ===== 播放控制组 =====
          AVPlaybackSettingGroup()
            .attributeModifier(groupAttributeModifier)

          // ===== 导航组 =====
          AVNavigationSettingGroup()
            .attributeModifier(groupAttributeModifier)

          Text() {
            Span($r('app.string.player_video_thanks_01'))
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            Span("FinPlayer")
              .fontSize(18)
              .fontColor($r('sys.color.ohos_id_color_component_activated'))
              .onClick(() => {
                MarketUtil.gotoMarket(this.getUIContext().getHostContext()! as common.UIAbilityContext
                  , "org.ohpg.fin.player")
              })
            Span($r('app.string.player_video_thanks_02'))
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
          .width(CommonConstants.FULL_PERCENT)
          .textAlign(TextAlign.Center)
          .padding({ top: CommonConstants.SPACE_8, bottom: CommonConstants.SPACE_8 })

        }
        .padding({
          bottom: px2vp(this.avoidArea?.bottomRect.height)
        })
      }
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Fade)
      .width(CommonConstants.FULL_PERCENT)
      .height('auto')
      .layoutWeight(1)
    }
    .attributeModifier(windowAttributeModifier)
  }

  aboutToDisappear(): void {
    this.playerPrefer.flush()
  }

}
