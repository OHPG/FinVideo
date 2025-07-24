import { FinVideoApi } from "./FinVideoApi";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/7/6 13:50
 * @Version V1.0
 * @Description Emby api
 */
export class EmbyFinApi implements FinVideoApi {

  private readonly context: Context

  constructor(context: Context) {
    this.context = context
  }

  async getPublicSystemInfo(url: string): Promise<FinPublicSystemInfo> {

  }

  authenticateUserByName(name: string, psw?: string | undefined): Promise<FinAuthResult> {

  }

  async markFavoriteItem(id: string): Promise<void> {

  }

  async unmarkFavoriteItem(id: string): Promise<void> {

  }

  async markPlayedItem(id: string): Promise<void> {

  }

  async markUnplayedItem(id: string): Promise<void> {

  }

  async onPlaybackStart(id: string): Promise<void> {

  }

  async onPlaybackProgress(id: string, position: number, playing: boolean): Promise<void> {

  }

  async onPlaybackStopped(id: string, position: number): Promise<void> {

  }
}