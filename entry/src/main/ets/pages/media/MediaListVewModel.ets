import { BaseItemKind, CollectionType } from "@ohpg/jellyfin";
import { LoadType } from "@ohpg/fin-core";
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

  private lastId?: number

  constructor(args: MediaListArgs, context: Context) {
    super(context)
    this.args = args
  }

  loadData(type: LoadType): Promise<void> {
    let types: Array<BaseItemKind> = new Array()
    switch (this.args.type) {
      case CollectionType.Movies:
        types.push(BaseItemKind.Movie)
        break
      case CollectionType.Tvshows:
        types.push(BaseItemKind.Series)
        break
      default:
        break
    }
    return this.repository.loadMediaList(this.args.id, types, true)
      .then((items) => {
        this.dataSource.initData(items)
      })
  }

}