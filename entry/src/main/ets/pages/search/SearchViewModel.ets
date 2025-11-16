import { FinItem, FinItemType, LoadType } from "@ohpg/fin-core";
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
    let movieList = new Array<FinItem>()
    let seriesList = new Array<FinItem>()
    let episodeList = new Array<FinItem>()
    for (const item of items) {
      if (item.type === FinItemType.Movie) {
        movieList.push(item)
      } else if (item.type === FinItemType.Series) {
        seriesList.push(item)
      } else if (item.type === FinItemType.Episode) {
        episodeList.push(item)
      }
    }

    if (movieList.length > 0) {
      sectionList.push({
        type: FinItemType.Movie,
        items: movieList
      })
    }
    if (seriesList.length > 0) {
      sectionList.push({
        type: FinItemType.Series,
        items: seriesList
      })
    }
    if (episodeList.length > 0) {
      sectionList.push({
        type: FinItemType.Episode,
        items: episodeList
      })
    }

    this.dataSource.initData(sectionList)

  }

}