import { BaseItemDto, BaseItemKind } from "@ohpg/jellyfin"
import { CommonConstants } from "../../common/CommonConstants"
import { FavouriteViewModel } from "./FavouriteViewModel"
import { BreakpointTypeEnum } from "@ohpg/fin-core"
import { ListRefreshView } from "@ohpg/fin-framework"
import { HomeToolBar } from "../../../widget/bar/HomeToolBar"
import { CategoryToolBar } from "../../../widget/bar/CategoryToolBar"
import { EpisodeItem } from "../../../widget/media/EpisodeItem"
import { MediaItem } from "../../../widget/media/MediaItem"
import { GroupInfo } from "../../../entity/GroupInfo"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/7 20:27
 * @Version V1.0
 * @Description Main
 */
@Component
export struct FavouriteComponent {

  private viewModel = new FavouriteViewModel(getContext())

  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  @Builder
  favouriteGroupBuilder(group: GroupInfo, index: number) {
    FavouriteGroup({item: group})
  }

  build() {
    Column() {

      HomeToolBar({
        title: $r('app.string.home_favourite')
      })

      ListRefreshView({
        source: this.viewModel,
        itemLayout: this.favouriteGroupBuilder,
        listAttribute: (attr) => {
          attr.divider = {
            color: Color.Transparent,
            strokeWidth: 16
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
struct FavouriteGroup {

  @Require @State item?: GroupInfo = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as GroupInfo
  }

  build() {
    Column() {
      // title
      CategoryToolBar({
        item: this.item?.group
      })
      // list
      List({space: 8}) {
        ForEach(this.item?.items, (item: BaseItemDto) => {
          ListItem() {
            if (item.Type === BaseItemKind.Episode) {
              EpisodeItem({item: item})
            } else {
              MediaItem({item: item})
            }
          }
        })
      }
      .contentStartOffset(CommonConstants.SPACE_16)
      .contentEndOffset(CommonConstants.SPACE_16)
      .width('100%')
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  aboutToRecycle(): void {

  }

}