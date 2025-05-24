import { BaseItemDto } from "@ohpg/jellyfin";
import {
  WlAudioInterruptHint,
  WlAudioInterruptType,
  WlScaleType,
  WlCodecType, WlCompleteType, WlLoadStatus, WlPlayer, WlTrackType } from "libwlmedia";
import { AbstractController } from "./AbstractController";
import { media } from "@kit.MediaKit";
import { WlTrackInfoBean } from "libwlmedia/src/main/ets/com/ywl5320/wlmedia/bean/WlTrackInfoBean";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/4/26 16:47
 * @Version V1.0
 * @Description wlmedia
 */
export class WLController extends AbstractController {

  private readonly wlPlayer: WlPlayer

  private readonly rgba: string = '#000000FF';

  private readonly uniqueNum: number = 0

  private prepared: boolean = false

  private videoWidth?: number

  private videoHeight?: number

  private count = 0

  public static generateUniqueNum(): number {
    return Date.now() + Math.floor(Math.random() * 1000);
  }

  constructor(context: Context) {
    super(context)
    this.uniqueNum = WLController.generateUniqueNum();
    this.wlPlayer = new WlPlayer()
    this.wlPlayer.setCodecType(WlCodecType.WL_CODEC_AUTO);
    this.requirePlayer()
  }

  private requirePlayer(): WlPlayer {
    this.onStateChanged('idle', media.StateChangeReason.BACKGROUND)
    this.wlPlayer.setOnMediaInfoListener({
      onPrepared: (): void => {
        this.prepared = true
        let tracks = this.wlPlayer.getVideoTracks()
        if (tracks && tracks.length > 0) {
          let track = tracks[0]
          this.videoWidth = track.videoWidth
          this.videoHeight = track.videoHeight
        }
        this.onStateChanged('prepared', media.StateChangeReason.BACKGROUND)
        // continue play
        let percent = this.itemDto?.UserData?.PlayedPercentage
        let ticks = this.itemDto?.UserData?.PlaybackPositionTicks
        if (ticks && percent && percent <= 98 ) {
          this.wlPlayer.seek(ticks / (10000 * 1000))
        }
        this.wlPlayer?.start();
      },
      onOutRenderTexture: (tex, width, height, rotate): void => {
      },
      onTimeInfo: (currentTime: number, bufferTime: number): void => {
        let position = currentTime * 1000
        this.progressCallback?.(position)
        this.count ++
        if (this.count >= 5) {
          this.reportPlaybackUpdate()
          this.count = 0
        }
      },
      onComplete: (wlCompleteType: WlCompleteType, msg: string): void => {
        this.prepared = false
        if (wlCompleteType == WlCompleteType.WL_COMPLETE_EOF) {
          // 正常播放完成
          this.videoWidth = undefined
          this.videoHeight = undefined
          this.onStateChanged('completed', media.StateChangeReason.BACKGROUND)
        } else if (wlCompleteType == WlCompleteType.WL_COMPLETE_ERROR) {
          // 播放出错，原因为：msg 字段
          this.videoWidth = undefined
          this.videoHeight = undefined
          this.errorCallback?.({
            name: "Player",
            code: -1,
            message: msg
          })
        } else if (wlCompleteType == WlCompleteType.WL_COMPLETE_HANDLE) {
          // 主动调用 wlPlayer.stop() 会回调此类型
        } else if (wlCompleteType == WlCompleteType.WL_COMPLETE_NEXT) {
          // 正在播放中，切换了新的数据源，会回调此类型
        } else if (wlCompleteType == WlCompleteType.WL_COMPLETE_TIMEOUT) {
          // 播放超时，会回调此接口
        } else if (wlCompleteType == WlCompleteType.WL_COMPLETE_LOOP) {
          // 循环播放中，每开始新的一次循环，会回调此接口
        }
      },
      onLoadInfo: (wlLoadStatus: WlLoadStatus, progress: number, speed: number): void => {
        // 加载状态回调
        if (wlLoadStatus == WlLoadStatus.WL_LOADING_STATUS_START) {
          // 开始加载
        } else if (wlLoadStatus == WlLoadStatus.WL_LOADING_STATUS_PROGRESS) {
          // 加载进度
        } else if (wlLoadStatus == WlLoadStatus.WL_LOADING_STATUS_FINISH) {
          // 加载完成
        }
      },
      onFirstFrameRendered: (): void => {
      },
      onSeekFinish: (): void => {
      },
      onAudioInterrupt: (type: WlAudioInterruptType, hint: WlAudioInterruptHint) => {
      },
      onAutoPlay: (): void => {

      },
      onDeEncryptData: (mediaType: WlTrackType, data: Uint8Array): Uint8Array | null => {
        return null;
      }
    });
    return this.wlPlayer
  }

  onSurfaceCreated(surfaceId: string): void {
    try {
      this.wlPlayer.setSurface(surfaceId, this.rgba, this.uniqueNum)
    } catch (error) {
    }
  }

  onSurfaceChanged(surfaceId: string, rect: SurfaceRect): void {
    try {
      this.wlPlayer.setSurface(surfaceId, this.rgba, this.uniqueNum);
    } catch (error) {
    }
  }

  onSurfaceDestroyed(surfaceId: string): void {
    try {
      this.wlPlayer.setSurface(null, this.rgba, this.uniqueNum);
    } catch (error) {
    }
  }

  public getUniqueNum(): number {
    return this.uniqueNum;
  }

  public async setData(item: BaseItemDto): Promise<void> {
    this.itemDto = item
    let url = await this.repository.getMediaSource(item.Id!)
    this.wlPlayer.setSource(url)
    this.onStateChanged('initialized', media.StateChangeReason.BACKGROUND)
    this.reportPlaybackStart()
  }

  public getWidth(): number | undefined {
    return this.videoWidth
  }

  public getHeight(): number | undefined {
    return this.videoHeight
  }

  public async prepare(): Promise<void> {
    this.wlPlayer.prepare()
  }

  public async start(): Promise<void> {
    if (this.wlPlayer.isPause()) {
      this.wlPlayer.resume()
      this.reportPlaybackUpdate()
    } else {
      this.wlPlayer.start()
    }
    this.onStateChanged('playing', media.StateChangeReason.BACKGROUND)
  }

  public async pause(): Promise<void> {
    this.wlPlayer.pause()
    this.onStateChanged('paused', media.StateChangeReason.BACKGROUND)
    this.reportPlaybackUpdate()
  }

  public async stop(): Promise<void> {
    this.wlPlayer.stop()
    this.onStateChanged('stopped', media.StateChangeReason.BACKGROUND)
  }

  public getDuration(): number {
    return this.wlPlayer.getDuration() * 1000
  }

  public getPosition(): number {
    return this.wlPlayer.getCurrentTime() * 1000
  }

  public async getTrackInfo(type: media.MediaType): Promise<media.MediaDescription[]> {
    let tracks: Array<WlTrackInfoBean> | undefined
    if (type === media.MediaType.MEDIA_TYPE_AUD) {
      tracks = this.wlPlayer.getAudioTracks()
    } else if (type === media.MediaType.MEDIA_TYPE_SUBTITLE) {
      tracks = this.wlPlayer.getSubtitleTracks()
    }
    let descs = new Array<media.MediaDescription>()
    tracks?.forEach((track) => {
      let desc: media.MediaDescription = {}
      desc[media.MediaDescriptionKey.MD_KEY_TRACK_INDEX] = track.trackIndex
      desc[media.MediaDescriptionKey.MD_KEY_TRACK_TYPE] = track.trackType
      desc[media.MediaDescriptionKey.MD_KEY_CODEC_MIME] = track.codecName
      desc[media.MediaDescriptionKey.MD_KEY_DURATION] = track.duration
      desc[media.MediaDescriptionKey.MD_KEY_BITRATE] = track.bitrate
      desc[media.MediaDescriptionKey.MD_KEY_WIDTH] = track.videoWidth
      desc[media.MediaDescriptionKey.MD_KEY_HEIGHT] = track.videoHeight
      desc[media.MediaDescriptionKey.MD_KEY_FRAME_RATE] = track.videoFrameRate
      desc[media.MediaDescriptionKey.MD_KEY_AUD_CHANNEL_COUNT] = track.audioChannelNum
      desc[media.MediaDescriptionKey.MD_KEY_AUD_SAMPLE_RATE] = track.audioSampleRate
      // desc[media.MediaDescriptionKey.MD_KEY_AUD_SAMPLE_DEPTH] = track.
      desc[media.MediaDescriptionKey.MD_KEY_LANGUAGE] = track.language
      // fix
      desc[media.MediaDescriptionKey.MD_KEY_TRACK_NAME] = track.language
      descs.push(desc)
    })
    return descs
  }

  public async getCurrentTrack(type: media.MediaType): Promise<number> {
    let track: number = 0
    if (type == media.MediaType.MEDIA_TYPE_AUD) {
      track = this.wlPlayer.getAudioTrackIndex(WlTrackType.WL_TRACK_AUDIO)
    } else if (type === media.MediaType.MEDIA_TYPE_VID) {
      track = this.wlPlayer.getVideoTrackIndex(WlTrackType.WL_TRACK_VIDEO)
    } else if (type === media.MediaType.MEDIA_TYPE_SUBTITLE) {
      track = this.wlPlayer.getSubtitleTrackIndex(WlTrackType.WL_TRACK_SUBTITLE)
    }
    return track
  }

  public selectTrack(type: media.MediaType, index: number): void {
    if (type == media.MediaType.MEDIA_TYPE_AUD) {
      this.wlPlayer.setAudioTrackIndex(index)
    } else if (type === media.MediaType.MEDIA_TYPE_VID) {
      this.wlPlayer.setVideoTrackIndex(index)
    } else if (type === media.MediaType.MEDIA_TYPE_SUBTITLE) {
      this.wlPlayer.setSubtitleTrackIndex(index)
    }
  }

  public setSpeed(speed: media.PlaybackSpeed): void {
    let speedNum: number = 1
    switch (speed) {
      case media.PlaybackSpeed.SPEED_FORWARD_0_25_X:
        speedNum = 0.25
        break
      case media.PlaybackSpeed.SPEED_FORWARD_0_50_X:
        speedNum = 0.50
        break
      case media.PlaybackSpeed.SPEED_FORWARD_0_75_X:
        speedNum = 0.75
        break
      case media.PlaybackSpeed.SPEED_FORWARD_1_00_X:
        speedNum = 1
        break
      case media.PlaybackSpeed.SPEED_FORWARD_1_25_X:
        speedNum = 1.25
        break
      case media.PlaybackSpeed.SPEED_FORWARD_1_50_X:
        speedNum = 1.5
        break
      case media.PlaybackSpeed.SPEED_FORWARD_1_75_X:
        speedNum = 1.75
        break
      case media.PlaybackSpeed.SPEED_FORWARD_2_00_X:
        speedNum = 2
        break
      case media.PlaybackSpeed.SPEED_FORWARD_3_00_X:
        speedNum = 3
        break
    }
    this.wlPlayer.setSpeed(speedNum)
  }

  public getSpeed(): media.PlaybackSpeed {
    let speedNum = this.wlPlayer.getSpeed()
    let speed: media.PlaybackSpeed = media.PlaybackSpeed.SPEED_FORWARD_1_00_X
    switch (speedNum) {
      case 0.25:
        speed = media.PlaybackSpeed.SPEED_FORWARD_0_25_X
        break
      case 0.5:
        speed = media.PlaybackSpeed.SPEED_FORWARD_0_50_X
        break
      case 0.75:
        speed = media.PlaybackSpeed.SPEED_FORWARD_0_75_X
        break
      case 1:
        speed = media.PlaybackSpeed.SPEED_FORWARD_1_00_X
        break
      case 1.25:
        speed = media.PlaybackSpeed.SPEED_FORWARD_1_25_X
        break
      case 1.5:
        speed = media.PlaybackSpeed.SPEED_FORWARD_1_50_X
        break
      case 1.75:
        speed = media.PlaybackSpeed.SPEED_FORWARD_1_75_X
        break
      case 2:
        speed = media.PlaybackSpeed.SPEED_FORWARD_2_00_X
        break
      case 3:
        speed = media.PlaybackSpeed.SPEED_FORWARD_3_00_X
        break
    }
    return speed
  }

  public setFitType(type: "Inside" | "Crop"): void {
    if (type === 'Inside') {
      this.wlPlayer.setVideoScale(this.uniqueNum, WlScaleType.WL_SCALE_FIT)
    } else {
      this.wlPlayer.setVideoScale(this.uniqueNum, WlScaleType.WL_SCALE_MATCH)
    }
  }

  public async seek(position: number): Promise<void> {
    this.wlPlayer.seek(position / 1000.0)
  }

  public async reset(): Promise<void> {
    this.wlPlayer
  }
  public async release(): Promise<void> {
    this.reportPlaybackStop()
    this.wlPlayer.release()
    this.onStateChanged('released', media.StateChangeReason.BACKGROUND)
  }

}