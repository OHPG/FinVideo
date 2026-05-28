import { window } from '@kit.ArkUI'
import { CommonConstants, ToolBar } from '@ohpg/fin-framework'
import { AVPlayerKit, AVPlayerPrefer } from '@ohpg/player'
import { AVGestureSettingGroup } from '@ohpg/widget'
import { groupAttributeModifier, windowAttributeModifier } from '../../style/Modifier'

@Entry
@Component
struct GestureSettingPage {

  @StorageProp('currentAvoidArea') avoidArea?: window.AvoidArea = undefined

  private playerPrefer: AVPlayerPrefer = AVPlayerKit.getPrefer()

  build() {
    Column({ space: CommonConstants.SPACE_8 }) {
      ToolBar({ title: $r('app.string.prefer_gesture') })

      Scroll() {
        Column({ space: CommonConstants.SPACE_8 }) {

          // ===== 手势组 =====
          AVGestureSettingGroup()
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
