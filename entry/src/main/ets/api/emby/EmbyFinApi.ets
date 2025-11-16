import { ActiveInfo, FinAuthResult, FinItem, FinItemData,
  FinItemType,
  FinPage,
  FinPublicSystemInfo, ServerType } from "@ohpg/fin-core";
import { ClientInfo, DeviceInfo } from "@ohpg/network";
import { FinItemSource } from "../../entity/FinItemSource";
import { FinPlaybackInfo } from "../../entity/FinPlaybackInfo";
import { FinVideoApi } from "../FinVideoApi";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/7/6 13:50
 * @Version V1.0
 * @Description Emby api
 */
export class EmbyFinApi implements FinVideoApi {

  private readonly context: Context

  constructor(context: Context, clientInfo: ClientInfo, deviceInfo: DeviceInfo) {
    this.context = context
  }

  getItemList(id: string, types: FinItemType[], recursive: boolean, index?: number): Promise<FinPage> {
    throw new Error("Method not implemented.");
  }

  getMovie(id: string): Promise<FinItem> {
    throw new Error("Method not implemented.");
  }

  getShow(id: string): Promise<FinItem> {
    throw new Error("Method not implemented.");
  }

  getItemSource(id: string): Promise<FinItemSource> {
    throw new Error("Method not implemented.");
  }

  getFavourite(types?: FinItemType[] | undefined): Promise<FinItem[]> {
    throw new Error("Method not implemented.");
  }

  getLibraryList(): Promise<FinItem[]> {
    throw new Error("Method not implemented.");
  }

  getLatestItems(id?: string | undefined): Promise<FinItem[]> {
    throw new Error("Method not implemented.");
  }

  getApiType(): ServerType {
    throw new Error("Method not implemented.");
  }

  updateAddress(address: string): void {
    throw new Error("Method not implemented.");
  }

  updateActiveInfo(activeInfo: ActiveInfo): void {
    throw new Error("Method not implemented.");
  }

  getSystemInfo(url?: string | undefined): Promise<FinPublicSystemInfo> {
    throw new Error("Method not implemented.");
  }

  auth(name: string, psw?: string | undefined, url?: string | undefined): Promise<FinAuthResult> {
    throw new Error("Method not implemented.");
  }

  release(): Promise<void> {
    throw new Error("Method not implemented.");
  }

  getResumeItems(): Promise<FinItem[]> {
    throw new Error("Method not implemented.");
  }

  getNextUp(seriesId?: string | undefined): Promise<FinItem[]> {
    throw new Error("Method not implemented.");
  }

  getSeasons(seriesId: string): Promise<FinItem[]> {
    throw new Error("Method not implemented.");
  }

  getEpisodes(seriesId: string, seasonId: string): Promise<FinItem[]> {
    throw new Error("Method not implemented.");
  }

  getEpisode(episodeId: string): Promise<FinItem> {
    throw new Error("Method not implemented.");
  }

  getPublicSystemInfo(url: string): Promise<FinPublicSystemInfo> {
    throw new Error("Method not implemented.");
  }

  authenticateUserByName(name: string, psw?: string | undefined): Promise<FinAuthResult> {
    throw new Error("Method not implemented.");
  }

  getItemData(id: string): Promise<FinItemData> {
    throw new Error("Method not implemented.");
  }

  search(keyword: string): Promise<FinItem[]> {
    throw new Error("Method not implemented.");
  }

  markFavoriteItem(id: string): Promise<void> {
    throw new Error("Method not implemented.");
  }

  unmarkFavoriteItem(id: string): Promise<void> {
    throw new Error("Method not implemented.");
  }

  markPlayedItem(id: string): Promise<void> {
    throw new Error("Method not implemented.");
  }

  markUnplayedItem(id: string): Promise<void> {
    throw new Error("Method not implemented.");
  }

  onPlaybackStart(id: string): Promise<void> {
    throw new Error("Method not implemented.");
  }

  onPlaybackProgress(id: string, position: number, playing: boolean): Promise<void> {
    throw new Error("Method not implemented.");
  }

  onPlaybackStopped(id: string, position: number): Promise<void> {
    throw new Error("Method not implemented.");
  }
}