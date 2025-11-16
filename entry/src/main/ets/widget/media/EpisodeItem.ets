import { FinItem, FinItemType } from "@ohpg/fin-core"
import { CommonConstants } from "../../pages/common/CommonConstants"
import { ShowEpisodeSheet } from "../../sheet/ShowEpisodeSheet"

@Reusable
@Component
export struct EpisodeItem {

  @Require @State item?: FinItem = undefined

  @State progress: boolean = false

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as FinItem
  }

  build() {
    Column({space: CommonConstants.SPACE_8}) {
      Stack({alignContent: Alignment.Bottom}) {
        Image(this.item?.image?.primary)
          .alt($r('app.media.alt'))
          .autoResize(true)
          .objectFit(ImageFit.Cover)
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .borderRadius($r('app.float.lg_border_radius'))

        if (this.progress) {
          Progress({ value: this.item?.data?.playPercentage, total: 100, type: ProgressType.Linear })
            .margin({bottom: CommonConstants.SPACE_8})
            .width('90%')
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .aspectRatio(1.5)


      if (this.item?.type === FinItemType.Episode) {
        Text(this.item.seriesName)
          .width(CommonConstants.FULL_PERCENT)
          .maxLines(1)
        Text((this.item?.parentIndex && this.item?.index)
          ? `S${this.item.parentIndex}: E${this.item.index} ${this.item.name}`
          : this.item?.name)
          .width(CommonConstants.FULL_PERCENT)
          .maxLines(1)
      } else {
        Text(this.item?.name)
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