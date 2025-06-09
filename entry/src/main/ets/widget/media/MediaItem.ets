import { BaseItemDto, ImageType } from "@ohpg/jellyfin"
import { Repository } from "../../data/Repository"
import { CommonConstants } from "../../pages/common/CommonConstants"
import { MediaRouter } from "../../pages/common/MediaRouter"

@Reusable
@Component
export struct MediaItem {

  @StorageLink("Repository") repository?: Repository = undefined

  @Require @State item?: BaseItemDto = undefined

  @State itemWidth: string | number = CommonConstants.FULL_PERCENT

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item']
  }

  build() {
    Column({space: CommonConstants.SPACE_8}) {
      Image(this.repository?.buildImage(this.item!, ImageType.Primary))
        .alt($r('app.media.alt'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .width(CommonConstants.FULL_PERCENT)
        .borderRadius($r('app.float.lg_border_radius'))
        .aspectRatio(0.67)

      Text(this.item?.Name)
        .maxLines(1)
        .width(CommonConstants.FULL_PERCENT)
    }
    .width(this.itemWidth)
    .onClick(() => {
      MediaRouter.openDetail(this.item!)
    })
  }

  aboutToRecycle(): void {

  }
}