import { window } from '@kit.ArkUI'
import { AppPrefer } from '../../prefer/AppPrefer'
import { CommonConstants, ToolBar } from '@ohpg/fin-framework'
import { MarketUtil, WebTool } from '@ohpg/fin-core'
import { common } from '@kit.AbilityKit'

@Entry
@Component
struct VideoSettingPage {

  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  private appPrefer: AppPrefer = AppStorage.get(AppPrefer.PREFER)!

  private voDescArray = [
    $r('app.string.player_video_vo_embed_desc'),
    $r('app.string.player_video_vo_gpu_desc')
  ]

  private voSelectionArray: Array<SelectOption> = [
    {
      value: $r('app.string.player_video_vo_embed')
    },
    {
      value: $r('app.string.player_video_vo_gpu')
    }
  ]

  @State voIndex: number = 0

  aboutToAppear(): void {
    this.voIndex = this.appPrefer.getPlayerVo()
  }

  build() {

    Column({space: CommonConstants.SPACE_8}) {
      ToolBar({
        title: $r('app.string.prefer_video')
      })

      Row({space: CommonConstants.SPACE_8}) {
        SymbolGlyph($r('sys.symbol.play_hexagon_fill'))
          .fontSize(24)
          .fontColor([$r('sys.color.ohos_id_color_text_primary')])
        Text($r('app.string.prefer_video_vo'))
          .fontSize(18)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
        Blank()
        Select(this.voSelectionArray)
          .value(this.voSelectionArray[this.voIndex].value)
          .onSelect((index) => {
            this.voIndex = index
            this.appPrefer.setPlayerVo(index)
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(48)
      .padding({
        left: CommonConstants.SPACE_16,
        right: CommonConstants.SPACE_16
      })

      Text(this.voDescArray[this.voIndex])
        .fontSize(14)
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          left: CommonConstants.SPACE_16,
          right: CommonConstants.SPACE_16
        })

      Blank()

      Text() {
        Span($r('app.string.player_video_thanks_01'))
          .fontSize(14)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        Span("FinPlayer")
          .fontSize(14)
          .fontColor($r('sys.color.ohos_id_color_component_activated'))
          .onClick(() => {
            MarketUtil.gotoMarket(this.getUIContext().getHostContext()! as common.UIAbilityContext
              , "org.ohpg.fin.player")
          })
        Span($r('app.string.player_video_thanks_02'))
          .fontSize(14)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
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