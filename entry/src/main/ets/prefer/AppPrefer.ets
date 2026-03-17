import { preferences } from "@kit.ArkData"
import { FinPageSize, FinSortBy, FinSortOrder } from "@ohpg/fin-core"
import { avSession } from "@kit.AVSessionKit"

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

  private static readonly KEY_PLAYER_VO = "player_vo"

  private static readonly KEY_PLAYER_LOOP_MODE = "player_loop_mode"

  private static readonly KEY_PLAYER_BACK_PLAY = "player_back_play"

  private static readonly KEY_SORT_ORDER = "sort_order"

  private static readonly KEY_SORT_BY = "sort_by"

  private static readonly KEY_PAGE_SIZE = "page_size"

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

  public getPlayerVo(): number {
    if (this.preference.hasSync(AppPrefer.KEY_PLAYER_VO)) {
      return this.preference.getSync(AppPrefer.KEY_PLAYER_VO, 0) as number
    }
    return 1
  }

  public setPlayerVo(vo: number) {
    this.preference.putSync(AppPrefer.KEY_PLAYER_VO, vo)
    this.preference.flush()
  }

  public getPlayerBackPlay(): boolean {
    if (this.preference.hasSync(AppPrefer.KEY_PLAYER_BACK_PLAY)) {
      return this.preference.getSync(AppPrefer.KEY_PLAYER_BACK_PLAY, false) as boolean
    }
    return false
  }

  public setPlayerBackPlay(backPlay: boolean) {
    this.preference.putSync(AppPrefer.KEY_PLAYER_BACK_PLAY, backPlay)
  }

  public getPlayerLoopMode(): avSession.LoopMode {
    if (this.preference.hasSync(AppPrefer.KEY_PLAYER_LOOP_MODE)) {
      return this.preference.getSync(AppPrefer.KEY_PLAYER_LOOP_MODE
        , avSession.LoopMode.LOOP_MODE_SEQUENCE) as avSession.LoopMode
    }
    return avSession.LoopMode.LOOP_MODE_SEQUENCE
  }

  public setPlayerLoopMode(mode: avSession.LoopMode) {
    this.preference.putSync(AppPrefer.KEY_PLAYER_LOOP_MODE, mode)
    this.preference.flush()
  }

  public getSortOrder(): FinSortOrder {
    if (this.preference.hasSync(AppPrefer.KEY_SORT_ORDER)) {
      return this.preference.getSync(AppPrefer.KEY_SORT_ORDER, FinSortOrder.Ascending) as FinSortOrder
    }
    return FinSortOrder.Ascending
  }

  public setSortOrder(sortOrder: FinSortOrder) {
    this.preference.putSync(AppPrefer.KEY_SORT_ORDER, sortOrder)
    this.preference.flush()
  }

  public getSortBy(): FinSortBy {
    if (this.preference.hasSync(AppPrefer.KEY_SORT_BY)) {
      return this.preference.getSync(AppPrefer.KEY_SORT_BY, FinSortBy.Name) as FinSortBy
    }
    return FinSortBy.Name
  }

  public setSortBy(sortBy: FinSortBy) {
    this.preference.putSync(AppPrefer.KEY_SORT_BY, sortBy)
    this.preference.flush()
  }

  public getPageSize(): FinPageSize {
    if (this.preference.hasSync(AppPrefer.KEY_PAGE_SIZE)) {
      return this.preference.getSync(AppPrefer.KEY_PAGE_SIZE, FinPageSize.Size_50) as FinPageSize
    }
    return FinPageSize.Size_50
  }

  public setPageSize(pageSize: FinPageSize) {
    this.preference.putSync(AppPrefer.KEY_PAGE_SIZE, pageSize)
    this.preference.flush()
  }

  public flush() {
    this.preference.flush()
  }

}