import { window } from '@kit.ArkUI'
import { CommonConstants, ToolBar } from '@ohpg/fin-framework'
import { AVPlayerKit, AVPlayerPrefer } from '@ohpg/player'
import { AVSubtitleSettingGroup, AVSubtitleStyleSettingGroup } from '@ohpg/widget'
import { groupAttributeModifier, windowAttributeModifier } from '../../style/Modifier'

@Entry
@Component
struct SubtitleSettingPage {

  @StorageProp('currentAvoidArea') avoidArea?: window.AvoidArea = undefined

  private playerPrefer: AVPlayerPrefer = AVPlayerKit.getPrefer()

  build() {
    Column({ space: CommonConstants.SPACE_8 }) {
      ToolBar({ title: $r('app.string.prefer_subtitle') })

      Scroll() {
        Column({ space: CommonConstants.SPACE_8 }) {

          // ===== 优先轨道语言 =====
          AVSubtitleSettingGroup()
            .attributeModifier(groupAttributeModifier)

          // ===== 字幕显示设置 =====
          AVSubtitleStyleSettingGroup()
            .attributeModifier(groupAttributeModifier)

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
