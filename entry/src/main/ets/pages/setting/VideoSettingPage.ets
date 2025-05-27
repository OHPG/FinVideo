import { CommonConstants, ToolBar } from '@ohpg/fin-framework'
import { AppPrefer } from '../../prefer/AppPrefer'

@Entry
@Component
struct VideoSettingPage {

  private appPrefer: AppPrefer = AppStorage.get(AppPrefer.PREFER)!

  private implDescArray = [
    $r('app.string.player_impl_auto_desc'),
    $r('app.string.player_impl_system_desc'),
    $r('app.string.player_impl_wl_desc')
  ]

  private implSelectionArray: Array<SelectOption> = [
    {
      value: $r('app.string.player_impl_auto')
    },
    {
      value: $r('app.string.player_impl_system')
    },
    {
      value: $r('app.string.player_impl_wl')
    }
  ]

  @State implIndex: number = 0

  aboutToAppear(): void {
    this.implIndex = this.appPrefer.getPlayerImpl()
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
        Text($r('app.string.prefer_video'))
          .fontSize(18)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
        Blank()
        Select(this.implSelectionArray)
          .value(this.implSelectionArray[this.implIndex].value)
          .onSelect((index) => {
            this.implIndex = index
            this.appPrefer.setPlayerImpl(index)
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(48)
      .padding({
        left: CommonConstants.SPACE_16,
        right: CommonConstants.SPACE_16
      })

      Text(this.implDescArray[this.implIndex])
        .fontSize(14)
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          left: CommonConstants.SPACE_16,
          right: CommonConstants.SPACE_16
        })
    }

  }

}