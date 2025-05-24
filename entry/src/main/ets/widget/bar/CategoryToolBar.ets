import { BaseItemDto, CollectionType } from "@ohpg/jellyfin";
import { BreakpointTypeEnum } from "@ohpg/fin-core";
import { CommonConstants } from "../../pages/common/CommonConstants";
import { MediaListArgs } from "../../pages/media/MediaListArgs";

@Reusable
@Component
export struct CategoryToolBar {

  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  @Require @State item?: BaseItemDto = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as BaseItemDto
  }

  build() {

    Row() {
      Text(this.item?.Name)
        .fontSize($r('app.float.lg_font_size'))
        .fontWeight(FontWeight.Medium)
        .fontFamily(CommonConstants.HARMONY_HEITI_MEDIUM_FONT_FAMILY)
      if (this.item?.CollectionType === CollectionType.Movies || this.item?.CollectionType === CollectionType.Tvshows) {
        Row() {
          Text($r('app.string.more'))
            .fontSize($r('app.float.md_font_size'))
            .opacity(CommonConstants.SECOND_LEVEL_OPACITY)

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .opacity(CommonConstants.THIRD_LEVEL_OPACITY)
            .fontSize($r('app.float.more_arrow_icon_height'))
        }
        .onClick(() => {
          let args: MediaListArgs = {
            id: this.item!.Id!,
            name: this.item!.Name!,
            type: this.item!.CollectionType!
          }
          this.getUIContext().getRouter().pushUrl({url: "pages/media/MediaListPage", params: args})
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