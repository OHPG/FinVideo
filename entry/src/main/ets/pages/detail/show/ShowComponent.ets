import { CommonConstants } from "../../common/CommonConstants"
import { ShowSeasonArgs } from "./season/ShowSeasonArgs"
import { ShowEpisodeSheet } from "../../../sheet/ShowEpisodeSheet"
import { DetailArgs } from "../DetailArgs"
import { FinItem } from "@ohpg/fin-core"
import router from "@ohos.router"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/23 12:12
 * @Version V1.0
 * @Description
 */
@Component
export struct ShowNextUp {

  @Require nextDto?: FinItem

  build() {
    Column({space: CommonConstants.SPACE_12}) {
      Text("接下来")
        .fontSize($r('sys.float.Title_S'))
      Image(this.nextDto?.image?.primary)
        .alt($r('app.media.alt'))
        .autoResize(true)
        .objectFit(ImageFit.Cover)
        .width(CommonConstants.FULL_PERCENT)
        .aspectRatio(1.5)
        .borderRadius($r('app.float.lg_border_radius'))
        .onClick(() => {
          let sheet = new ShowEpisodeSheet(this.getUIContext(), this.nextDto!)
          sheet.show()
        })
      Text(this.nextDto?.name)
    }
    .margin({
      left: CommonConstants.SPACE_16,
      right: CommonConstants.SPACE_16,
    })
    .alignItems(HorizontalAlign.Start)
  }

}

@Component
export struct ShowSeasons {

  @Prop seasonDto?: Array<FinItem> = undefined

  @Prop args: DetailArgs

  build() {
    Column({space: CommonConstants.SPACE_12}) {
      Text("季")
        .fontSize($r('sys.float.Title_S'))
        .margin({
          left: CommonConstants.SPACE_16,
          right: CommonConstants.SPACE_16
        })
      List({space: CommonConstants.SPACE_12}) {
        ForEach(this.seasonDto, (dto: FinItem) => {
          ListItem() {
            ShowSeasonItem({
              args: this.args,
              item: dto
            })
          }
        })
      }
      .contentStartOffset(CommonConstants.SPACE_16)
      .contentEndOffset(CommonConstants.SPACE_16)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.ITEM_HEIGHT)
    }
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
  }
}

@Component
@Reusable
struct ShowSeasonItem {

  @Require args?: DetailArgs

  @Require @State item?: FinItem = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as FinItem
  }

  build() {
    Column({space: CommonConstants.SPACE_8}) {
      Image(this.item?.image?.primary)
        .alt($r('app.media.alt'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .borderRadius($r('app.float.lg_border_radius'))
        .width(CommonConstants.ITEM_WIDTH)
        .aspectRatio(CommonConstants.ITEM_RATIO)
      Text(this.item?.name)
    }
    .width(CommonConstants.ITEM_WIDTH)
    .height(CommonConstants.ITEM_HEIGHT)
    .onClick(() => {
      let args: ShowSeasonArgs = {
        id: this.args!.id,
        name: this.args!.name,
        seasonId: this.item!.id!
      }
      router.push({
        url: "pages/detail/show/season/ShowSeasonPage",
        params: args
      })
    })
  }

  aboutToDisappear(): void {
  }
}