import { FinItem } from "@ohpg/fin-core";
import { BaseItemKind, ItemFields, Jellyfin } from "@ohpg/jellyfin";
import { FinVideoApi } from "./FinVideoApi";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/7/6 13:49
 * @Version V1.0
 * @Description jellyfin api
 */
export class JellyfinFinApi implements FinVideoApi {

  private readonly context: Context

  private readonly emptyArray = []

  /**
   * Jellyfin api tmp
   */
  private jellyfin: Jellyfin

  /**
   * Jellyfin api tmp
   */
  protected jellyfinTmp: Jellyfin

  constructor(context: Context) {
    this.context = context
    this.jellyfin = new Jellyfin()
  }

  async getPublicSystemInfo(url: string): Promise<FinPublicSystemInfo> {

  }

  authenticateUserByName(name: string, psw?: string | undefined): Promise<FinAuthResult> {

  }

  async getResumeItems(): Promise<Array<FinItem>> {
    let result = await this.jellyfin.getItemsApi().getResumeItems({
      userId: this.activeInfo!.userInfo.userId,
      includeItemTypes: [BaseItemKind.Movie, BaseItemKind.Episode],
      fields: [ItemFields.Overview],
      limit: 12,
    })
    if (result.Items) {
      return result.Items
    }
    return this.emptyArray
  }

  async getNextUp(seriesId?: string | undefined): Promise<Array<FinItem>> {
    let result = await this.jellyfin.getTvShowsApi().getNextUp({
      userId: this.activeInfo!.userInfo.userId,
      seriesId: seriesId,
      enableResumable: false,
      fields: [ItemFields.Overview],
      limit: 12
    })
    if (result.Items) {
      return result.Items
    }
    return []
  }

  async getSeasons(seriesId: string): Promise<Array<FinItem>> {
    let result = await this.jellyfin.getTvShowsApi().getSeasons({
      userId: this.activeInfo!.userInfo.userId,
      seriesId: seriesId
    })
    if (result.Items) {
      return result.Items
    }
    return []
  }

  async getEpisodes(seriesId: string, seasonId: string): Promise<Array<FinItem>> {
    let result = await this.jellyfin.getTvShowsApi().getEpisodes({
      userId: this.activeInfo!.userInfo.userId,
      seriesId: seriesId,
      seasonId: seasonId,
      fields: [ItemFields.Overview, ItemFields.ParentId]
    })
    if (result.Items) {
      return result.Items
    }
    return []
  }

  async getEpisode(episodeId: string): Promise<FinItem> {
    let item = await this.jellyfin.getUserLibraryApi().getItem({
      userId: this.activeInfo!.userInfo.userId,
      itemId: episodeId
    })

  }

  async markFavoriteItem(id: string): Promise<void> {
    await this.jellyfin.getUserLibraryApi().markFavoriteItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  async unmarkFavoriteItem(id: string): Promise<void> {
    await this.jellyfin.getUserLibraryApi().unmarkFavoriteItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  async markPlayedItem(id: string): Promise<void> {
    await this.jellyfin.getPlayStateApi().markPlayedItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  async markUnplayedItem(id: string): Promise<void> {
    await this.jellyfin.getPlayStateApi().markUnplayedItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  async onPlaybackStart(id: string): Promise<void> {
    await this.jellyfin.getPlayStateApi().onPlaybackStart({itemId: id})
  }

  async onPlaybackProgress(id: string, position: number, playing: boolean): Promise<void> {
    await this.jellyfin.getPlayStateApi().onPlaybackProgress({itemId: id, positionTicks: position, isPaused: !playing})
  }

  async onPlaybackStopped(id: string, position: number): Promise<void> {
    await this.jellyfin.getPlayStateApi().onPlaybackStopped({itemId: id, positionTicks: position})
  }


}