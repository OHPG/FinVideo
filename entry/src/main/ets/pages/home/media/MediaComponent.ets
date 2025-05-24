import { GridAttr } from "@abner/refresh";
import { BaseItemDto, ImageType } from "@ohpg/jellyfin";
import { MediaViewModel } from "./MediaViewModel";
import { Repository } from "../../../data/Repository"
import { BreakpointTypeEnum } from "@ohpg/fin-core";
import { CommonConstants } from "../../common/CommonConstants";
import { GridRefreshView } from "@ohpg/fin-framework";
import { HomeToolBar } from "../../../widget/bar/HomeToolBar";
import { MediaListArgs } from "../../media/MediaListArgs";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/7 20:27
 * @Version V1.0
 * @Description Main
 */
@Component
export struct MediaComponent {

  private viewModel = new MediaViewModel(getContext())

  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  @Builder
  mediaItem(item: BaseItemDto, index: number) {
    MediaItem({
      item: item
    })
  }

  build() {
    Column() {
      HomeToolBar({
        title: $r('app.string.home_media')
      })

      GridRefreshView({
        source: this.viewModel,
        itemLayout: this.mediaItem,
        gridAttribute: (attr: GridAttr) => {
          attr.padding = {
            left: CommonConstants.SPACE_16,
            right: CommonConstants.SPACE_16
          }
          attr.rowsGap = CommonConstants.SPACE_12
          attr.columnsGap = CommonConstants.SPACE_12
          attr.columnsTemplate = 'repeat(auto-fit, 140)'
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

@Reusable
@Component
struct MediaItem {

  @StorageLink("Repository") repository?: Repository = undefined

  @Require @State item?: BaseItemDto = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as BaseItemDto
  }

  build() {
    Stack() {
      Image(this.repository?.buildImage(this.item!, ImageType.Primary))
        .alt($r('app.media.alt'))
        .autoResize(true)
        .objectFit(ImageFit.Cover)
        .borderRadius($r('app.float.lg_border_radius'))
        .width('100%')
        .aspectRatio(1.5)
    }
    .onClick(() => {
      let args: MediaListArgs = {
        id: this.item!.Id!,
        name: this.item!.Name!,
        type: this.item!.CollectionType!
      }
      this.getUIContext().getRouter().pushUrl({url: "pages/media/MediaListPage", params: args})
    })
  }

}