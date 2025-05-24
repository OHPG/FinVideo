import { LoadType } from "@ohpg/fin-core";
import { SimpleRepository } from "@ohpg/fin-framework";
import { DetailViewModel } from "../DetailViewModel";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/19 22:26
 * @Version V1.0
 * @Description Movie
 */
export class MovieViewModel extends DetailViewModel implements SimpleRepository {

  async loadData(type: LoadType): Promise<Object> {
    // await this.getUserItem()
    try {
      let movieDto = await this.repository.loadMovie(this.args.id)
      this.userItemDto = movieDto.UserData
      return movieDto
    } catch (error) {
      throw error as Error
    }
  }

}