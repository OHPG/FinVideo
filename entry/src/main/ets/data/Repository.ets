import { BaseItemDto, BaseItemKind,
  BaseItemPerson,
  CollectionType,
  ImageType,
  ItemFields,
  ItemFilter,
  ItemSortBy,
  MediaProtocol,
  MediaSourceInfo,
  PlaybackInfoResponse,
  SortOrder,
  UserItemDataDto} from "@ohpg/fin-core";
import { uri } from "@kit.ArkTS";
import { FinRepository } from "@ohpg/fin-framework";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/9 11:50
 * @Version V1.0
 * @Description Repository
 */
export class Repository extends FinRepository {

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

  public buildImage(dto: BaseItemDto, type: ImageType): string | undefined {
    let imageUri = new uri.URI(this.jellyfin.apiClient.getServerInfo()!.address)
    imageUri = imageUri.addEncodedSegment(`items/${dto.Id!}/Images/${type}`)
    return imageUri.toString()
  }

  public buildPersonImage(person: BaseItemPerson, type: ImageType): string | undefined {
    let imageUri = new uri.URI(this.jellyfin.apiClient.getServerInfo()!.address)
    imageUri = imageUri.addEncodedSegment(`items/${person.Id!}/Images/${type}`)
    return imageUri.toString()
  }

  public async getMediaList(): Promise<Array<BaseItemDto>> {
    let result = await this.jellyfin.getUserViewsApi().getUserViews({
      userId: this.activeInfo!.userInfo.userId
    })
    let groups = this.filterItem(result.Items)
    if (!groups) {
      return []
    }
    return groups
  }

  public async getLatestMedia(id?: string): Promise<Array<BaseItemDto>> {
    let result = await this.jellyfin.getUserLibraryApi().getLatestMedia({
      userId: this.activeInfo!.userInfo.userId,
      includeItemTypes: [BaseItemKind.Series, BaseItemKind.Movie],
      parentId: id,
      limit: 12
    })
    if (result) {
      return result
    }
    return []
  }

  /**
   * 查询所有媒体库
   * @returns
   */
  public async loadMedia(): Promise<Array<BaseItemDto>> {
    let result = await this.jellyfin.getItemsApi().getItems({
      userId: this.activeInfo!.userInfo.userId
    })
    let items = this.filterItem(result.Items)
    if (items) {
      return items
    }
    return []
  }

  public async loadFavourite(includeItemTypes?: Array<BaseItemKind>): Promise<Array<BaseItemDto>> {
    let result = await this.jellyfin.getItemsApi().getItems({
      userId: this.activeInfo!.userInfo.userId,
      filters: [ItemFilter.IsFavorite],
      includeItemTypes: includeItemTypes,
      fields: [ItemFields.Overview],
      recursive: true
    })
    if (result.Items) {
      return result.Items
    }
    return []
  }

  public async loadMediaList(id: string, types: Array<BaseItemKind>
    , recursive: boolean, sortBy?: Array<ItemSortBy>, sortOrder?: Array<SortOrder>): Promise<Array<BaseItemDto>> {
    let result = await this.jellyfin.getItemsApi().getItems({
      parentId: id,
      includeItemTypes: types,
      recursive: recursive,
      sortBy: sortBy,
      sortOrder: sortOrder
    })
    return result.Items!
  }

  public loadMovie(id: string): Promise<BaseItemDto> {
    return this.jellyfin.getUserLibraryApi().getItem({
      userId: this.activeInfo!.userInfo.userId,
      itemId: id
    })
  }

  public loadShow(showId: string): Promise<BaseItemDto> {
    return this.jellyfin.getUserLibraryApi().getItem({
      userId: this.activeInfo!.userInfo.userId,
      itemId: showId
    })
  }

  public getPlaybackInfo(id: string): Promise<PlaybackInfoResponse> {
    return this.jellyfin.getMediaInfoApi().getPlaybackInfo({
      userId: this.activeInfo!.userInfo.userId,
      itemId: id
    })
  }

  public loadStreamUrl(id: string, sourceId: string): Promise<string> {
    return this.jellyfin.getVideosApi().getVideoStreamUrl({
      itemId: id,
      static: true,
      mediaSourceId: sourceId
    })
  }

  public async getMediaSource(id: string, sourceInfo: MediaSourceInfo): Promise<string> {
    let url: string | undefined | null
    switch (sourceInfo.Protocol) {
      case MediaProtocol.File:
        url = await this.loadStreamUrl(id, sourceInfo.Id!)
        break
      case MediaProtocol.Http:
        url = sourceInfo.Path
        break
    }
    if (url) {
      return url
    }
    throw new Error("Source not support.")
  }

  public async searchMedia(keyword: string): Promise<Array<BaseItemDto>> {
    let result = await this.jellyfin.getItemsApi().getItems({
      userId: this.activeInfo?.userInfo.userId,
      searchTerm: keyword,
      includeItemTypes: [BaseItemKind.Movie, BaseItemKind.Series, BaseItemKind.Episode],
      recursive: true
    })
    if (result.Items) {
      return result.Items
    }
    return []
  }

  public getUserItem(id: string): Promise<UserItemDataDto> {
    return this.jellyfin.getItemsApi().getItemUserData({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

}