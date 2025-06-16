import router from '@ohos.router'
import { ListRefreshView, ToolBar } from '@ohpg/fin-framework'
import { CommonConstants } from '../common/CommonConstants'
import { SearchArgs } from './SearchArgs'
import { SearchViewModel } from './SearchViewModel'
import { SectionInfo } from '../../entity/SectionInfo'
import { BaseItemDto, BaseItemKind } from '@ohpg/jellyfin'
import { SectionToolBar } from '../../widget/bar/SectionToolBar'
import LazyDataSource from '../common/LazyDataSource'
import { MediaItem } from '../../widget/media/MediaItem'
import { EpisodeItem } from '../../widget/media/EpisodeItem'
import { window } from '@kit.ArkUI'

@Entry
@Component
struct SearchPage {

  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  private args: SearchArgs = router.getParams() as SearchArgs

  private viewModel = new SearchViewModel(getContext(), this.args.word)

  @Builder
  private mainGroup(sectionInfo: SectionInfo, index: number) {
    if (sectionInfo.type === BaseItemKind.Episode) {
      SectionLand({item: sectionInfo})
    } else {
      SectionPo({item: sectionInfo})
    }
  }

  build() {
    Column() {
      ToolBar({
        title: this.args.word
      })
      ListRefreshView({
        source: this.viewModel,
        itemLayout: this.mainGroup,
        listAttribute: (attr) => {
          attr.divider = {
            color: Color.Transparent,
            strokeWidth: CommonConstants.SPACE_12
          }
          attr.width = CommonConstants.FULL_PERCENT
          attr.height = CommonConstants.FULL_PERCENT
          attr.contentEndOffset = px2vp(this.avoidArea?.bottomRect.height)
        },
      })
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

}

@Component
struct SectionPo {

  @Require @State item?: SectionInfo = undefined

  private itemData = new LazyDataSource<BaseItemDto>()

  aboutToAppear(): void {
    this.itemData.dataArray = this.item?.items!
  }

  build() {
    Column() {
      SectionToolBar({item: this.item})
      List({space: CommonConstants.SPACE_12}) {
        LazyForEach(this.itemData, (item: BaseItemDto) => {
            ListItem() {
              MediaItem({item: item, itemWidth: 140})
            }
        })
      }
      .contentStartOffset(CommonConstants.SPACE_16)
      .contentEndOffset(CommonConstants.SPACE_16)
      .width(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .width(CommonConstants.FULL_PERCENT)
  }

}

@Component
struct SectionLand {

  @Require @State item?: SectionInfo = undefined

  private itemData = new LazyDataSource<BaseItemDto>()

  aboutToAppear(): void {
    this.itemData.dataArray = this.item?.items!
  }

  build() {
    Column() {
      SectionToolBar({item: this.item})
      List({space: CommonConstants.SPACE_12}) {
        LazyForEach(this.itemData, (item: BaseItemDto) => {
          ListItem() {
            EpisodeItem({item: item})
          }
        })
      }
      .contentStartOffset(CommonConstants.SPACE_16)
      .contentEndOffset(CommonConstants.SPACE_16)
      .width(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .width(CommonConstants.FULL_PERCENT)
  }

}