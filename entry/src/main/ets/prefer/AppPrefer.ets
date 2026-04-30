import { preferences } from "@kit.ArkData"
import { FinPageSize, FinSortBy, FinSortOrder } from "@ohpg/fin-core"
import { avSession } from "@kit.AVSessionKit"
import { RotationType } from "../enum/RotationType"

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

  private static readonly KEY_PLAYER_FAST_FORWARD = "player_fast_forward"

  private static readonly KEY_PLAYER_FAST_REWIND = "player_fast_rewind"

  private static readonly KEY_PLAYER_HW_DECODE = "player_hw_decode"

  private static readonly KEY_PLAYER_ROTATION = "player_rotation"

  private static readonly KEY_GESTURE_DC_FR = "player_gesture_dc_fr"

  private static readonly KEY_GESTURE_SL_VB = "player_gesture_sl_vb"

  private static readonly KEY_GESTURE_GUIDE = "player_gesture_guide"

  private static readonly KEY_AUTO_NEXT = "player_auto_next"

  private static readonly KEY_AUTO_PIP = "player_auto_pip"

  private static readonly KEY_CODEC_PREFER = "player_codec_prefer"

  private static readonly KEY_AO_SPDIF = "player_spdif"

  private static readonly KEY_HISTORY_ENABLE = "player_history_enable"

  private static readonly KEY_SUB_SIZE = "player_sub_size"

  private static readonly KEY_SUB_COLOR = "player_sub_color"

  private static readonly KEY_SUB_SHADOW_RADIUS = "player_sub_shadow_radius"

  private static readonly KEY_SUB_SHADOW_COLOR = "player_sub_shadow_color"

  private static readonly KEY_SUB_VERTICAL_POSITION = "player_sub_vertical_position"

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

  public setPlayerFastForward(forward: number) {
    this.preference.putSync(AppPrefer.KEY_PLAYER_FAST_FORWARD, forward)
  }

  public getPlayerFastForward(): number {
    if (this.preference.hasSync(AppPrefer.KEY_PLAYER_FAST_FORWARD)) {
      return this.preference.getSync(AppPrefer.KEY_PLAYER_FAST_FORWARD, 30) as number
    }
    return 30
  }

  public setPlayerFastRewind(rewind: number) {
    this.preference.putSync(AppPrefer.KEY_PLAYER_FAST_REWIND, rewind)
  }

  public getPlayerFastRewind(): number {
    if (this.preference.hasSync(AppPrefer.KEY_PLAYER_FAST_REWIND)) {
      return this.preference.getSync(AppPrefer.KEY_PLAYER_FAST_REWIND, 15) as number
    }
    return 15
  }

  public isHWDecode(): boolean {
    if (this.preference.hasSync(AppPrefer.KEY_PLAYER_HW_DECODE)) {
      return this.preference.getSync(AppPrefer.KEY_PLAYER_HW_DECODE, true) as boolean
    }
    return true
  }

  public setHWDecode(hwDecode: boolean) {
    this.preference.putSync(AppPrefer.KEY_PLAYER_HW_DECODE, hwDecode)
  }

  public getPlayerRotation(): RotationType {
    if (this.preference.hasSync(AppPrefer.KEY_PLAYER_ROTATION)) {
      return this.preference.getSync(AppPrefer.KEY_PLAYER_ROTATION, 0) as number
    }
    return RotationType.FOLLOW_WINDOW
  }

  public setPlayerRotation(rotation: RotationType) {
    this.preference.putSync(AppPrefer.KEY_PLAYER_ROTATION, rotation)
  }

  public getPlayerGestureDcFr(): boolean {
    if (this.preference.hasSync(AppPrefer.KEY_GESTURE_DC_FR)) {
      return this.preference.getSync(AppPrefer.KEY_GESTURE_DC_FR, true) as boolean
    }
    return true
  }

  public setPlayerGestureDcFr(enabled: boolean) {
    this.preference.putSync(AppPrefer.KEY_GESTURE_DC_FR, enabled)
  }

  public getPlayerGestureSlVb(): boolean {
    if (this.preference.hasSync(AppPrefer.KEY_GESTURE_SL_VB)) {
      return this.preference.getSync(AppPrefer.KEY_GESTURE_SL_VB, true) as boolean
    }
    return true
  }

  public setPlayerGestureSlVb(enabled: boolean) {
    this.preference.putSync(AppPrefer.KEY_GESTURE_SL_VB, enabled)
  }

  public isPlayerGestureGuideFinished(): boolean {
    if (this.preference.hasSync(AppPrefer.KEY_GESTURE_GUIDE)) {
      return this.preference.getSync(AppPrefer.KEY_GESTURE_GUIDE, false) as boolean
    }
    return false
  }

  public setGestureGuideFinished(): void {
    this.preference.putSync(AppPrefer.KEY_GESTURE_GUIDE, true)
    this.preference.flush()
  }

  public getPlayerAutoNext(): boolean {
    if (this.preference.hasSync(AppPrefer.KEY_AUTO_NEXT)) {
      return this.preference.getSync(AppPrefer.KEY_AUTO_NEXT, true) as boolean
    }
    return true
  }

  public setPlayerAutoNext(autoNext: boolean) {
    this.preference.putSync(AppPrefer.KEY_AUTO_NEXT, autoNext)
  }

  public getPlayerAutoPip(): boolean {
    if (this.preference.hasSync(AppPrefer.KEY_AUTO_PIP)) {
      return this.preference.getSync(AppPrefer.KEY_AUTO_PIP, false) as boolean
    }
    return false
  }

  public setPlayerAutoPip(autoPip: boolean) {
    this.preference.putSync(AppPrefer.KEY_AUTO_PIP, autoPip)
  }

  public getCodecPrefer(): number {
    if (this.preference.hasSync(AppPrefer.KEY_CODEC_PREFER)) {
      return this.preference.getSync(AppPrefer.KEY_CODEC_PREFER, 1) as number
    }
    return 1
  }

  public setCodecPrefer(codec: number) {
    this.preference.putSync(AppPrefer.KEY_CODEC_PREFER, codec)
  }

  public isAoSpdif(): boolean {
    if (this.preference.hasSync(AppPrefer.KEY_AO_SPDIF)) {
      return this.preference.getSync(AppPrefer.KEY_AO_SPDIF, false) as boolean
    }
    return false
  }

  public setAoSpdif(spdif: boolean) {
    this.preference.putSync(AppPrefer.KEY_AO_SPDIF, spdif)
  }

  public enableHistory(): boolean {
    if (this.preference.hasSync(AppPrefer.KEY_HISTORY_ENABLE)) {
      return this.preference.getSync(AppPrefer.KEY_HISTORY_ENABLE, true) as boolean
    }
    return true
  }

  public setHistoryEnable(enable: boolean) {
    this.preference.putSync(AppPrefer.KEY_HISTORY_ENABLE, enable)
  }

  public getSubSize(): number {
    if (this.preference.hasSync(AppPrefer.KEY_SUB_SIZE)) {
      return this.preference.getSync(AppPrefer.KEY_SUB_SIZE, 60) as number
    }
    return 60
  }

  public setSubSize(size: number) {
    this.preference.putSync(AppPrefer.KEY_SUB_SIZE, size)
  }

  public getSubColor(): string {
    if (this.preference.hasSync(AppPrefer.KEY_SUB_COLOR)) {
      return this.preference.getSync(AppPrefer.KEY_SUB_COLOR, '#FFFFFFFF') as string
    }
    return '#FFFFFFFF'
  }

  public setSubColor(color: string) {
    this.preference.putSync(AppPrefer.KEY_SUB_COLOR, color)
  }

  public getSubShadowRadius(): number {
    if (this.preference.hasSync(AppPrefer.KEY_SUB_SHADOW_RADIUS)) {
      return this.preference.getSync(AppPrefer.KEY_SUB_SHADOW_RADIUS, 0) as number
    }
    return 0
  }

  public setSubShadowRadius(radius: number) {
    this.preference.putSync(AppPrefer.KEY_SUB_SHADOW_RADIUS, radius)
  }

  public getSubShadowColor(): string {
    if (this.preference.hasSync(AppPrefer.KEY_SUB_SHADOW_COLOR)) {
      return this.preference.getSync(AppPrefer.KEY_SUB_SHADOW_COLOR, '#80000000') as string
    }
    return '#80000000'
  }

  public setSubShadowColor(color: string) {
    this.preference.putSync(AppPrefer.KEY_SUB_SHADOW_COLOR, color)
  }

  public getSubVerticalPosition(): number {
    if (this.preference.hasSync(AppPrefer.KEY_SUB_VERTICAL_POSITION)) {
      return this.preference.getSync(AppPrefer.KEY_SUB_VERTICAL_POSITION, 100) as number
    }
    return 100
  }

  public setSubVerticalPosition(position: number) {
    this.preference.putSync(AppPrefer.KEY_SUB_VERTICAL_POSITION, position)
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
      let value = this.preference.getSync(AppPrefer.KEY_PAGE_SIZE, FinPageSize.Size_50) as number
      if (value === FinPageSize.Size_25 || value === FinPageSize.Size_50 || value === FinPageSize.Size_100) {
        return value as FinPageSize
      }
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