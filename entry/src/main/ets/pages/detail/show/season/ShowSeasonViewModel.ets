import { LoadType } from "@ohpg/fin-core";
import { ShowSeasonArgs } from "./ShowSeasonArgs";
import { ListViewModel } from "../../../common/ListViewModel";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/23 17:13
 * @Version V1.0
 * @Description
 */
export class ShowSeasonViewModel extends ListViewModel {

  private readonly args: ShowSeasonArgs

  constructor(context: Context, args: ShowSeasonArgs) {
    super(context)
    this.args = args
  }

  loadData(type: LoadType): Promise<void> {
    return this.repository.getEpisodes(this.args.id, this.args.seasonId)
      .then((items) => {
        this.dataSource.initData(items)
      })
  }

}