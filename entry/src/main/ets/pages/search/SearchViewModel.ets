import { LoadType } from "@ohpg/fin-core";
import { BaseItemDto, BaseItemKind } from "@ohpg/jellyfin";
import { SectionInfo } from "../../entity/SectionInfo";
import { ListViewModel } from "../common/ListViewModel";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/28 21:14
 * @Version V1.0
 * @Description
 */
export class SearchViewModel extends ListViewModel {

  private readonly word: string

  constructor(context: Context, word: string) {
    super(context)
    this.word = word
  }

  async loadData(type: LoadType): Promise<void> {
    let items = await this.repository.searchMedia(this.word)
    let sectionList = new Array<SectionInfo>()
    let movieList = new Array<BaseItemDto>()
    let seriesList = new Array<BaseItemDto>()
    let episodeList = new Array<BaseItemDto>()
    for (const item of items) {
      if (item.Type === BaseItemKind.Movie) {
        movieList.push(item)
      } else if (item.Type === BaseItemKind.Series) {
        seriesList.push(item)
      } else if (item.Type === BaseItemKind.Episode) {
        episodeList.push(item)
      }
    }

    if (movieList.length > 0) {
      sectionList.push({
        type: BaseItemKind.Movie,
        items: movieList
      })
    }
    if (seriesList.length > 0) {
      sectionList.push({
        type: BaseItemKind.Series,
        items: seriesList
      })
    }
    if (episodeList.length > 0) {
      sectionList.push({
        type: BaseItemKind.Episode,
        items: episodeList
      })
    }

    this.dataSource.initData(sectionList)

  }

}