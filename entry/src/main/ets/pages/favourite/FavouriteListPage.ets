import { window } from '@kit.ArkUI'
import { CommonConstants } from '../common/CommonConstants'
import { FavouriteListVewModel } from './FavouriteListVewModel'
import { GridRefreshView } from '@ohpg/fin-framework'
import { MediaItem } from '../../widget/media/MediaItem'
import { FavouriteListArgs } from './FavouriteListArgs'
import { ToolBar } from '@ohpg/fin-framework'
import { FinItem, FinItemType } from '@ohpg/fin-core'
import { EpisodeItem } from '../../widget/media/EpisodeItem'

@Entry
@Component
struct FavouriteListPage {

  private args = this.getUIContext().getRouter().getParams() as FavouriteListArgs

  private viewModel = new FavouriteListVewModel(this.args, this.getUIContext().getHostContext()!)

  @StorageProp('currentAvoidArea') currentAvoidArea?: window.AvoidArea = undefined

  @Builder
  mediaListView(info: Object, index: number) {
    if ((info as FinItem).type === FinItemType.Episode) {
      EpisodeItem({item: info as FinItem})
    } else {
      MediaItem({item: info as FinItem})
    }
  }

  build() {
    Column() {

      ToolBar({
        title: this.args.name
      })

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