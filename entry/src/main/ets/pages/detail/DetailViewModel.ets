import { FinItemData, LoadType } from '@ohpg/fin-core'
import { SimpleRepository } from '@ohpg/fin-framework'
import { AppViewModel } from '../common/AppViewModel'
import { DetailArgs } from './DetailArgs'
import { FinItemSource } from '../../entity/FinItemSource'

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/19 23:20
 * @Version V1.0
 * @Description 详情页 ViewModel 基类
 */
export class DetailViewModel extends AppViewModel implements SimpleRepository {

  public args: DetailArgs

  public userItemDto?: FinItemData

  /** 媒体版本列表 */
  public sources?: Array<FinItemSource>

  /** 当前选中的版本索引 */
  public selectedSourceIndex: number = 0

  constructor(context: Context, args: DetailArgs) {
    super(context)
    this.args = args
  }

  async loadData(type: LoadType): Promise<Object> {
    return this.userItemDto!
  }

  // ─── 版本管理 ──────────────────────────────────────────────────────────────

  /**
   * 加载媒体版本列表
   */
  public async loadSources(): Promise<void> {
    try {
      this.sources = await this.repository.getMediaSource(this.args.id)
    } catch (_e) {
      this.sources = undefined
    }
  }

  /**
   * 获取版本列表
   */
  public getSources(): Array<FinItemSource> | undefined {
    return this.sources
  }

  /**
   * 是否有多个版本
   */
  public hasMultipleSources(): boolean {
    return this.sources != undefined && this.sources.length > 1
  }

  /**
   * 获取当前选中的版本
   */
  public getSelectedSource(): FinItemSource | undefined {
    if (this.sources && this.sources.length > 0) {
      return this.sources[this.selectedSourceIndex]
    }
    return undefined
  }

  /**
   * 获取当前选中的版本 ID
   */
  public getSelectedSourceId(): string | undefined {
    return this.getSelectedSource()?.id
  }

  /**
   * 获取当前选中的版本索引
   */
  public getSelectedSourceIndex(): number {
    return this.selectedSourceIndex
  }

  /**
   * 设置当前选中的版本索引
   */
  public setSelectedSourceIndex(index: number): void {
    this.selectedSourceIndex = index
  }

  // ─── 用户数据 ──────────────────────────────────────────────────────────────

  /**
   * 获取用户媒体数据
   */
  public async getUserItem(): Promise<FinItemData> {
    let userItemDto = await this.repository.getItemData(this.args.id)
    this.userItemDto = userItemDto
    return userItemDto
  }

  /**
   * 是否已播放完成
   */
  public isFinished(): boolean {
    return this.userItemDto?.played ?? false
  }

  /**
   * 标记已播放/未播放
   */
  public async finishOrNot(): Promise<boolean> {
    if (this.isFinished()) {
      await this.repository.markUnplayedItem(this.args.id)
      this.userItemDto!.played = false
      return false
    } else {
      await this.repository.markPlayedItem(this.args.id)
      this.userItemDto!.played = true
      return true
    }
  }

  /**
   * 是否已收藏
   */
  public isFavourite(): boolean {
    return this.userItemDto?.isFavorite ?? false
  }

  /**
   * 收藏/取消收藏
   */
  public async favouriteOrNot(): Promise<boolean> {
    if (this.isFavourite()) {
      await this.repository.unmarkFavoriteItem(this.args.id)
      this.userItemDto!.isFavorite = false
      return false
    } else {
      await this.repository.markFavoriteItem(this.args.id)
      this.userItemDto!.isFavorite = true
      return true
    }
  }

}
