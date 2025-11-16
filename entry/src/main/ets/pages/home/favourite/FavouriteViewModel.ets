import { FinItem, FinItemType, LoadType } from "@ohpg/fin-core";
import { ListViewModel } from "../../common/ListViewModel";
import { GroupInfo } from "../../../entity/GroupInfo";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/14 21:24
 * @Version V1.0
 * @Description
 */
export class FavouriteViewModel extends ListViewModel {

  async loadData(type: LoadType): Promise<void> {
    let includeTypeArray = [FinItemType.Movie, FinItemType.Series, FinItemType.Episode]
    let items = await this.repository.getFavourite(includeTypeArray)
    let groupMap = new Map<string, GroupInfo>()
    items.forEach((item) => {
      let groupInfo = groupMap.get(item.type!)
      if (!groupInfo) {
        let name: string
        if (item.type === FinItemType.Movie) {
          name = "电影"
        } else if (item.type === FinItemType.Series) {
          name = "电视剧"
        } else if (item.type === FinItemType.Episode) {
          name = "集"
        } else {
          name = item.type!
        }
        groupInfo = {
          type: 'Normal',
          group: {
            id: "",
            name: name,
            type: item.type,
          },
          items: new Array<FinItem>(),
          favourite: true
        }
        groupMap.set(item.type!, groupInfo)
      }
      groupInfo.items!.push(item)
    })
    let groupArray = new Array<GroupInfo>()
    includeTypeArray.forEach((type) => {
      let groupInfo = groupMap.get(type)
      if (groupInfo) {
        groupArray.push(groupInfo)
      }
    })
    this.dataSource.initData(groupArray)
  }
}