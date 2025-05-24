import { BaseItemDto, BaseItemKind, ImageType } from "@ohpg/jellyfin"
import { Repository } from "../../data/Repository"
import { CommonConstants } from "../../pages/common/CommonConstants"
import { ShowEpisodeSheet } from "../../sheet/ShowEpisodeSheet"

@Reusable
@Component
export struct EpisodeItem {

  @StorageLink("Repository") repository?: Repository = undefined

  @Require @State item?: BaseItemDto = undefined

  @State progress: boolean = false

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item']
  }

  build() {
    Column({space: CommonConstants.SPACE_8}) {
      Stack({alignContent: Alignment.Bottom}) {
        Image(this.repository?.buildImage(this.item!, ImageType.Primary))
          .alt($r('app.media.alt'))
          .autoResize(true)
          .objectFit(ImageFit.Cover)
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .borderRadius($r('app.float.lg_border_radius'))

        if (this.progress) {
          Progress({ value: this.item?.UserData?.PlayedPercentage, total: 100, type: ProgressType.Linear })
            .margin({bottom: CommonConstants.SPACE_8})
            .width('90%')
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .aspectRatio(1.5)


      if (this.item?.Type === BaseItemKind.Episode) {
        Text(this.item.SeriesName)
          .width(CommonConstants.FULL_PERCENT)
          .maxLines(1)
        Text((this.item?.ParentIndexNumber && this.item?.IndexNumber)
          ? `S${this.item.ParentIndexNumber}: E${this.item.IndexNumber} ${this.item.Name}`
          : this.item?.Name)
          .width(CommonConstants.FULL_PERCENT)
          .maxLines(1)
      } else {
        Text(this.item?.Name)
          .maxLines(1)
          .width(CommonConstants.FULL_PERCENT)
      }
    }
    .width(200)
    .onClick(() => {
      let sheet = new ShowEpisodeSheet(this.getUIContext(), this.item!)
      sheet.show()
    })
  }

  aboutToRecycle(): void {

  }
}