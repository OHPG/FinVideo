import { FinCollectionType, FinItemType, LoadType } from "@ohpg/fin-core";
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

  constructor(args: MediaListArgs, context: Context) {
    super(context)
    this.args = args
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
    let items = await this.repository.getLibraryMediaList(this.args.id, types, recursive)
    this.dataSource.initData(items)
  }

}