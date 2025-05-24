import { router } from "@kit.ArkUI"
import { BaseItemDto, BaseItemKind, BaseItemPerson, ImageType, PersonKind } from "@ohpg/jellyfin"
import { CommonConstants } from "../common/CommonConstants"
import { DetailViewModel } from "./DetailViewModel"
import { Repository } from "../../data/Repository"
import LazyDataSource from "../common/LazyDataSource"
import { PlayerArgs } from "../player/PlayerArgs"
import { BreakpointSystem } from "@ohpg/fin-core"

@Component
export struct DetailOperate {

  @LocalStorageLink("viewModel") viewModel?: DetailViewModel = undefined

  @Link itemDto: BaseItemDto

  @State collecting: boolean = false

  @State collected: boolean = false

  @State finishing: boolean = false

  @State finished: boolean = false

  aboutToAppear(): void {
    if (this.viewModel) {
      this.finished = this.viewModel.isFinished()
      this.collected = this.viewModel.isFavourite()
    }
  }

  build() {
    Row({space: CommonConstants.SPACE_8}) {
      Button({type: ButtonType.Capsule}) {
        SymbolGlyph($r('sys.symbol.play_fill'))
          .fontColor([$r('sys.color.font_on_primary')])
          .fontSize($r('sys.float.Title_M'))
      }
      .id('episode_play')
      .width(80)
      .height(32)
      .onClick(() => {
        this.playOrNot()
      })

      Blank()

      Button({type: ButtonType.Circle}) {
        if (this.finishing) {
          SymbolGlyph($r('sys.symbol.loading'))
            .fontSize($r('sys.float.Title_M'))
        } else {
          SymbolGlyph($r('sys.symbol.checkmark'))
            .fontColor([this.finished ? Color.Red : Color.Gray])
            .fontSize($r('sys.float.Title_M'))
        }
      }
      .id('episode_finish')
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .enabled(!this.finishing)
      .padding(CommonConstants.SPACE_4)
      .onClick(() => {
        this.finishOrNot()
      })

      Button({type: ButtonType.Circle}) {
        if (this.collecting) {
          SymbolGlyph($r('sys.symbol.loading'))
            .fontSize($r('sys.float.Title_M'))
        } else {
          SymbolGlyph(this.collected ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
            .fontColor([this.collected ? Color.Red : Color.Gray])
            .fontSize($r('sys.float.Title_M'))
        }
      }
      .id('episode_collect')
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .enabled(!this.collecting)
      .padding(CommonConstants.SPACE_4)
      .onClick(() => {
        this.collectOrNot()
      })
    }
  }

  private playOrNot() {
    let args: PlayerArgs = {
      id: this.itemDto!.Id!,
      name: this.itemDto!.Name!,
      type: this.itemDto!.Type!
    }
    router.pushUrl({url: "pages/player/PlayerPage", params: args})
  }

  private finishOrNot() {
    this.finishing = true
    this.viewModel?.finishOrNot()
      .then((finished) => {
        this.finishing = false
        this.finished = finished
        this.itemDto!.UserData!.Played = finished
      })
      .catch((error: Error) => {
        this.finishing = false
      })
  }

  private collectOrNot() {
    this.collecting = true
    this.viewModel?.favouriteOrNot()
      .then((collected) => {
        this.collecting = false
        this.collected = collected
        this.itemDto!.UserData!.IsFavorite = collected
      })
      .catch((error: Error) => {
        this.collecting = false
      })
  }

  aboutToDisappear(): void {

  }

}

@Component
export struct DetailCover {

  @StorageLink("Repository") repository?: Repository = undefined

  @Prop itemDto: BaseItemDto

  @StorageProp(BreakpointSystem.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_SM

  @StorageProp(BreakpointSystem.CURRENT_HEIGHT_BREAKPOINT) currentHeightBreakpoint: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM

  build() {
    Image(this.repository?.buildImage(this.itemDto, ImageType.Backdrop))
      .alt($r('app.media.alt'))
      .objectFit(ImageFit.Cover)
      .autoResize(true)
      .width(CommonConstants.FULL_PERCENT)
      .aspectRatio(this.currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM ? 1.5 : 3)
  }

}

@Component
export struct DetailHeader {

  @StorageLink("Repository") repository?: Repository = undefined

  @Prop itemDto: BaseItemDto

  @State collecting: boolean = false

  @State collected: boolean = false

  @State finishing: boolean = false

  @State finished: boolean = false

  aboutToAppear(): void {

  }

  build() {
    Column({space: CommonConstants.SPACE_12}) {

      Text(this.itemDto.Name)
        .fontSize($r('sys.float.Title_M'))

      Row({space: CommonConstants.SPACE_8}) {
        Text(this.itemDto.ProductionYear?.toString())

        Text(Math.round(((this.itemDto.RunTimeTicks!) / 600000000)) + "min")

        Text(this.itemDto.OfficialRating)

        Text(this.itemDto.CommunityRating?.toString())

      }

      Row() {
        Text(this.itemDto.MediaSources?.[0].MediaStreams?.[0].DisplayTitle)
      }

      if (this.itemDto.Type === BaseItemKind.Movie) {
        DetailOperate({
          itemDto: this.itemDto
        })
      }

      Text(this.itemDto.Overview)

      Row({space: CommonConstants.SPACE_8}) {
        Text("风格")
        Text(this.itemDto.Genres?.join(","))
      }

      Row({space: CommonConstants.SPACE_8}) {
        Text("导演")
        Text(this.itemDto.People?.filter((people) => {
          return people.Type === PersonKind.Director
        })?.map((person) => {
          return person.Name
        })?.join(","))
      }

      Row({space: CommonConstants.SPACE_8}) {
        Text("作者")
        Text(this.itemDto.People?.filter((people) => {
          return people.Type === PersonKind.Writer
        })?.map((people) => {
          return people.Name
        }).join(","))
      }
    }
    .padding({
      left: CommonConstants.SPACE_16,
      right: CommonConstants.SPACE_16
    })
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
  }

  aboutToDisappear(): void {

  }

}

@Component
export struct DetailFooter {

  @Require itemDto?: BaseItemDto

  private personDataSource: LazyDataSource<BaseItemPerson> = new LazyDataSource();

  aboutToAppear(): void {
    if (this.itemDto?.People) {
      this.personDataSource.appendArrayData(this.itemDto.People)
    }
  }

  build() {
    Column({space: CommonConstants.SPACE_12}) {
      Text("演职人员")
        .fontSize($r('sys.float.Title_S'))
        .margin({
          left: CommonConstants.SPACE_16
        })

      List({space: CommonConstants.SPACE_12}) {
        LazyForEach(this.personDataSource, (person: BaseItemPerson, index) => {
          ListItem() {
            PersonItem({item: person})
          }
        })
      }
      .contentStartOffset(CommonConstants.SPACE_16)
      .contentEndOffset(CommonConstants.SPACE_16)
      .listDirection(Axis.Horizontal)
      .width(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .height(220)
    }
    .alignItems(HorizontalAlign.Start)
  }

  aboutToDisappear(): void {

  }

}

@Reusable
@Component
struct PersonItem {

  @StorageLink("Repository") repository?: Repository = undefined

  @Require @State item?: BaseItemPerson = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item']
  }

  build() {
    Column() {
      Image(this.repository?.buildPersonImage(this.item!, ImageType.Primary))
        .alt($r('app.media.alt'))
        .borderRadius($r('app.float.lg_border_radius'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .width(120)
        .height(180)
      Text(this.item?.Name)
        .maxLines(1)
        .ellipsisMode(EllipsisMode.END)
        .height(20)
      Text(this.item?.Role)
        .maxLines(1)
        .ellipsisMode(EllipsisMode.END)
        .height(20)
    }
    .alignItems(HorizontalAlign.Start)
    .width(120)
    .height(220)
  }

}
