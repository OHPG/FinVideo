import { LoadType } from "@ohpg/fin-core";
import { BaseItemDto, BaseItemKind } from "@ohpg/jellyfin";
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
    let includeTypeArray = [BaseItemKind.Movie, BaseItemKind.Series, BaseItemKind.Episode]
    let items = await this.repository.loadFavourite(includeTypeArray)
    let groupMap = new Map<string, GroupInfo>()
    items.forEach((item) => {
      let groupInfo = groupMap.get(item.Type!)
      if (!groupInfo) {
        let name: string
        if (item.Type === BaseItemKind.Movie) {
          name = "电影"
        } else if (item.Type === BaseItemKind.Series) {
          name = "电视剧"
        } else if (item.Type === BaseItemKind.Episode) {
          name = "集"
        } else {
          name = item.Type!
        }
        groupInfo = {
          type: 'Normal',
          group: {
            Name: name,
          },
          items: new Array<BaseItemDto>()
        }
        groupMap.set(item.Type!, groupInfo)
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