import { LoadType } from "@ohpg/fin-core";
import { RefreshDataSource } from "@abner/refresh";
import { RefreshRepository } from "@ohpg/fin-framework";
import { AppViewModel } from './AppViewModel'
/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/27 21:36
 * @Version V1.0
 * @Description
 */
export abstract class ListViewModel extends AppViewModel implements RefreshRepository {

  protected readonly dataSource = new RefreshDataSource();

  getDataSource(): RefreshDataSource {
    return this.dataSource
  }

  abstract loadData(type: LoadType): Promise<void>

}