import { FinItem } from "@ohpg/fin-core"
import { MediaRouter } from "../../pages/common/MediaRouter"
import { CommonConstants } from "../../pages/common/CommonConstants"

@Reusable
@Component
export struct MediaItem {

  @Require @State item?: FinItem = undefined

  @State itemWidth: string | number = CommonConstants.FULL_PERCENT

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as FinItem
  }

  build() {
    Column({space: CommonConstants.SPACE_8}) {
      Image(this.item?.image?.primary)
        .alt($r('app.media.alt'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .width(CommonConstants.FULL_PERCENT)
        .borderRadius($r('app.float.lg_border_radius'))
        .aspectRatio(0.67)

      Text(this.item?.name)
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