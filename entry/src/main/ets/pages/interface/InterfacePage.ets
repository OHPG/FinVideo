import { FinPageSize } from '@ohpg/fin-core'
import { CommonConstants, ToolBar } from '@ohpg/fin-framework'
import { AppConfig } from '../../config/AppConfig'
import { AppPrefer } from '../../prefer/AppPrefer'

@Entry
@Component
struct InterfacePage {

  @StorageLink(AppConfig.CONFIG) appConfig?: AppConfig = undefined

  private appPrefer: AppPrefer = AppStorage.get(AppPrefer.PREFER)!

  private pageSizeArray: Array<FinPageSize> = [
    FinPageSize.Size_25,
    FinPageSize.Size_50,
    FinPageSize.Size_100
  ]

  private pageSizeSelectionArray: Array<SelectOption> = [
    {
      value: FinPageSize.Size_25.toString()
    },
    {
      value: FinPageSize.Size_50.toString()
    },
    {
      value: FinPageSize.Size_100.toString()
    }
  ]

  @State pageSizeIndex: number = 1

  aboutToAppear(): void {
    let pageSize = this.appPrefer.getPageSize()
    this.pageSizeIndex = this.pageSizeArray.findIndex((value) => value === pageSize)
  }

  build() {

    Column({space: CommonConstants.SPACE_8}) {
      ToolBar({
        title: $r('app.string.prefer_interface')
      })

      Row({space: CommonConstants.SPACE_8}) {
        SymbolGlyph($r('sys.symbol.flipping_page_fill'))
          .fontSize(24)
          .fontColor([$r('sys.color.ohos_id_color_text_primary')])
        Text($r('app.string.interface_page_size'))
          .fontSize(18)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
        Blank()
        Select(this.pageSizeSelectionArray)
          .value(this.pageSizeSelectionArray[this.pageSizeIndex].value)
          .onSelect((index) => {
            this.pageSizeIndex = index
            let pageSize = this.pageSizeArray.findIndex((value) => value === index)
            this.appPrefer.setPageSize(pageSize)
            this.appConfig!.pageSize = pageSize
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(48)
      .padding({
        left: CommonConstants.SPACE_16,
        right: CommonConstants.SPACE_16
      })
    }
  }

}