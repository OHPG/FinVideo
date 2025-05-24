import { BaseItemDto, BaseItemKind, ImageType } from "@ohpg/jellyfin"
import { Repository } from "../../data/Repository"
import { CommonConstants } from "../../pages/common/CommonConstants"
import { DetailArgs } from "../../pages/detail/DetailArgs"
import { router } from "@kit.ArkUI"

@Reusable
@Component
export struct MediaItem {

  @StorageLink("Repository") repository?: Repository = undefined

  @Require @State item?: BaseItemDto = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item']
  }

  build() {
    Column({space: CommonConstants.SPACE_12}) {
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
    .width(140)
    .onClick(() => {
      let path: string
      if (this.item?.Type === BaseItemKind.Movie) {
        path = 'pages/detail/movie/MoviePage'
      } else if (this.item?.Type === BaseItemKind.Series) {
        path = 'pages/detail/show/ShowPage'
      } else {
        return
      }
      let args: DetailArgs = {
        id: this.item!.Id!,
        name: this.item.Name!
      }
      router.pushUrl({url: path, params: args})
    })
  }

  aboutToRecycle(): void {

  }
}