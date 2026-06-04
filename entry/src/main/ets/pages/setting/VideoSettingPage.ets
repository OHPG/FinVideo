import { window } from '@kit.ArkUI'
import { CommonConstants, ToolBar } from '@ohpg/fin-framework'
import { AVPlayerKit, AVPlayerPrefer } from '@ohpg/player'
import { AVPlaybackSettingGroup, AVNavigationSettingGroup } from '@ohpg/widget'
import { groupAttributeModifier, windowAttributeModifier } from '../../style/Modifier'
import { VersionSettingGroup } from '../../widget/comp/VersionSettingGroup'

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

          // ===== 版本选择组 =====
          VersionSettingGroup()
            .attributeModifier(groupAttributeModifier)

          // ===== 导航组 =====
          AVNavigationSettingGroup()
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
