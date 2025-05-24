import { BaseItemDto, ImageType } from "@ohpg/jellyfin"
import { CommonConstants } from "../../common/CommonConstants"
import { Repository } from "../../../data/Repository"
import { ShowSeasonArgs } from "./season/ShowSeasonArgs"
import router from "@ohos.router"
import { DetailArgs } from "../DetailArgs"
import { ShowEpisodeSheet } from "../../../sheet/ShowEpisodeSheet"
import { BreakpointSystem } from "@ohpg/fin-core"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/23 12:12
 * @Version V1.0
 * @Description
 */
@Component
export struct ShowNextUp {

  @StorageLink("Repository") repository?: Repository = undefined

  @Require nextDto?: BaseItemDto

  build() {
    Column({space: CommonConstants.SPACE_12}) {
      Text("接下来")
        .fontSize($r('sys.float.Title_S'))
      Image(this.repository?.buildImage(this.nextDto!, ImageType.Primary))
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
      Text(this.nextDto?.Name)
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

  @Prop seasonDto?: Array<BaseItemDto> = undefined

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
        ForEach(this.seasonDto, (dto: BaseItemDto) => {
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

  @StorageLink("Repository") repository?: Repository = undefined

  @Require args?: DetailArgs

  @Require @State item?: BaseItemDto = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item']
  }

  build() {
    Column() {
      Image(this.repository?.buildImage(this.item!, ImageType.Primary))
        .alt($r('app.media.alt'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .borderRadius($r('app.float.lg_border_radius'))
        .width(CommonConstants.ITEM_WIDTH)
        .aspectRatio(CommonConstants.ITEM_RATIO)
      Text(this.item?.Name)
    }
    .width(CommonConstants.ITEM_WIDTH)
    .height(CommonConstants.ITEM_HEIGHT)
    .onClick(() => {
      let args: ShowSeasonArgs = {
        id: this.args!.id,
        name: this.args!.name,
        seasonId: this.item!.Id!
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