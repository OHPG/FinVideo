import { media } from "@kit.MediaKit";
import { BaseItemDto } from "@ohpg/jellyfin";
import { Repository } from "../data/Repository";
import { ErrorCallback } from "@kit.BasicServicesKit";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/4/26 16:50
 * @Version V1.0
 * @Description
 */
export abstract class AbstractPlayer {

  protected readonly context: Context

  protected readonly repository: Repository

  private reportingPlayback: boolean = false

  protected itemDto?: BaseItemDto

  protected lastPosition = 0

  private lastState?: media.AVPlayerState = undefined

  private stateChangeCallback?: media.OnAVPlayerStateChangeHandle

  protected progressCallback?: Callback<number>

  protected errorCallback?: ErrorCallback

  constructor(context: Context) {
    this.context = context
    this.repository = AppStorage.get(Repository.REPOSITORY)!
  }

  /**
   * Get player name
   * @returns
   */
  public abstract getName(): string

  /**
   * Set surface id
   * @param id
   */
  public abstract setSurfaceId(id?: string)

  /**
   * Set data
   * @param url
   * @param item
   * @returns
   */
  public abstract setData(url: string, item: BaseItemDto): Promise<void>

  /**
   * Get video width
   * @returns
   */
  public abstract getWidth(): number | undefined

  /**
   * Get video height
   * @returns
   */
  public abstract getHeight(): number | undefined

  /**
   * Prepare
   * @returns
   */
  public abstract prepare(): Promise<void>

  /**
   * Start play
   * @returns
   */
  public abstract start(): Promise<void>

  /**
   * Pause play
   * @returns
   */
  public abstract pause(): Promise<void>

  /**
   * Stop play
   * @returns
   */
  public abstract stop(): Promise<void>

  /**
   * Reset play
   * @returns
   */
  public abstract reset(): Promise<void>

  /**
   * Seek
   * @param position
   * @returns
   */
  public abstract seek(position: number): Promise<void>

  /**
   * Get duration
   * @returns
   */
  public abstract getDuration(): number

  /**
   * Get play position
   * @returns
   */
  public abstract getPosition(): number

  /**
   * Get current track
   * @returns
   */
  public abstract getCurrentTrack(type: media.MediaType): Promise<number>

  /**
   * Get tracks
   * @returns
   */
  public abstract getTrackInfo(type: media.MediaType): Promise<Array<media.MediaDescription>>

  /**
   * Select track
   * @param type
   * @param index
   */
  public abstract selectTrack(type: media.MediaType, index: number)

  /**
   * Get speed
   * @returns
   */
  public abstract getSpeed(): media.PlaybackSpeed

  /**
   * Set speed
   * @param speed
   */
  public abstract setSpeed(speed: media.PlaybackSpeed)

  onProgressChange(callback: Callback<number>) {
    this.progressCallback = callback
  }

  offProgressChange() {
    this.progressCallback = undefined
  }

  onStateChange(callback: media.OnAVPlayerStateChangeHandle) {
    this.stateChangeCallback = callback
  }

  offStateChange() {
    this.stateChangeCallback = undefined
  }

  onError(callback: ErrorCallback) {
    this.errorCallback = callback
  }

  offError() {
    this.errorCallback = undefined
  }

  protected onStateChanged(state: media.AVPlayerState, reason: media.StateChangeReason) {
    this.lastState = state
    this.stateChangeCallback?.(state, reason)
  }

  protected reportPlaybackStart() {
    if (!this.itemDto) {
      return
    }
    // console.log("AbstractController: reportPlaybackStart " + this.itemDto.Id)
    this.reportingPlayback = true
    this.repository.onPlaybackStart(this.itemDto.Id!)
      .then(() => {
        this.reportingPlayback = false
        // console.log("AbstractController: reportPlaybackStart success.")
      })
      .catch((error: Error) => {
        this.reportingPlayback = false
        // console.warn("AbstractController: reportPlaybackStart fail " + JSON.stringify(error))
      })
  }

  protected reportPlaybackUpdate() {
    if (!this.itemDto || this.reportingPlayback) {
      return
    }
    this.reportingPlayback = true
    this.lastPosition = this.getPosition() * 10000
    // console.log("AbstractController: reportPlaybackUpdate " + this.itemDto.Id + ", position = " + this.lastPosition)
    this.repository.onPlaybackUpdate(this.itemDto.Id!, this.lastPosition, this.lastState === 'playing')
      .then(() => {
        this.reportingPlayback = false
        // console.log("AbstractController: reportPlaybackUpdate success.")
      })
      .catch((error: Error) => {
        this.reportingPlayback = false
        // console.warn("AbstractController: reportPlaybackUpdate fail " + JSON.stringify(error))
      })
  }

  protected reportPlaybackStop() {
    if (!this.itemDto) {
      return
    }
    this.reportingPlayback = true
    // console.log("AbstractController: reportPlaybackStop " + this.itemDto.Id)
    this.repository.onPlaybackStop(this.itemDto.Id!, this.lastPosition)
      .then(() => {
        this.reportingPlayback = false
        // console.log("AbstractController: reportPlaybackStop success.")
      })
      .catch((error: Error) => {
        this.reportingPlayback = false
        // console.warn("AbstractController: reportPlaybackStop fail " + JSON.stringify(error))
      })
  }

  public async release(): Promise<void> {
    this.stateChangeCallback = undefined
  }

}