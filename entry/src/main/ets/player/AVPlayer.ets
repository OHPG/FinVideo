import { media } from "@kit.MediaKit";
import { BaseItemDto } from "@ohpg/jellyfin";
import { AbstractPlayer } from "./AbstractPlayer";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/24 11:20
 * @Version V1.0
 * @Description
 */
export class AVPlayer extends AbstractPlayer {

  private avPlayer?: media.AVPlayer

  private avTimer?: number

  private avState: media.AVPlayerState = 'idle';

  private avSpeed?: media.PlaybackSpeed

  private surfaceId?: string

  constructor(context: Context) {
    super(context);
  }

  public getName(): string {
    return "AVPlayer"
  }

  private async requireAvPlayer(): Promise<media.AVPlayer> {
    if (this.avPlayer) {
      return this.avPlayer
    }
    // player
    this.avPlayer = await media.createAVPlayer()
    this.avPlayer.surfaceId = this.surfaceId
    this.avPlayer.on('stateChange', (state, reason) => {
      this.avState = state
      if (state === 'initialized') {
        this.avPlayer!.surfaceId = this.surfaceId
        this.avPlayer?.prepare()
      }
      if (state === 'prepared') {
        this.avPlayer!.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT_CROP
        if (this.avSpeed !== undefined) {
          this.avPlayer?.setSpeed(this.avSpeed)
        }
        // continue play
        let percent = this.itemDto?.UserData?.PlayedPercentage
        let ticks = this.itemDto?.UserData?.PlaybackPositionTicks
        if (ticks && percent && percent <= 98) {
          this.avPlayer?.seek(ticks / 10000)
        }
        this.avPlayer?.play()
      }
      if (state === 'playing') {
        this.startTimer()
      } else {
        this.stopTimer()
      }
      this.onStateChanged(state, reason)
    })
    this.avPlayer.on('seekDone', (position) => {
      // console.log("VideoController: onSeekDone position = " + position)
    })
    this.avPlayer.on('bufferingUpdate', (type, value) => {
      // console.log("VideoController: onBufferUpdate type = " + type + ", value = " + value)
    })
    this.avPlayer.on('trackChange', (index, selected) => {
      // console.log("VideoController: onTrackChange index = " + index + ", selected = " + selected)
    })
    this.avPlayer.on('durationUpdate', (duration) => {
      // console.log("VideoController: onDurationUpdate duration = " + duration)
    })
    this.avPlayer.on('error', (error) => {
      // console.log("VideoController: onError error = " + JSON.stringify(error))
      this.errorCallback?.(error)
    })
    return this.avPlayer
  }

  public setSurfaceId(id?: string | undefined): void {
    this.surfaceId = id
  }

  private startTimer() {
    if (this.avTimer !== undefined) return
    this.avTimer = setInterval(() => {
      this.progressCallback?.(this.getPosition())
    }, 1000)
  }

  private stopTimer() {
    if (this.avTimer) {
      clearInterval(this.avTimer)
      this.avTimer = undefined
    }
  }

  public getDuration(): number {
    if (this.avPlayer) {
      return this.avPlayer.duration
    }
    return 0
  }

  public getPosition(): number {
    if (this.avPlayer) {
      return this.avPlayer.currentTime
    }
    return 0
  }

  public getWidth(): number | undefined {
    return this.avPlayer?.width
  }

  public getHeight(): number | undefined {
    return this.avPlayer?.height
  }

  public async setData(url: string, item: BaseItemDto): Promise<void> {
    this.itemDto = item
    let avPlayer = await this.requireAvPlayer()
    avPlayer.url = url
  }

  public async prepare(): Promise<void> {
    let avPlayer = await this.requireAvPlayer()
    await avPlayer.prepare()
  }

  public getState(): media.AVPlayerState {
    return this.avState
  }

  public isPrepared(): boolean {
    return false
  }

  public getSpeed(): media.PlaybackSpeed {
    if (this.avSpeed === undefined) {
      return media.PlaybackSpeed.SPEED_FORWARD_1_00_X
    }
    return this.avSpeed
  }

  public setSpeed(speed: media.PlaybackSpeed) {
    this.avSpeed = speed
    this.avPlayer?.setSpeed(speed)
  }

  public async getTrackInfo(type: media.MediaType): Promise<Array<media.MediaDescription>> {
    let trackArray = new Array<media.MediaDescription>()
    if (this.avPlayer) {
      let allTracks = await this.avPlayer!.getTrackDescription()
      allTracks.forEach((track) => {
        let trackType = track[media.MediaDescriptionKey.MD_KEY_TRACK_TYPE] as media.MediaType
        if (trackType === type) {
          trackArray.push(track)
        }
      })
    }
    return trackArray
  }

  public async getCurrentTrack(type: media.MediaType): Promise<number> {
    if (!this.avPlayer) return 0
    let indexs =  await this.avPlayer.getSelectedTracks()
    let tracks = await this.getTrackInfo(type)
    let track = tracks.find((t) => {
      let index = t[media.MediaDescriptionKey.MD_KEY_TRACK_INDEX] as number
      return indexs.indexOf(index) >= 0
    })
    if (track) {
      return track[media.MediaDescriptionKey.MD_KEY_TRACK_INDEX] as number
    }
    return 0
  }

  public selectTrack(type: media.MediaType, index: number) {
    this.avPlayer?.selectTrack(index)
  }

  public async start(): Promise<void> {
    await this.avPlayer?.play()
  }

  public async seek(position: number): Promise<void> {
    // console.log("VideoController: seek " + position)
    this.avPlayer?.seek(position, media.SeekMode.SEEK_CLOSEST)
  }

  public async pause(): Promise<void> {
    await this.avPlayer?.pause()
  }

  public async stop(): Promise<void> {
    await this.avPlayer?.stop()
  }

  public async reset(): Promise<void> {
    await this.avPlayer?.reset()
  }

  public async release(): Promise<void> {
    this.progressCallback = undefined
    this.errorCallback = undefined
    await this.avPlayer?.release()
    await super.release()
  }

}