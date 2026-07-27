import { ActiveInfo, FinAuthResult, FinItem, FinItemData,
  FinItemType,
  FinPage,
  FinPerson, FinPersonType, FinPublicSystemInfo,
  ServerType } from "@ohpg/fin-core";
import { ClientInfo, DeviceInfo } from "@ohpg/network";
import { CollectionType, ImageType, ItemFilter, ItemSortBy,
  MediaProtocol,
  MediaStreamType,
  SortOrder,
  UserItemDataDto,
  VideoRange } from "@ohpg/emby";
import { BaseItemDto, BaseItemKind, BaseItemPerson, ItemFields, Emby } from "@ohpg/emby";
import { FinVideoApi } from "../FinVideoApi";
import { uri } from "@kit.ArkTS";
import { BaseItemDtoQueryResult } from "@ohpg/emby/src/main/ets/model/BaseItemDtoQueryResult";
import { FinItemSource } from "../../entity/FinItemSource";
import { AppConfig } from "../../config/AppConfig";
import { FinSubSource } from "../../entity/FinSubSource";
import { FinMediaTrack } from "../../entity/FinMediaTrack";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/7/6 13:50
 * @Version V1.0
 * @Description Emby api
 */
export class EmbyFinApi implements FinVideoApi {

  private readonly context: Context

  private readonly appConfig: AppConfig

  private activeInfo?: ActiveInfo

  private emby: Emby

  private embyTmp: Emby

  private lastMediaSourceId?: string

  private lastPlaySessionId?: string

  constructor(context: Context, clientInfo: ClientInfo, deviceInfo: DeviceInfo) {
    this.context = context
    this.appConfig = AppStorage.get(AppConfig.CONFIG)!
    this.emby = new Emby(clientInfo, deviceInfo)
    this.embyTmp = new Emby(clientInfo, deviceInfo)
  }

  getApiType(): ServerType {
    return ServerType.EMBY
  }

  updateAddress(address: string): void {
    this.emby.selectServer({ address: address })
  }

  updateActiveInfo(activeInfo: ActiveInfo): void {
    this.activeInfo = activeInfo
    this.emby.selectServer({ address: activeInfo.addressInfo.address })
    this.emby.selectUser({ id: activeInfo.userInfo.userId, token: activeInfo.userInfo.accessToken })
  }

  private buildImage(dto: BaseItemDto, type: ImageType): string | undefined {
    let id = dto.Id!
    let tag: string | undefined
    if (type === ImageType.Primary) {
      if (dto.Type === BaseItemKind.Season) {
        // Season 没有自己的 Primary 时，fallback 到 Series
        if (!dto.ImageTags || !dto.ImageTags[ImageType.Primary]) {
          if (!dto.SeriesId) return undefined
          id = dto.SeriesId
          tag = dto.SeriesPrimaryImageTag || undefined
        } else {
          tag = dto.ImageTags[ImageType.Primary] || undefined
        }
      } else {
        if (!dto.ImageTags || !dto.ImageTags[ImageType.Primary]) return undefined
        tag = dto.ImageTags[ImageType.Primary] || undefined
      }
    } else if (type === ImageType.Backdrop) {
      if (!dto.BackdropImageTags || dto.BackdropImageTags.length === 0) return undefined
      tag = dto.BackdropImageTags[0] || undefined
    } else if (type === ImageType.Logo) {
      if (!dto.ImageTags || !dto.ImageTags[ImageType.Logo]) return undefined
      tag = dto.ImageTags[ImageType.Logo] || undefined
    }
    let imageUri = new uri.URI(this.activeInfo!.addressInfo.address)
    imageUri = imageUri.addEncodedSegment(`Items/${id}/Images/${type}`)
    let url = imageUri.toString()
    if (tag) {
      url += `?tag=${tag}`
    }
    return url
  }

  private buildPersonImage(person: BaseItemPerson, type: ImageType): string {
    let imageUri = new uri.URI(this.activeInfo!.addressInfo.address)
    imageUri = imageUri.addEncodedSegment(`Items/${person.Id!}/Images/${type}`)
    let url = imageUri.toString()
    if (person.PrimaryImageTag) {
      url += `?tag=${person.PrimaryImageTag}`
    }
    return url
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
      seriesId: item.SeriesId || undefined,
      seasonId: item.SeasonId || undefined,
      runtimeTicks: item.RunTimeTicks ? item.RunTimeTicks / 10000 : undefined,
      productionYear: item.ProductionYear ? item.ProductionYear.toString() : undefined,
      officialRating: item.OfficialRating || undefined,
      communityRating: item.CommunityRating ? item.CommunityRating.toString() : undefined,
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
    let cur: number = result.StartIndex ?? index ?? 0
    let more: boolean = cur + finItems.length < (result.TotalRecordCount || 0)
    return { cur: cur, items: finItems, more: more }
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
    })
    return newItems
  }

  async getPublicSystemInfo(url: string): Promise<FinPublicSystemInfo> {
    this.embyTmp.selectServer({ address: url })
    let info = await this.embyTmp.getSystemApi().getPublicSystemInfo()
    return { Id: info.Id, ServerName: info.ServerName, Version: info.Version, StartupWizardCompleted: true }
  }

  public async getSystemInfo(url?: string): Promise<FinPublicSystemInfo> {
    if (url) {
      this.embyTmp.selectServer({ address: url })
    } else {
      this.embyTmp.selectServer({ address: this.activeInfo!.addressInfo.address })
    }
    this.embyTmp.selectUser({ id: this.activeInfo!.userInfo.userId, token: this.activeInfo!.userInfo.accessToken })
    let info = await this.embyTmp.getSystemApi().getSystemInfo()
    return { Id: info.Id, ServerName: info.ServerName, Version: info.Version, StartupWizardCompleted: true }
  }

  async auth(name: string, psw?: string | undefined, url?: string | undefined): Promise<FinAuthResult> {
    if (url) {
      this.embyTmp.selectServer({ address: url })
    } else {
      this.embyTmp.selectServer({ address: this.activeInfo!.addressInfo.address })
    }
    let authResult = await this.embyTmp.getUserApi().authenticateUserByName({ Username: name, Pw: psw })
    return {
      UserName: authResult.User?.Name,
      UserId: authResult.User?.Id,
      AccessToken: authResult.AccessToken
    }
  }

  async getResumeItems(): Promise<Array<FinItem>> {
    let result = await this.emby.getItemsApi().getResumeItems({
      userId: this.activeInfo!.userInfo.userId,
      includeItemTypes: [BaseItemKind.Movie, BaseItemKind.Episode],
      fields: [ItemFields.Overview],
      limit: 12,
    })
    return this.resultToFinItems(result)
  }

  async getNextUp(seriesId?: string | undefined): Promise<Array<FinItem>> {
    let result = await this.emby.getTvShowsApi().getNextUp({
      userId: this.activeInfo!.userInfo.userId,
      seriesId: seriesId,
      fields: [ItemFields.Overview],
      limit: 12
    })
    return this.resultToFinItems(result)
  }

  async getLibraryList(): Promise<FinItem[]> {
    let result = await this.emby.getUserViewsApi().getUserViews({
      userId: this.activeInfo!.userInfo.userId
    })
    let groups = this.filterItem(result.Items)
    return this.itemsToFinItems(groups)
  }

  async getItemList(id: string, types: FinItemType[], recursive: boolean, index?: number): Promise<FinPage> {
    let result = await this.emby.getItemsApi().getItems({
      userId: this.activeInfo!.userInfo.userId,
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
    let result = await this.emby.getUserLibraryApi().getLatestMedia({
      userId: this.activeInfo!.userInfo.userId,
      includeItemTypes: [BaseItemKind.Series, BaseItemKind.Movie],
      parentId: id,
      limit: 12
    })
    return this.itemsToFinItems(result)
  }

  async getMovie(id: string): Promise<FinItem> {
    let item = await this.emby.getUserLibraryApi().getItem({
      userId: this.activeInfo!.userInfo.userId,
      itemId: id
    })
    return this.itemToFinItem(item)
  }

  async getShow(id: string): Promise<FinItem> {
    let item = await this.emby.getUserLibraryApi().getItem({
      userId: this.activeInfo!.userInfo.userId,
      itemId: id
    })
    return this.itemToFinItem(item)
  }

  async getSeasons(seriesId: string): Promise<Array<FinItem>> {
    let result = await this.emby.getTvShowsApi().getSeasons({
      userId: this.activeInfo!.userInfo.userId,
      seriesId: seriesId
    })
    return this.resultToFinItems(result)
  }

  async getEpisodes(seriesId: string, seasonId?: string): Promise<Array<FinItem>> {
    let result = await this.emby.getTvShowsApi().getEpisodes({
      userId: this.activeInfo!.userInfo.userId,
      seriesId: seriesId,
      seasonId: seasonId,
      fields: [ItemFields.Overview, ItemFields.ParentId]
    })
    return this.resultToFinItems(result)
  }

  async getEpisode(episodeId: string): Promise<FinItem> {
    let item = await this.emby.getUserLibraryApi().getItem({
      userId: this.activeInfo!.userInfo.userId,
      itemId: episodeId
    })
    return this.itemToFinItem(item)
  }

  async getItemData(id: string): Promise<FinItemData> {
    let item = await this.emby.getUserLibraryApi().getItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
    return this.itemDataToFinItemData(item.UserData)!
  }

  async getFavourite(types?: FinItemType[] | undefined): Promise<FinItem[]> {
    let result = await this.emby.getItemsApi().getItems({
      userId: this.activeInfo!.userInfo.userId,
      filters: [ItemFilter.IsFavorite],
      includeItemTypes: types as ESObject,
      fields: [ItemFields.Overview],
      recursive: true
    })
    return this.resultToFinItems(result)
  }

  async getItemSource(id: string): Promise<Array<FinItemSource>> {
    let playbackInfo = await this.emby.getMediaInfoApi().postPlaybackInfo({
      userId: this.activeInfo!.userInfo.userId,
      itemId: id,
      data: {
        UserId: this.activeInfo!.userInfo.userId,
        EnableDirectPlay: true,
        EnableDirectStream: true,
        EnableTranscoding: false,
        IsPlayback: true,
        AutoOpenLiveStream: true,
        DeviceProfile: {
          MaxStreamingBitrate: 120000000,
          DirectPlayProfiles: [
            { Container: 'mp4,m4v', AudioCodec: 'aac,mp3,ac3,eac3,flac,alac,dts,opus,truehd', VideoCodec: 'h264,hevc,vp9,av1', Type: 'Video' },
            { Container: 'mkv', AudioCodec: 'aac,mp3,ac3,eac3,flac,alac,dts,opus,truehd', VideoCodec: 'h264,hevc,vp9,av1', Type: 'Video' },
            { Container: 'avi', AudioCodec: 'aac,mp3,ac3', VideoCodec: 'h264,mpeg4', Type: 'Video' },
            { Container: 'mov', AudioCodec: 'aac,mp3,ac3', VideoCodec: 'h264,hevc', Type: 'Video' },
            { Container: 'ts,mpegts', AudioCodec: 'aac,mp3,ac3,eac3,dts', VideoCodec: 'h264,hevc', Type: 'Video' },
            { Container: 'wmv,asf', AudioCodec: 'wma', VideoCodec: 'wmv3,vc1', Type: 'Video' }
          ],
          SubtitleProfiles: [
            { Format: 'srt', Method: 'External' },
            { Format: 'ass', Method: 'External' },
            { Format: 'ssa', Method: 'External' },
            { Format: 'vtt', Method: 'External' },
            { Format: 'sub', Method: 'External' },
            { Format: 'smi', Method: 'External' }
          ]
        }
      }
    })

    this.lastPlaySessionId = playbackInfo.PlaySessionId || undefined

    let results = new Array<FinItemSource>()
    let mediaSources = playbackInfo.MediaSources ?? []

    for (let source of mediaSources) {
      // 判断是否是hdr
      let sdr = true
      source.MediaStreams?.forEach((stream) => {
        if (stream.Type === MediaStreamType.Video) {
          if (stream.VideoRange) {
            sdr = stream.VideoRange !== VideoRange.Hdr
          }
        }
      })

      let url: string | undefined | null
      switch (source.Protocol) {
        case MediaProtocol.File:
          if (source.DirectStreamUrl) {
            url = this.buildDirectStreamUrl(source.DirectStreamUrl, source.AddApiKeyToDirectStreamUrl ?? false)
          } else {
            url = await this.emby.getVideosApi().getVideoStreamUrl({
              itemId: id,
              static: true,
              mediaSourceId: source.Id!,
              api_key: this.activeInfo!.userInfo.accessToken
            })
          }
          break
        case MediaProtocol.Http:
          // Http 协议的 DirectStreamUrl 是 Emby 生成的完整相对路径，直接拼 host 即可
          url = source.DirectStreamUrl
            ? this.buildDirectStreamUrl(source.DirectStreamUrl, source.AddApiKeyToDirectStreamUrl ?? false)
            : source.Path
          break
      }

      const subSources = source.MediaStreams?.filter(stream =>
        stream.Type === MediaStreamType.Subtitle && stream.IsExternal
      ).map(sub => {
        let subUrl: string;
        if (sub.Path?.startsWith('http')) {
          subUrl = sub.Path;
        } else {
          subUrl = `${this.activeInfo!.addressInfo.address}/Videos/${id}/${source.Id}/Subtitles/${sub.Index}/Stream.${sub.Codec}`;
        }
        let subSource: FinSubSource = {
          title: sub.Title || undefined,
          index: sub.Index || undefined,
          force: sub.IsForced || undefined,
          'default': sub.IsDefault,
          url: subUrl
        }
        return subSource
      });

      if (url) {
        // 记录第一个来源的 mediaSourceId 用于播放上报
        if (results.length === 0) {
          this.lastMediaSourceId = source.Id || undefined
        }
        const videoStream = source.MediaStreams?.find(s => s.Type === MediaStreamType.Video)

        // 构建轨道信息
        const tracks: FinMediaTrack[] = []
        source.MediaStreams?.forEach((stream) => {
          if (stream.Type === MediaStreamType.Video) {
            tracks.push({
              type: 'Video',
              title: stream.DisplayTitle || `${stream.Codec?.toUpperCase() ?? 'Video'}`,
              codec: stream.Codec || undefined,
              width: stream.Width ?? undefined,
              height: stream.Height ?? undefined,
              frameRate: stream.RealFrameRate ?? stream.AverageFrameRate ?? undefined,
              bitrate: stream.BitRate ?? undefined,
              videoRangeType: stream.VideoRange || undefined,
              aspectRatio: stream.AspectRatio || undefined,
              profile: stream.Profile || undefined,
              bitDepth: stream.BitDepth ?? undefined,
              pixelFormat: stream.PixelFormat || undefined,
              isDefault: stream.IsDefault ?? undefined
            })
          } else if (stream.Type === MediaStreamType.Audio) {
            tracks.push({
              type: 'Audio',
              title: stream.DisplayTitle || `${stream.Codec?.toUpperCase() ?? 'Audio'}`,
              codec: stream.Codec || undefined,
              language: stream.Language || undefined,
              bitrate: stream.BitRate ?? undefined,
              channels: stream.Channels ?? undefined,
              channelLayout: stream.ChannelLayout || undefined,
              sampleRate: stream.SampleRate ?? undefined,
              isDefault: stream.IsDefault ?? undefined
            })
          } else if (stream.Type === MediaStreamType.Subtitle) {
            tracks.push({
              type: 'Subtitle',
              title: stream.DisplayTitle || stream.Title || stream.Language || 'Subtitle',
              codec: stream.Codec || undefined,
              language: stream.Language || undefined,
              isDefault: stream.IsDefault ?? undefined,
              isExternal: stream.IsExternal ?? undefined,
              isForced: stream.IsForced ?? undefined
            })
          }
        })

        results.push({
          id: source.Id || undefined,
          name: source.Name || source.Id || id,
          url: url,
          sdr: sdr,
          sub: subSources,
          width: videoStream?.Width ?? undefined,
          height: videoStream?.Height ?? undefined,
          bitrate: source.Bitrate ?? undefined,
          videoCodec: videoStream?.Codec ?? undefined,
          tracks: tracks.length > 0 ? tracks : undefined,
          path: source.Path || undefined
        })
      }
    }

    if (results.length === 0) {
      throw new Error("Source not support.")
    }
    return results
  }

  async search(keyword: string): Promise<FinItem[]> {
    let result = await this.emby.getItemsApi().getItems({
      userId: this.activeInfo?.userInfo.userId,
      searchTerm: keyword,
      includeItemTypes: [BaseItemKind.Movie, BaseItemKind.Series, BaseItemKind.Episode],
      recursive: true
    })
    return this.resultToFinItems(result)
  }

  async getPersonItems(personId: string): Promise<FinItem[]> {
    let result = await this.emby.getItemsApi().getItems({
      userId: this.activeInfo!.userInfo.userId,
      personIds: [personId],
      includeItemTypes: [BaseItemKind.Movie, BaseItemKind.Series],
      recursive: true,
      sortBy: [ItemSortBy.SortName],
      sortOrder: [SortOrder.Ascending],
      fields: [ItemFields.Overview]
    })
    return this.resultToFinItems(result)
  }

  async getPersonDetail(personId: string): Promise<FinItem> {
    let item = await this.emby.getUserLibraryApi().getItem({
      userId: this.activeInfo!.userInfo.userId,
      itemId: personId
    })
    return this.itemToFinItem(item)
  }

  async markFavoriteItem(id: string): Promise<void> {
    await this.emby.getUserLibraryApi().markFavoriteItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  async unmarkFavoriteItem(id: string): Promise<void> {
    await this.emby.getUserLibraryApi().unmarkFavoriteItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  async markPlayedItem(id: string): Promise<void> {
    await this.emby.getPlayStateApi().markPlayedItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  async markUnplayedItem(id: string): Promise<void> {
    await this.emby.getPlayStateApi().markUnplayedItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  async onPlaybackStart(id: string): Promise<void> {
    await this.emby.getPlayStateApi().onPlaybackStart({
      itemId: id,
      mediaSourceId: this.lastMediaSourceId || id,
      playSessionId: this.lastPlaySessionId || ''
    })
  }

  async onPlaybackProgress(id: string, position: number, playing: boolean): Promise<void> {
    await this.emby.getPlayStateApi().onPlaybackProgress({
      itemId: id,
      mediaSourceId: this.lastMediaSourceId || id,
      playSessionId: this.lastPlaySessionId || '',
      positionTicks: position * 10000,
      isPaused: !playing
    })
  }

  async onPlaybackStopped(id: string, position: number): Promise<void> {
    await this.emby.getPlayStateApi().onPlaybackStopped({
      itemId: id,
      mediaSourceId: this.lastMediaSourceId || id,
      playSessionId: this.lastPlaySessionId || '',
      positionTicks: position * 10000
    })
  }

  /**
   * 将 DirectStreamUrl 补全为完整 URL，并按需追加 api_key。
   * 调用方负责在传入前处理协议相关的路径前缀（如 File 协议的 /emby）。
   */
  private buildDirectStreamUrl(directStreamUrl: string, addApiKey: boolean): string {
    let url = directStreamUrl
    if (!url.startsWith('http')) {
      url = this.activeInfo!.addressInfo.address + url
    }
    if (addApiKey && !url.includes('api_key=')) {
      const sep = url.includes('?') ? '&' : '?'
      url = url + sep + 'api_key=' + this.activeInfo!.userInfo.accessToken
    }
    return url
  }

  async release(): Promise<void> {
    this.emby.apiClient.release()
  }
}
