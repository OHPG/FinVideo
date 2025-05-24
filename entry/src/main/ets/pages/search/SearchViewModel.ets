import { LoadType } from "@ohpg/fin-core";
import { ListViewModel } from "../common/ListViewModel";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/28 21:14
 * @Version V1.0
 * @Description
 */
export class SearchViewModel extends ListViewModel {

  loadData(type: LoadType): Promise<void> {
    return this.repository.searchMedia("")
      .then((arr) => {

      })
  }

}