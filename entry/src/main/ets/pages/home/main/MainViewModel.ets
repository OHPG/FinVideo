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
    try {
      let resumeItems = await this.repository.getResumeItems()
      if (resumeItems && resumeItems.length > 0) {
        groupArray.push({
          type: "Continue",
          group: {
            id: "",
            name: "继续观看"
          },
          items: resumeItems
        })
      }
    } catch (e) {
      console.error("MainViewModel", "getResumeItems failed: " + JSON.stringify(e))
    }
    try {
      let nextUpItems = await this.repository.getNextUp()
      if (nextUpItems && nextUpItems.length > 0) {
        groupArray.push({
          type: "Next",
          group: {
            id: "",
            name: "接下来"
          },
          items: nextUpItems
        })
      }
    } catch (e) {
      console.error("MainViewModel", "getNextUp failed: " + JSON.stringify(e))
    }
    try {
      let normalItems = await this.repository.getLibraryList()
      if (normalItems) {
        for (let item of normalItems) {
          try {
            let items = await this.repository.getLibraryLatestMedia(item.id)
            if (items && items.length > 0) {
              groupArray.push({
                type: "Normal",
                group: item,
                items: items
              })
            }
          } catch (e) {
            console.error("MainViewModel", "getLibraryLatestMedia failed for " + item.id + ": " + JSON.stringify(e))
          }
        }
      }
    } catch (e) {
      console.error("MainViewModel", "getLibraryList failed: " + JSON.stringify(e))
    }
    this.dataSource.initData(groupArray)
  }

  onClear(): void {

  }

}