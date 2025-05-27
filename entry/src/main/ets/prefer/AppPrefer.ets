import { preferences } from "@kit.ArkData"
import { PlayerImpl } from "../player/PlayerImpl"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/9 18:36
 * @Version V1.0
 * @Description
 */
export class AppPrefer {

  public static readonly PREFER = "prefer"

  private static readonly KEY_PRIVACY_GRANT = "privacy_grant"

  private static readonly KEY_PLAYER_IMPL = "player_impl"

  private readonly preference: preferences.Preferences

  constructor(context: Context) {
    this.preference = preferences.getPreferencesSync(context, { name: "app_prefer" } )
  }

  public isPrivacyGrant(): boolean {
    if (this.preference.hasSync(AppPrefer.KEY_PRIVACY_GRANT)) {
      return this.preference.getSync(AppPrefer.KEY_PRIVACY_GRANT, false) as boolean
    }
    return false
  }

  public setPrivacyGrant(): void {
    this.preference.putSync(AppPrefer.KEY_PRIVACY_GRANT, true)
    this.preference.flush()
  }

  public getPlayerImpl(): PlayerImpl {
    if (this.preference.hasSync(AppPrefer.KEY_PLAYER_IMPL)) {
      return this.preference.getSync(AppPrefer.KEY_PLAYER_IMPL, 0) as number
    }
    return 0
  }

  public setPlayerImpl(impl: PlayerImpl) {
    this.preference.putSync(AppPrefer.KEY_PLAYER_IMPL, impl)
    this.preference.flush()
  }

}