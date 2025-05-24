import { LoadType } from "@ohpg/fin-core";
import { GroupInfo } from "../../../entity/GroupInfo";
import { ListViewModel } from "../../common/ListViewModel";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/12 21:42
 * @Version V1.0
 * @Description
 */
export class MainViewModel extends ListViewModel {

  constructor(context: Context) {
    super(context)
  }

  async loadData(type: LoadType): Promise<void> {
    let groupArray = new Array<GroupInfo>()
    let resumeItems = await this.repository.getResumeItems()
    if (resumeItems && resumeItems.length > 0) {
      groupArray.push({
        type: "Continue",
        group: {
          Name: "继续观看"
        },
        items: resumeItems
      })
    }
    let nextUpItems = await this.repository.getNextUp()
    if (nextUpItems && nextUpItems.length > 0) {
      groupArray.push({
        type: "Next",
        group: {
          Name: "接下来"
        },
        items: nextUpItems
      })
    }
    let normalItems = await this.repository.getMediaList()
    if (normalItems) {
      for (let item of normalItems) {
        let items = await this.repository.getLatestMedia(item.Id)
        if (items && items.length > 0) {
          groupArray.push({
            type: "Normal",
            group: item,
            items: items
          })
        }
      }
    }
    this.dataSource.initData(groupArray)
  }

  onClear(): void {

  }

}