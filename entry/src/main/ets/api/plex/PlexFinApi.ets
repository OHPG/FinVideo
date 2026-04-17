import { ActiveInfo, FinAuthResult,
  FinCollectionType,
  FinItem, FinItemData,
  FinItemType,
  FinPage,
  FinPerson, FinPersonType, FinPublicSystemInfo,
  ServerType } from "@ohpg/fin-core";
import { ClientInfo, DeviceInfo } from "@ohpg/network";
import { Plex, PlexMetadata, PlexDirectory } from "@ohpg/plex";
import { FinVideoApi } from "../FinVideoApi";
import { FinItemSource } from "../../entity/FinItemSource";
import { AppConfig } from "../../config/AppConfig";
import { FinSubSource } from "../../entity/FinSubSource";

export class PlexFinApi implements FinVideoApi {

  private readonly context: Context
  private readonly appConfig: AppConfig
  private activeInfo?: ActiveInfo
  private plex: Plex
  private plexTmp: Plex
  private lastDuration: number = 0

  constructor(context: Context, clientInfo: ClientInfo, deviceInfo: DeviceInfo) {
    this.context = context
    this.appConfig = AppStorage.get(AppConfig.CONFIG)!
    this.plex = new Plex(clientInfo, deviceInfo)
    this.plexTmp = new Plex(clientInfo, deviceInfo)
  }

  getApiType(): ServerType {
    return ServerType.PLEX
  }

  updateAddress(address: string): void {
    this.plex.selectServer({ address: address })
  }

  updateActiveInfo(activeInfo: ActiveInfo): void {
    this.activeInfo = activeInfo
    this.plex.selectServer({ address: activeInfo.addressInfo.address })
    this.plex.selectUser({ id: activeInfo.userInfo.userId, token: activeInfo.userInfo.accessToken })
  }

  private getBaseUrl(): string {
    return this.activeInfo!.addressInfo.address
  }

  private getToken(): string {
    return this.activeInfo!.userInfo.accessToken || ''
  }

  private buildImage(thumb?: string): string {
    if (!thumb) return ''
    if (thumb.startsWith('http')) return thumb
    return `${this.getBaseUrl()}${thumb}?X-Plex-Token=${this.getToken()}`
  }

  private plexTypeToFinType(type?: string): FinItemType {
    switch (type) {
      case 'movie': return FinItemType.Movie
      case 'show': return FinItemType.Series
      case 'season': return FinItemType.Season
      case 'episode': return FinItemType.Episode
      default: return type as ESObject as FinItemType
    }
  }

  private metadataToFinItem(item: PlexMetadata): FinItem {
    let finItem: FinItem = {
      id: item.ratingKey!,
      name: item.title!,
      path: '',
      type: this.plexTypeToFinType(item.type),
      originalTitle: item.originalTitle || '',
      overview: item.summary || '',
      seriesName: item.grandparentTitle || undefined,
      seasonId: item.parentRatingKey || undefined,
      runtimeTicks: item.duration || undefined,
      image: {
        primary: this.buildImage(item.thumb),
        backdrop: this.buildImage(item.art || item.grandparentArt)
      },
      data: this.buildItemData(item),
      genres: item.Genre?.map(g => g.tag!) || undefined,
      parentIndex: item.parentIndex || undefined,
      index: item.index || undefined,
      collectionType: undefined
    }

    if (item.Role) {
      let persons = new Array<FinPerson>()
      item.Role.forEach((role) => {
        persons.push({
          id: role.id?.toString() || '',
          name: role.tag!,
          role: role.role || '',
          type: 'Actor' as ESObject as FinPersonType,
          image: {
            primary: role.thumb ? this.buildImage(role.thumb) : ''
          }
        })
      })
      finItem.person = persons
    }
    return finItem
  }

  private buildItemData(item: PlexMetadata): FinItemData | undefined {
    let played = (item.viewCount || 0) > 0
    let playPercentage: number | undefined
    if (item.duration && item.viewOffset) {
      playPercentage = (item.viewOffset / item.duration) * 100
    }
    let finData: FinItemData = {
      playPercentage: playPercentage,
      playedPositionTicks: item.viewOffset || undefined,
      playCount: item.viewCount || 0,
      played: played
    }
    return finData
  }

  private directoryToFinItem(dir: PlexDirectory): FinItem {
    let finItem: FinItem = {
      id: dir.key!,
      name: dir.title!,
      path: '',
      type: FinItemType.Folder,
      originalTitle: '',
      overview: '',
      image: {
        primary: this.buildImage(dir.thumb || dir.composite),
        backdrop: this.buildImage(dir.art)
      },
      collectionType: this.mapSectionType(dir.type)
    }
    return finItem
  }

  private mapSectionType(type?: string): FinCollectionType | undefined {
    switch (type) {
      case 'movie': return FinCollectionType.Movies
      case 'show': return FinCollectionType.TvShows
      default: return undefined
    }
  }

  private metadataListToFinItems(items?: Array<PlexMetadata>): Array<FinItem> {
    let result = new Array<FinItem>()
    items?.forEach((item) => result.push(this.metadataToFinItem(item)))
    return result
  }

  async getPublicSystemInfo(url: string): Promise<FinPublicSystemInfo> {
    this.plexTmp.selectServer({ address: url })
    let resp = await this.plexTmp.getSystemApi().getIdentity()
    let mc = resp.MediaContainer
    return {
      Id: mc?.machineIdentifier,
      ServerName: mc?.friendlyName || 'Plex Server',
      Version: mc?.version,
      StartupWizardCompleted: true
    }
  }

  public async getSystemInfo(url?: string): Promise<FinPublicSystemInfo> {
    if (url) {
      this.plexTmp.selectServer({ address: url })
    } else {
      this.plexTmp.selectServer({ address: this.getBaseUrl() })
    }
    this.plexTmp.selectUser({ id: this.activeInfo!.userInfo.userId, token: this.getToken() })
    let resp = await this.plexTmp.getSystemApi().getServerInfo()
    let mc = resp.MediaContainer
    return {
      Id: mc?.machineIdentifier,
      ServerName: mc?.friendlyName,
      Version: mc?.version,
      StartupWizardCompleted: true
    }
  }

  async auth(name: string, psw?: string, url?: string): Promise<FinAuthResult> {
    if (url) {
      this.plexTmp.selectServer({ address: url })
    } else {
      this.plexTmp.selectServer({ address: this.getBaseUrl() })
    }
    // Step 1: Sign in to plex.tv with username/password to get token
    let account = await this.plexTmp.getUserApi().signIn(name, psw || '')
    let token = account.authToken || ''
    let userId = account.id?.toString() || ''
    let userName = account.username || account.title || name

    // Step 2: Verify the token works against the local server
    this.plexTmp.selectUser({ id: userId, token: token })
    await this.plexTmp.getSystemApi().getServerInfo()

    let result: FinAuthResult = {
      UserName: userName,
      UserId: userId,
      AccessToken: token
    }
    return result
  }

  async getResumeItems(): Promise<Array<FinItem>> {
    // Try /library/onDeck first
    let resp = await this.plex.getLibraryApi().getOnDeck()
    let items = resp.MediaContainer?.Metadata
    if (items && items.length > 0) {
      return this.metadataListToFinItems(items)
    }
    // Fallback: try /hubs for "Continue Watching" hub
    let hubResp = await this.plex.getLibraryApi().getHubs()
    let hubs = hubResp.MediaContainer?.Hub
    if (hubs) {
      for (let hub of hubs) {
        if (hub.context === 'hub.continueWatching' || hub.hubIdentifier === 'continueWatching') {
          return this.metadataListToFinItems(hub.Metadata)
        }
      }
    }
    return []
  }

  async getNextUp(seriesId?: string): Promise<Array<FinItem>> {
    if (seriesId) {
      // Show detail page: find next episode for this series from onDeck
      let resp = await this.plex.getLibraryApi().getOnDeck()
      let items = resp.MediaContainer?.Metadata
      if (items) {
        items = items.filter(i => i.grandparentRatingKey === seriesId)
        if (items.length > 0) {
          return this.metadataListToFinItems(items)
        }
      }
      // Fallback: find first unwatched episode
      let allResp = await this.plex.getLibraryApi().getAllLeaves(seriesId)
      let allEpisodes = allResp.MediaContainer?.Metadata
      if (allEpisodes) {
        for (let ep of allEpisodes) {
          if (!ep.viewCount || ep.viewCount === 0) {
            return this.metadataListToFinItems([ep])
          }
        }
      }
      return []
    }
    // Home page: return onDeck items WITHOUT playback progress (next episodes only)
    let resp = await this.plex.getLibraryApi().getOnDeck()
    let items = resp.MediaContainer?.Metadata
    let nextItems = items?.filter(i => !i.viewOffset || i.viewOffset === 0)
    return this.metadataListToFinItems(nextItems)
  }

  async getLibraryList(): Promise<FinItem[]> {
    let resp = await this.plex.getLibraryApi().getSections()
    let dirs = resp.MediaContainer?.Directory
    let result = new Array<FinItem>()
    dirs?.forEach((dir) => {
      if (dir.type === 'movie' || dir.type === 'show') {
        result.push(this.directoryToFinItem(dir))
      }
    })
    return result
  }

  async getItemList(id: string, types: FinItemType[], recursive: boolean, index?: number): Promise<FinPage> {
    let start = index || 0
    let size = this.appConfig.pageSize
    let resp = await this.plex.getLibraryApi().getItems(id, start, size)
    let mc = resp.MediaContainer
    let items = this.metadataListToFinItems(mc?.Metadata)
    let total = mc?.totalSize || mc?.size || items.length
    let more = start + items.length < total
    let page: FinPage = { cur: start, items: items, more: more }
    return page
  }

  async getLatestItems(id?: string): Promise<FinItem[]> {
    let resp = await this.plex.getLibraryApi().getRecentlyAdded(id, 20)
    let items = resp.MediaContainer?.Metadata || []
    let result = new Array<FinItem>()
    let seenIds = new Set<string>()
    for (let item of items) {
      if (result.length >= 12) break
      let finItem = this.metadataToFinItem(item)
      // Plex recentlyAdded returns seasons for show libraries
      // Map them back to their parent show and deduplicate
      if (item.type === 'season' && item.parentRatingKey) {
        if (seenIds.has(item.parentRatingKey)) continue
        seenIds.add(item.parentRatingKey)
        finItem.id = item.parentRatingKey
        finItem.type = FinItemType.Series
        finItem.name = item.parentTitle || finItem.name
        finItem.image = {
          primary: this.buildImage(item.parentThumb || item.thumb),
          backdrop: this.buildImage(item.art)
        }
      } else if (item.type === 'episode' && item.grandparentRatingKey) {
        if (seenIds.has(item.grandparentRatingKey)) continue
        seenIds.add(item.grandparentRatingKey)
        finItem.id = item.grandparentRatingKey
        finItem.type = FinItemType.Series
        finItem.name = item.grandparentTitle || finItem.name
        finItem.image = {
          primary: this.buildImage(item.grandparentThumb || item.thumb),
          backdrop: this.buildImage(item.grandparentArt || item.art)
        }
      } else {
        if (seenIds.has(item.ratingKey!)) continue
        seenIds.add(item.ratingKey!)
      }
      result.push(finItem)
    }
    return result
  }

  async getMovie(id: string): Promise<FinItem> {
    let resp = await this.plex.getLibraryApi().getMetadata({ ratingKey: id })
    let item = resp.MediaContainer?.Metadata?.[0]!
    return this.metadataToFinItem(item)
  }

  async getShow(id: string): Promise<FinItem> {
    let resp = await this.plex.getLibraryApi().getMetadata({ ratingKey: id })
    let item = resp.MediaContainer?.Metadata?.[0]!
    return this.metadataToFinItem(item)
  }

  async getSeasons(seriesId: string): Promise<Array<FinItem>> {
    let resp = await this.plex.getLibraryApi().getChildren({ ratingKey: seriesId })
    let result = new Array<FinItem>()
    // Plex may return seasons as Metadata or Directory
    let metadata = resp.MediaContainer?.Metadata
    if (metadata && metadata.length > 0) {
      metadata.forEach((item) => {
        if (item.ratingKey) {
          let finItem: FinItem = {
            id: item.ratingKey,
            name: item.title || '',
            path: '',
            type: FinItemType.Season,
            originalTitle: '',
            overview: item.summary || '',
            image: {
              primary: this.buildImage(item.thumb || item.parentThumb),
              backdrop: this.buildImage(item.art)
            },
            parentIndex: item.parentIndex,
            index: item.index
          }
          result.push(finItem)
        }
      })
    }
    let dirs = resp.MediaContainer?.Directory
    if (result.length === 0 && dirs) {
      dirs.forEach((dir) => {
        if (dir.ratingKey) {
          let finItem: FinItem = {
            id: dir.ratingKey,
            name: dir.title || '',
            path: '',
            type: FinItemType.Season,
            originalTitle: '',
            overview: dir.summary || '',
            image: {
              primary: this.buildImage(dir.thumb || dir.parentThumb),
              backdrop: ''
            },
            parentIndex: dir.parentIndex,
            index: dir.index
          }
          result.push(finItem)
        }
      })
    }
    return result
  }

  async getEpisodes(seriesId: string, seasonId: string): Promise<Array<FinItem>> {
    let resp = await this.plex.getLibraryApi().getChildren({ ratingKey: seasonId })
    return this.metadataListToFinItems(resp.MediaContainer?.Metadata)
  }

  async getEpisode(episodeId: string): Promise<FinItem> {
    let resp = await this.plex.getLibraryApi().getMetadata({ ratingKey: episodeId })
    let item = resp.MediaContainer?.Metadata?.[0]!
    return this.metadataToFinItem(item)
  }

  async getItemData(id: string): Promise<FinItemData> {
    let resp = await this.plex.getLibraryApi().getMetadata({ ratingKey: id })
    let item = resp.MediaContainer?.Metadata?.[0]!
    return this.buildItemData(item)!
  }

  async getFavourite(types?: FinItemType[]): Promise<FinItem[]> {
    // Plex doesn't have a direct favorites API in the same way
    // Return empty for now
    return []
  }

  async getItemSource(id: string): Promise<FinItemSource> {
    let resp = await this.plex.getLibraryApi().getMetadata({ ratingKey: id })
    let item = resp.MediaContainer?.Metadata?.[0]!
    let media = item.Media?.[0]!
    let part = media.Part?.[0]!

    let url = `${this.getBaseUrl()}${part.key}?X-Plex-Token=${this.getToken()}`

    this.lastDuration = item.duration || media.duration || 0

    // Check HDR
    let sdr = true
    part.Stream?.forEach((stream) => {
      if (stream.streamType === 1) {
        if (stream.videoRange && stream.videoRange !== 'SDR') {
          sdr = false
        }
      }
    })

    // Subtitles
    let subSources: Array<FinSubSource> | undefined
    let subs = part.Stream?.filter(s => s.streamType === 3 && s.key)
    if (subs && subs.length > 0) {
      subSources = subs.map(sub => {
        let subUrl = `${this.getBaseUrl()}${sub.key}?X-Plex-Token=${this.getToken()}`
        let subSource: FinSubSource = {
          title: sub.displayTitle || sub.title || sub.language || undefined,
          index: sub.index || undefined,
          force: sub.forced || undefined,
          default: sub.default,
          url: subUrl
        }
        return subSource
      })
    }

    let source: FinItemSource = { url: url, sdr: sdr, sub: subSources }
    return source
  }

  async search(keyword: string): Promise<FinItem[]> {
    let resp = await this.plex.getLibraryApi().search({ query: keyword })
    // Plex search returns hubs, need to extract Metadata from each hub
    let result = new Array<FinItem>()
    let metadata = resp.MediaContainer?.Metadata
    if (metadata) {
      metadata.forEach((item) => {
        if (item.type === 'movie' || item.type === 'show' || item.type === 'episode') {
          result.push(this.metadataToFinItem(item))
        }
      })
    }
    return result
  }

  async getPersonItems(_personId: string): Promise<FinItem[]> {
    // Plex 不支持按 personId 查询相关作品
    return []
  }

  async markFavoriteItem(id: string): Promise<void> {
    // Plex does not have a favorites API
  }

  async unmarkFavoriteItem(id: string): Promise<void> {
    // Plex does not have a favorites API
  }

  async markPlayedItem(id: string): Promise<void> {
    await this.plex.getPlayStateApi().scrobble(id)
  }

  async markUnplayedItem(id: string): Promise<void> {
    await this.plex.getPlayStateApi().unscrobble(id)
  }

  async onPlaybackStart(id: string): Promise<void> {
    await this.plex.getPlayStateApi().timeline({
      ratingKey: id,
      key: `/library/metadata/${id}`,
      state: 'playing',
      time: 0,
      duration: this.lastDuration
    })
  }

  async onPlaybackProgress(id: string, position: number, playing: boolean): Promise<void> {
    await this.plex.getPlayStateApi().timeline({
      ratingKey: id,
      key: `/library/metadata/${id}`,
      state: playing ? 'playing' : 'paused',
      time: position,
      duration: this.lastDuration
    })
  }

  async onPlaybackStopped(id: string, position: number): Promise<void> {
    await this.plex.getPlayStateApi().timeline({
      ratingKey: id,
      key: `/library/metadata/${id}`,
      state: 'stopped',
      time: position,
      duration: this.lastDuration
    })
  }

  async release(): Promise<void> {
    this.plex.apiClient.release()
  }
}
