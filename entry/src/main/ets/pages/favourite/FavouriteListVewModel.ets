import { LoadType } from "@ohpg/fin-core";
import { ListViewModel } from "../common/ListViewModel";
import { FavouriteListArgs } from "./FavouriteListArgs";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/19 22:38
 * @Version V1.0
 * @Description
 */
export class FavouriteListVewModel extends ListViewModel {

  private readonly args: FavouriteListArgs

  constructor(args: FavouriteListArgs, context: Context) {
    super(context)
    this.args = args
  }

  async loadData(type: LoadType): Promise<void> {
    let items = await this.repository.getFavourite([this.args.type!])
    this.dataSource.initData(items)
  }

}