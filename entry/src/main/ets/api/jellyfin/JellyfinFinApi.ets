import { ActiveInfo,
  FinAuthResult,
  FinItem,
  FinItemData,
  FinItemType,
  FinPage,
  FinPerson, FinPersonType, FinPublicSystemInfo,
  ServerType } from "@ohpg/fin-core";
import { ClientInfo, DeviceInfo } from "@ohpg/network";
import { CollectionType, ImageType, ItemFilter, ItemSortBy,
  MediaProtocol,
  MediaStreamType,
  SortOrder, UserItemDataDto,
  VideoRange,
  VideoRangeType } from "@ohpg/jellyfin";
import { BaseItemDto, BaseItemKind, BaseItemPerson, ItemFields, Jellyfin } from "@ohpg/jellyfin";
import { FinVideoApi } from "../FinVideoApi";
import { uri } from "@kit.ArkTS";
import { BaseItemDtoQueryResult } from "@ohpg/jellyfin/src/main/ets/model/BaseItemDtoQueryResult";
import { FinItemSource } from "../../entity/FinItemSource";
import { AppConfig } from "../../config/AppConfig";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/7/6 13:49
 * @Version V1.0
 * @Description jellyfin api
 */
export class JellyfinFinApi implements FinVideoApi {

  private readonly context: Context

  private readonly appConfig: AppConfig

  private readonly emptyArray = []

  private activeInfo?: ActiveInfo

  /**
   * Jellyfin api tmp
   */
  private jellyfin: Jellyfin

  /**
   * Jellyfin api tmp
   */
  protected jellyfinTmp: Jellyfin

  constructor(context: Context, clientInfo: ClientInfo, deviceInfo: DeviceInfo) {
    this.context = context
    this.appConfig = AppStorage.get(AppConfig.CONFIG)!
    this.jellyfin = new Jellyfin(clientInfo, deviceInfo)
    this.jellyfinTmp = new Jellyfin(clientInfo, deviceInfo)
  }

  getApiType(): ServerType {
    return ServerType.JELLYFIN
  }

  updateAddress(address: string): void {
    this.jellyfin.selectServer({address: address})
  }

  updateActiveInfo(activeInfo: ActiveInfo): void {
    this.activeInfo = activeInfo
    this.jellyfin.selectServer({address: activeInfo.addressInfo.address})
    this.jellyfin.selectUser({id: activeInfo.userInfo.userId, token: activeInfo.userInfo.accessToken})
  }

  private buildImage(dto: BaseItemDto, type: ImageType): string {
    let imageUri = new uri.URI(this.activeInfo!.addressInfo.address)
    let id = dto.Id!
    if (dto.Type === BaseItemKind.Season) {
      if (!dto.ImageTags || Object.keys(dto.ImageTags).length <= 0) {
        id = dto.SeriesId!
      }
    }
    imageUri = imageUri.addEncodedSegment(`items/${id}/Images/${type}`)
    return imageUri.toString()
  }

  private buildPersonImage(person: BaseItemPerson, type: ImageType): string {
    let imageUri = new uri.URI(this.activeInfo!.addressInfo.address)
    imageUri = imageUri.addEncodedSegment(`items/${person.Id!}/Images/${type}`)
    return imageUri.toString()
  }

  private itemDataToFinItemData(itemData?: UserItemDataDto): FinItemData | undefined {
    if (!itemData) return undefined
    let finItemData: FinItemData = {
      rating: itemData.Rating!,
      playPercentage: itemData.PlayedPercentage!,
      unplayedItemCount: itemData.UnplayedItemCount!,
      playedPositionTicks: itemData.PlaybackPositionTicks
        ? itemData.PlaybackPositionTicks / 10000
        : undefined,
      playCount: itemData.PlayCount!,
      isFavorite: itemData.IsFavorite,
      likes: itemData.Likes!,
      lastPlayDate: itemData.LastPlayedDate!,
      played: itemData.Played
    }
    return finItemData
  }

  private itemToFinItem(item: BaseItemDto): FinItem {
    let finItem: FinItem = {
      id: item.Id!,
      name: item.Name!,
      path: item.Path!,
      type: item.Type! as ESObject as FinItemType,
      originalTitle: item.OriginalTitle!,
      overview: item.Overview!,
      seriesName: item.SeriesName || undefined,
      seasonId: item.SeasonId || undefined,
      runtimeTicks: item.RunTimeTicks ? item.RunTimeTicks / 10000 : undefined,
      image: {
        primary: this.buildImage(item, ImageType.Primary),
        backdrop: this.buildImage(item, ImageType.Backdrop)
      },
      data: this.itemDataToFinItemData(item.UserData),
      genres: item.Genres || undefined,
      parentIndex: item.ParentIndexNumber || undefined,
      index: item.IndexNumber || undefined,
      collectionType: item.CollectionType ? item.CollectionType as ESObject : undefined
    }

    // people
    if (item.People) {
      let finPerson = new Array<FinPerson>()
      item.People?.forEach((person) => {
        finPerson.push({
          id: person.Id!,
          name: person.Name!,
          role: person.Role!,
          type: person.Type as ESObject as FinPersonType,
          image: {
            primary: this.buildPersonImage(person, ImageType.Primary)
          }
        })
      })
      finItem.person = finPerson
    }
    return finItem
  }

  private itemsToFinItems(items?: Array<BaseItemDto>): Array<FinItem> {
    let finItems = new Array<FinItem>()
    items?.forEach((item) => finItems.push(this.itemToFinItem(item)))
    return finItems
  }

  private resultToFinItems(result: BaseItemDtoQueryResult): Array<FinItem> {
    let finItems = new Array<FinItem>()
    result.Items?.forEach((item) => finItems.push(this.itemToFinItem(item)))
    return finItems
  }

  private resultToFinPage(result: BaseItemDtoQueryResult, index?: number): FinPage {
    let finItems = new Array<FinItem>()
    result.Items?.forEach((item) => finItems.push(this.itemToFinItem(item)))
    let cur: number = result.StartIndex ? result.StartIndex : 0
    let more: boolean = cur + finItems.length < (result.TotalRecordCount || 0) - 1
    return {cur: cur, items: finItems, more: more}
  }

  private filterItem(items?: Array<BaseItemDto> | null): Array<BaseItemDto> | undefined {
    let newItems: Array<BaseItemDto> | undefined
    items?.forEach((item) => {
      let type = item.CollectionType
      if (type == CollectionType.Tvshows
        || type === CollectionType.Movies
        || type === undefined) {
        if (newItems == undefined) {
          newItems = new Array()
        }
        newItems.push(item)
      }
    }
    )
    return newItems
  }

  async getPublicSystemInfo(url: string): Promise<FinPublicSystemInfo> {
    this.jellyfinTmp.selectServer({address: url})
    let info = await this.jellyfinTmp.getSystemApi().getPublicSystemInfo()
    return {Id: info.Id, ServerName: info.ServerName, Version: info.Version, StartupWizardCompleted: info.StartupWizardCompleted}
  }

  public async getSystemInfo(url?: string): Promise<FinPublicSystemInfo> {
    if (url) {
      this.jellyfinTmp.selectServer({address: url})
    } else {
      this.jellyfinTmp.selectServer({address: this.activeInfo!.addressInfo.address})
    }
    this.jellyfinTmp.selectUser({id: this.activeInfo!.userInfo.userId, token: this.activeInfo!.userInfo.accessToken})
    let info = await this.jellyfinTmp.getSystemApi().getSystemInfo()
    return {Id: info.Id, ServerName: info.ServerName, Version: info.Version, StartupWizardCompleted: info.StartupWizardCompleted}
  }

  async auth(name: string, psw?: string | undefined, url?: string | undefined): Promise<FinAuthResult> {
    if (url) {
      this.jellyfinTmp.selectServer({address: url})
    } else {
      this.jellyfinTmp.selectServer({address: this.activeInfo!.addressInfo.address})
    }
    let authResult = await this.jellyfinTmp.getUserApi().authenticateUserByName({Username: name, Pw: psw})
    return { UserName: authResult.User?.Name
    , UserId: authResult.User?.Id
    , AccessToken: authResult.AccessToken}
  }

  async getResumeItems(): Promise<Array<FinItem>> {
    let result = await this.jellyfin.getItemsApi().getResumeItems({
      userId: this.activeInfo!.userInfo.userId,
      includeItemTypes: [BaseItemKind.Movie, BaseItemKind.Episode],
      fields: [ItemFields.Overview],
      limit: 12,
    })
    return this.resultToFinItems(result)
  }

  async getNextUp(seriesId?: string | undefined): Promise<Array<FinItem>> {
    let result = await this.jellyfin.getTvShowsApi().getNextUp({
      userId: this.activeInfo!.userInfo.userId,
      seriesId: seriesId,
      enableResumable: false,
      fields: [ItemFields.Overview],
      limit: 12
    })
    return this.resultToFinItems(result)
  }

  async getLibraryList(): Promise<FinItem[]> {
    // let result = await this.jellyfin.getItemsApi().getItems({
    //   userId: this.activeInfo!.userInfo.userId
    // })
    let result = await this.jellyfin.getUserViewsApi().getUserViews({
      userId: this.activeInfo!.userInfo.userId
    })
    let groups = this.filterItem(result.Items)
    return this.itemsToFinItems(groups)
  }

  async getItemList(id: string, types: FinItemType[], recursive: boolean, index?: number): Promise<FinPage> {
    let result = await this.jellyfin.getItemsApi().getItems({
      parentId: id,
      includeItemTypes: types as ESObject,
      recursive: recursive,
      sortBy: [this.appConfig.sortBy as ESObject as ItemSortBy],
      sortOrder: [this.appConfig.sortOrder as ESObject as SortOrder],
      startIndex: index || 0,
      limit: this.appConfig.pageSize
    })
    return this.resultToFinPage(result, index)
  }

  async getLatestItems(id?: string | undefined): Promise<FinItem[]> {
    let result = await this.jellyfin.getUserLibraryApi().getLatestMedia({
      userId: this.activeInfo!.userInfo.userId,
      includeItemTypes: [BaseItemKind.Series, BaseItemKind.Movie],
      parentId: id,
      limit: 12
    })
    return this.itemsToFinItems(result)
  }

  async getMovie(id: string): Promise<FinItem> {
    let item = await this.jellyfin.getUserLibraryApi().getItem({
      userId: this.activeInfo!.userInfo.userId,
      itemId: id
    })
    return this.itemToFinItem(item)
  }

  async getShow(id: string): Promise<FinItem> {
    let item = await this.jellyfin.getUserLibraryApi().getItem({
      userId: this.activeInfo!.userInfo.userId,
      itemId: id
    })
    return this.itemToFinItem(item)
  }

  async getSeasons(seriesId: string): Promise<Array<FinItem>> {
    let result = await this.jellyfin.getTvShowsApi().getSeasons({
      userId: this.activeInfo!.userInfo.userId,
      seriesId: seriesId
    })
    return this.resultToFinItems(result)
  }

  async getEpisodes(seriesId: string, seasonId: string): Promise<Array<FinItem>> {
    let result = await this.jellyfin.getTvShowsApi().getEpisodes({
      userId: this.activeInfo!.userInfo.userId,
      seriesId: seriesId,
      seasonId: seasonId,
      fields: [ItemFields.Overview, ItemFields.ParentId]
    })
    return this.resultToFinItems(result)
  }

  async getEpisode(episodeId: string): Promise<FinItem> {
    let item = await this.jellyfin.getUserLibraryApi().getItem({
      userId: this.activeInfo!.userInfo.userId,
      itemId: episodeId
    })
    return this.itemToFinItem(item)
  }

  async getItemData(id: string): Promise<FinItemData> {
    let itemData = await this.jellyfin.getItemsApi().getItemUserData({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
    return this.itemDataToFinItemData(itemData)!
  }

  async getFavourite(types?: FinItemType[] | undefined): Promise<FinItem[]> {
    let result = await this.jellyfin.getItemsApi().getItems({
      userId: this.activeInfo!.userInfo.userId,
      filters: [ItemFilter.IsFavorite],
      includeItemTypes: types as ESObject,
      fields: [ItemFields.Overview],
      recursive: true
    })
    return this.resultToFinItems(result)
  }

  async getItemSource(id: string): Promise<FinItemSource> {

    let playbackInfo = await this.jellyfin.getMediaInfoApi().getPlaybackInfo({
      userId: this.activeInfo!.userInfo.userId,
      itemId: id
    })

    // 目前只支持首个
    let source = playbackInfo.MediaSources?.[0]!

    // 判断是否是hdr
    let sdr = true
    source.MediaStreams?.forEach((source) => {
      if (source.Type === MediaStreamType.Video) {
        if (source.VideoRangeType) {
          sdr = source.VideoRangeType === VideoRangeType.Sdr
            || source.VideoRangeType == VideoRangeType.Unknown
        } else if (source.VideoRange) {
          sdr = source.VideoRange !== VideoRange.Hdr
        }
      }
    })

    let url: string | undefined | null
    switch (source.Protocol) {
      case MediaProtocol.File:
        url = await this.jellyfin.getVideosApi().getVideoStreamUrl({
          itemId: id,
          static: true,
          mediaSourceId: id
        })
        break
      case MediaProtocol.Http:
        url = source.Path
        break
    }
    if (url) {
      return {url: url, sdr: sdr}
    }
    throw new Error("Source not support.")
  }

  async search(keyword: string): Promise<FinItem[]> {
    let result = await this.jellyfin.getItemsApi().getItems({
      userId: this.activeInfo?.userInfo.userId,
      searchTerm: keyword,
      includeItemTypes: [BaseItemKind.Movie, BaseItemKind.Series, BaseItemKind.Episode],
      recursive: true
    })
    return this.resultToFinItems(result)
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

  async release(): Promise<void> {
    this.jellyfin.apiClient.release()
  }
}