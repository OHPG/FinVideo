import { FinApi, FinItem } from "@ohpg/fin-core";

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