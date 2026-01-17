import { window } from '@kit.ArkUI'
import { CommonConstants } from '../common/CommonConstants'
import { MediaListArgs } from './MediaListArgs'
import { MediaListVewModel } from './MediaListVewModel'
import { GridRefreshView } from '@ohpg/fin-framework'
import { ToolBar } from '@ohpg/fin-framework'
import { MediaItem } from '../../widget/media/MediaItem'
import { FinItem } from '@ohpg/fin-core'
import { SortMenu } from '../../widget/menu/SortMenu'

@Entry
@Component
struct MediaListPage {

  private args = this.getUIContext().getRouter().getParams() as MediaListArgs

  private viewModel = new MediaListVewModel(this.args, this.getUIContext().getHostContext()!)

  @StorageProp('currentAvoidArea') currentAvoidArea?: window.AvoidArea = undefined

  @Builder
  mediaListView(info: Object, index: number) {
    MediaItem({item: info as FinItem})
  }

  build() {
    Column() {

      ToolBar({
        title: this.args.name
      }) {
        SortMenu()
      }

      GridRefreshView({
        source: this.viewModel,
        gridAttribute: (attr) => {
          attr.padding = {
            left: CommonConstants.SPACE_16,
            right: CommonConstants.SPACE_16,
            bottom: px2vp(this.currentAvoidArea?.bottomRect.height)
          }
          attr.rowsGap = CommonConstants.SPACE_16
          attr.columnsGap = CommonConstants.SPACE_12
          attr.columnsTemplate = 'repeat(auto-fit, 140)'
          attr.width = CommonConstants.FULL_PERCENT
          attr.height = CommonConstants.FULL_PERCENT
        },
        itemLayout: this.mediaListView
      })
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
    }
  }

}