import { FinItem, LoadType } from '@ohpg/fin-core'
import { SimpleRepository } from '@ohpg/fin-framework'
import { DetailViewModel } from '../DetailViewModel'
import { DetailArgs } from '../DetailArgs'

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/21 22:11
 * @Version V1.0
 * @Description 电影详情页 ViewModel
 */
export class MovieViewModel extends DetailViewModel implements SimpleRepository {

  constructor(context: Context, args: DetailArgs) {
    super(context, args)
  }

  async loadData(type: LoadType): Promise<Object> {
    // 并发加载电影信息和版本列表
    const sourcesPromise = this.loadSources()
    let movieDto = await this.repository.getMovie(this.args.id)
    this.userItemDto = movieDto.data!
    await sourcesPromise
    return movieDto
  }

}
