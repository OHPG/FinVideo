import { LoadType } from "@ohpg/fin-core";
import { SimpleRepository } from "@ohpg/fin-framework";
import { DetailViewModel } from "../DetailViewModel";
import { ShowInfo } from "./ShowInfo";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/21 22:11
 * @Version V1.0
 * @Description
 */
export class ShowViewModel extends DetailViewModel implements SimpleRepository {

  async loadData(type: LoadType): Promise<Object> {
    let show = await this.repository.loadShow(this.args.id)
    let info: ShowInfo = {
      show: show
    }
    let nextUps = await this.repository.getNextUp(this.args.id)
    let seasons = await this.repository.getSeasons(this.args.id)
    if (nextUps && nextUps.length > 0) {
      info.nextUp = nextUps[0]
    }
    info.seasons = seasons
    return info
  }

}