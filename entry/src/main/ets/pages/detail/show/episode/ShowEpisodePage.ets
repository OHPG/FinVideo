import { BaseItemDto, ImageType } from "@ohpg/jellyfin"
import { Repository } from "../../../../data/Repository"
import { CommonConstants } from "../../../common/CommonConstants"
import { DetailOperate } from "../../DetailComponent"
import { ShowEpisodeViewModel } from "./ShowEpisodeViewModel"

@Preview
@Component
export struct ShowEpisodePage {

  @Prop storage: LocalStorage

  @State episodeDto?: BaseItemDto = undefined

  @State overview?: string | null = undefined

  @StorageLink("Repository") repository?: Repository = undefined

  private viewModel?: ShowEpisodeViewModel

  aboutToAppear(): void {
    this.viewModel = new ShowEpisodeViewModel(getContext(), this.episodeDto!)
    this.storage.setOrCreate('viewModel', this.viewModel)
  }

  build() {
    Column({space: CommonConstants.SPACE_12}) {
      Row({space: CommonConstants.SPACE_8}) {
        Image(this.episodeDto ? this.repository?.buildImage(this.episodeDto!, ImageType.Primary) : undefined)
          .id('episode_cover')
          .alt($r('app.media.alt'))
          .autoResize(true)
          .objectFit(ImageFit.Cover)
          .borderRadius($r('app.float.lg_border_radius'))
          .layoutWeight(2)
          .aspectRatio(1.5)

        Stack() {
          Column({space: CommonConstants.SPACE_8}) {
            Text(this.episodeDto?.SeriesName)
              .id('episode_name')
              .fontSize($r('sys.float.Body_L'))

            Text((this.episodeDto?.ParentIndexNumber && this.episodeDto?.IndexNumber)
              ? `S${this.episodeDto?.ParentIndexNumber}:E${this.episodeDto?.IndexNumber} - ${this.episodeDto?.Name}`
              : this.episodeDto?.Name)
              .fontSize($r('sys.float.Body_M'))

            Blank()

            DetailOperate({
              itemDto: this.episodeDto
            }, this.storage)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(3)
      }
      Text(this.episodeDto?.Overview)
        .fontSize($r('sys.float.Body_M'))
      Blank(CommonConstants.SPACE_16)
    }
    .padding(CommonConstants.SPACE_16)
  }

  aboutToDisappear(): void {

  }

}