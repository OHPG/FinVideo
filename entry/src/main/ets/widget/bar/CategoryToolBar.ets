import { GroupInfo } from "../../entity/GroupInfo";
import { CommonConstants } from "../../pages/common/CommonConstants";
import { FavouriteListArgs } from "../../pages/favourite/FavouriteListArgs";
import { MediaListArgs } from "../../pages/media/MediaListArgs";

@Reusable
@Component
export struct CategoryToolBar {

  @Require @State item?: GroupInfo = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as GroupInfo
  }

  build() {

    Row() {
      Text(this.item?.group?.name)
        .fontSize($r('app.float.lg_font_size'))
        .fontWeight(FontWeight.Medium)
        .fontFamily(CommonConstants.HARMONY_HEITI_MEDIUM_FONT_FAMILY)
      if (this.item?.type === "Normal") {
        Row() {
          Text($r('app.string.more'))
            .fontSize($r('app.float.md_font_size'))
            .opacity(CommonConstants.SECOND_LEVEL_OPACITY)

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .opacity(CommonConstants.THIRD_LEVEL_OPACITY)
            .fontSize($r('app.float.more_arrow_icon_height'))
        }
        .onClick(() => {
          if (this.item?.favourite) {
            let args: FavouriteListArgs = {
              id: this.item!.group?.id!,
              name: this.item!.group?.name!,
              type: this.item!.group?.type!
            }
            this.getUIContext().getRouter().pushUrl({url: "pages/favourite/FavouriteListPage", params: args})
          } else {
            let args: MediaListArgs = {
              id: this.item!.group?.id!,
              name: this.item!.group?.name!,
              type: this.item!.group?.collectionType!
            }
            this.getUIContext().getRouter().pushUrl({url: "pages/media/MediaListPage", params: args})
          }
        })
      }
    }
    .alignItems(VerticalAlign.Center)
    .padding({
      right: CommonConstants.SPACE_16,
      left: CommonConstants.SPACE_16,
      top: CommonConstants.SPACE_8,
      bottom: CommonConstants.SPACE_8
    })
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  aboutToRecycle(): void {
  }
}