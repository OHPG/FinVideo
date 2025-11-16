import { CircleShape, window } from '@kit.ArkUI'
import { Repository } from '../../../../data/Repository'
import { ShowEpisodeSheet } from '../../../../sheet/ShowEpisodeSheet'
import { ListRefreshView } from '@ohpg/fin-framework'
import { CommonConstants } from '../../../common/CommonConstants'
import { ShowSeasonArgs } from './ShowSeasonArgs'
import { ShowSeasonViewModel } from './ShowSeasonViewModel'
import { ToolBar } from '@ohpg/fin-framework'
import { FinItem } from '@ohpg/fin-core'

@Entry
@Component
struct ShowSeasonPage {

  private args = this.getUIContext().getRouter().getParams() as ShowSeasonArgs

  private viewModel = new ShowSeasonViewModel(getContext(), this.args)

  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  @Builder
  seasonItemBuilder(item: FinItem, index: number) {
    SeasonItem({item: item})
  }

  build() {
    Column() {
      ToolBar({
        title: this.args.name
      })

      ListRefreshView({
        source: this.viewModel,
        itemLayout: this.seasonItemBuilder,
        listAttribute: (attr) => {
          attr.divider = {
            color: Color.Transparent,
            strokeWidth: CommonConstants.SPACE_12
          }
          attr.width = CommonConstants.FULL_PERCENT
          attr.height = CommonConstants.FULL_PERCENT
          attr.contentEndOffset = px2vp(this.avoidArea?.bottomRect.height)
        }
      })
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

}

@Component
@Reusable
export struct SeasonItem {

  @StorageLink("Repository") repository?: Repository = undefined

  @State isSheetShow: boolean = false

  @Require @State item?: FinItem = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as FinItem
  }

  build() {
    RelativeContainer(){
      Image(this.item?.image?.primary)
        .id("episode_cover")
        .alt($r('app.media.alt'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .width(160)
        .height(90)
        .borderRadius($r('app.float.lg_border_radius'))
        .alignRules({
          center: {
            anchor: "__container__",
            align: VerticalAlign.Center
          },
          left: {
            anchor: "__container__",
            align: HorizontalAlign.Start
          }
        })

      SymbolGlyph($r('sys.symbol.checkmark'))
        .fontColor([Color.Red])
        .fontSize($r('sys.float.Subtitle_S'))
        .padding(CommonConstants.SPACE_4)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .visibility(this.item?.data?.played ? Visibility.Visible : Visibility.Hidden)
        .alignRules({
          top: {
            anchor: "episode_cover",
            align: VerticalAlign.Top
          },
          right: {
            anchor: "episode_cover",
            align: HorizontalAlign.End
          }
        })
        .clipShape(new CircleShape({
          width: CommonConstants.FULL_PERCENT,
          height: CommonConstants.FULL_PERCENT
        }))
        .margin(CommonConstants.SPACE_4)

      Text(this.item?.index + ". " + this.item?.name)
        .id("episode_name")
        .fontSize($r('sys.float.Body_L'))
        .maxLines(1)
        .margin({
          left: CommonConstants.SPACE_12
        })
        .alignRules({
          left: {
            anchor: "episode_cover",
            align: HorizontalAlign.End
          },
          right: {
            anchor: "__container__",
            align: HorizontalAlign.End
          },
          top: {
            anchor: "episode_cover",
            align: VerticalAlign.Top
          }
        })
      Text(this.item?.overview)
        .id("episode_overview")
        .fontSize($r('sys.float.Body_S'))
        .maxLines(5)
        .textAlign(TextAlign.Start)
        .align(Alignment.TopStart)
        .textOverflow({
          overflow: TextOverflow.Ellipsis
        })
        .margin({
          left: CommonConstants.SPACE_12,
          top: CommonConstants.SPACE_4
        })
        .alignRules({
          left: {
            anchor: "episode_cover",
            align: HorizontalAlign.End
          },
          right: {
            anchor: "__container__",
            align: HorizontalAlign.End
          },
          top: {
            anchor: "episode_name",
            align: VerticalAlign.Bottom
          },
          bottom: {
            anchor: "__container__",
            align: VerticalAlign.Bottom
          }
        })
    }
    .padding({
      left: CommonConstants.SPACE_16,
      right: CommonConstants.SPACE_16,
    })
    .width(CommonConstants.FULL_PERCENT)
    .height(100)
    .onClick(() => {
      let sheet = new ShowEpisodeSheet(this.getUIContext(), this.item!)
      sheet.show()
    })
  }
}