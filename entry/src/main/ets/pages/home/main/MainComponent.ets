import { BaseItemDto } from '@ohpg/jellyfin';
import { BreakpointTypeEnum } from '@ohpg/fin-core';
import { CommonConstants } from '../../common/CommonConstants';
import { MainViewModel } from './MainViewModel';
import { ListRefreshView } from '@ohpg/fin-framework';
import { HomeToolBar } from '../../../widget/bar/HomeToolBar';
import { CategoryToolBar } from '../../../widget/bar/CategoryToolBar';
import { MediaItem } from '../../../widget/media/MediaItem';
import { EpisodeItem } from '../../../widget/media/EpisodeItem';
import { GroupInfo } from '../../../entity/GroupInfo';

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/7 20:27
 * @Version V1.0
 * @Description Main
 */
@Component
export struct MainComponent {

  private viewModel = new MainViewModel(getContext())

  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  @Builder
  private mainGroup(groupInfo: GroupInfo, index: number) {
    MainNormalGroup({
      item: groupInfo
    })
  }

  build() {
    Column() {
      HomeToolBar({
        title: $r('app.string.home_main')
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
        },
      })
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
    }
  }

  aboutToDisappear(): void {
    this.viewModel.onClear()
  }

}

@Component
@Reusable
struct MainNormalGroup {

  @Require @State item?: GroupInfo = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as GroupInfo
  }

  build() {
    Column() {
      // title
      CategoryToolBar({item: this.item?.group})
      // list
      List({space: CommonConstants.SPACE_12}) {
        ForEach(this.item?.items, (item: BaseItemDto) => {
          ListItem() {
            if (this.item?.group?.CollectionType) {
              MediaItem({item: item})
            } else {
              EpisodeItem({item: item, progress: this.item?.type === 'Continue'})
            }
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

  aboutToRecycle(): void {

  }
}