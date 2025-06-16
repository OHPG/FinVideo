import { CommonConstants } from "@ohpg/fin-framework";
import { BaseItemKind } from "@ohpg/jellyfin";
import { SectionInfo } from "../../entity/SectionInfo";

@Component
export struct SectionToolBar {

  @Require @State item?: SectionInfo

  @State sectionTitle?: string = undefined

  aboutToAppear(): void {
    switch (this.item?.type) {
      case BaseItemKind.Movie:
        this.sectionTitle = "电影"
        break
      case BaseItemKind.Series:
        this.sectionTitle = "剧集"
        break
      case BaseItemKind.Episode:
        this.sectionTitle = "集"
        break
    }
  }

  build() {
    Text(this.sectionTitle)
      .fontSize($r('app.float.lg_font_size'))
      .fontWeight(FontWeight.Medium)
      .fontFamily(CommonConstants.HARMONY_HEITI_MEDIUM_FONT_FAMILY)
      .padding({
        right: CommonConstants.SPACE_16,
        left: CommonConstants.SPACE_16,
        top: CommonConstants.SPACE_8,
        bottom: CommonConstants.SPACE_8
      })
      .width(CommonConstants.FULL_PERCENT)
  }

}