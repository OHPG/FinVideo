import { FinCollectionType, FinItemType, FinPage, LoadType } from "@ohpg/fin-core";
import { ListViewModel } from "../common/ListViewModel";
import { MediaListArgs } from "./MediaListArgs";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/19 22:38
 * @Version V1.0
 * @Description
 */
export class MediaListVewModel extends ListViewModel {

  private readonly args: MediaListArgs

  private lastPage?: FinPage

  constructor(args: MediaListArgs, context: Context) {
    super(context)
    this.args = args
  }

  hasMore(): boolean {
    return this.lastPage?.more ? true : false
  }

  async loadData(type: LoadType): Promise<void> {
    let types: Array<FinItemType> = new Array()
    let recursive = true
    switch (this.args.type) {
      case FinCollectionType.Movies:
        types.push(FinItemType.Movie)
        break
      case FinCollectionType.TvShows:
        types.push(FinItemType.Series)
        break
      default:
        recursive = false
        break
    }
    if (type !== "More") {
      this.lastPage = undefined
    }
    let page = await this.repository.getLibraryMediaList(this.args.id
      , types
      , recursive
      , this.lastPage ? this.lastPage.cur + this.lastPage.items.length : 0)
    if (type === "More") {
      this.dataSource.pushDataArray(page.items)
    } else {
      this.dataSource.initData(page.items)
    }
    this.lastPage = page
  }

}