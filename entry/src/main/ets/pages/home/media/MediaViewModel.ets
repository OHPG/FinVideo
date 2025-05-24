import { LoadType } from "@ohpg/fin-core";
import { ListViewModel } from "../../common/ListViewModel";
/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/13 21:56
 * @Version V1.0
 * @Description
 */
@Observed
export class MediaViewModel extends ListViewModel {

  loadData(type: LoadType): Promise<void> {
    return this.repository.loadMedia()
      .then((items) => {
        this.dataSource.initData(items)
      })
  }

}