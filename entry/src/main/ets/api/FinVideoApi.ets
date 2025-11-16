import { FinItem, FinItemData, FinItemType, FinPage } from "@ohpg/fin-core";
import { FinApi } from "@ohpg/fin-framework";
import { FinItemSource } from "../entity/FinItemSource";
import { FinPlaybackInfo } from "../entity/FinPlaybackInfo";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/7/6 23:17
 * @Version V1.0
 * @Description Video Fin Api
 */
export interface FinVideoApi extends FinApi {

  /**
   * 获取恢复播放列表
   * @returns
   */
  getResumeItems(): Promise<Array<FinItem>>

  /**
   * 获取继续播放列表
   * @param seriesId
   * @returns
   */
  getNextUp(seriesId?: string): Promise<Array<FinItem>>

  /**
   * 获取媒体库列表
   * @returns
   */
  getLibraryList(): Promise<Array<FinItem>>

  /**
   * 获取最近
   * @param id
   * @returns
   */
  getLatestItems(id?: string): Promise<Array<FinItem>>

  /**
   * 获取媒体列表
   * @param id
   * @param types
   * @returns
   */
  getItemList(id: string, types: Array<FinItemType>, recursive: boolean, index?: number): Promise<FinPage>

  /**
   * 获取电影
   * @param id
   * @returns
   */
  getMovie(id: string): Promise<FinItem>

  /**
   * 获取剧集
   * @param id
   * @returns
   */
  getShow(id: string): Promise<FinItem>

  /**
   * 获取季信息
   * @param seriesId
   * @returns
   */
  getSeasons(seriesId: string): Promise<Array<FinItem>>

  /**
   * 获取季的剧集列表
   * @param seriesId
   * @param seasonId
   * @returns
   */
  getEpisodes(seriesId: string, seasonId: string): Promise<Array<FinItem>>

  /**
   * 获取集的信息
   * @param episodeId
   * @returns
   */
  getEpisode(episodeId: string): Promise<FinItem>

  /**
   * 获取item的数据
   * @param id
   * @returns
   */
  getItemData(id: string): Promise<FinItemData>

  /**
   * 获取媒体数据源
   * @param id
   * @param sourceInfo
   * @returns
   */
  getItemSource(id: string): Promise<FinItemSource>

  /**
   * 获取收藏
   * @param types
   * @returns
   */
  getFavourite(types?: Array<FinItemType>): Promise<Array<FinItem>>

  /**
   * 搜索
   * @param keyword
   * @returns
   */
  search(keyword: string): Promise<Array<FinItem>>

  /**
   * 播放开始
   * @param id
   * @returns
   */
  onPlaybackStart(id: string): Promise<void>

  /**
   * 播放进度
   * @param id
   * @param position
   * @param playing
   * @returns
   */
  onPlaybackProgress(id: string, position: number, playing: boolean): Promise<void>

  /**
   * 播放停止
   * @param id
   * @param position
   * @returns
   */
  onPlaybackStopped(id: string, position: number): Promise<void>

}