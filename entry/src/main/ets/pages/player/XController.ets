import { media } from "@kit.MediaKit"
import { AbstractPlayer } from "../../player/AbstractPlayer"
import { ErrorCallback } from "@kit.BasicServicesKit"
import { Repository } from "../../data/Repository"
import { AppPrefer } from "../../prefer/AppPrefer"
import { PlayerImpl } from "../../player/PlayerImpl"
import { WLPlayer } from "../../player/WLPlayer"
import { AVPlayer } from "../../player/AVPlayer"
import { FinItem } from "@ohpg/fin-core"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/6/9 22:16
 * @Version V1.0
 * @Description 播放器控制器
 */
export class XController extends XComponentController {

  private readonly context: Context

  private readonly repository: Repository

  private appPrefer: AppPrefer = AppStorage.get(AppPrefer.PREFER)!

  private surfaceId?: string

  private windowWidth = 0

  private windowHeight = 0

  private avFitMode: 'Inside' | 'Crop' = 'Inside'

  player?: AbstractPlayer

  private stateChangeCallback?: media.OnAVPlayerStateChangeHandle

  private progressCallback?: Callback<number>

  private errorCallback?: ErrorCallback

  private subCallback?: Callback<media.SubtitleInfo>

  constructor(context: Context) {
    super()
    this.context = context
    this.repository = AppStorage.get(Repository.REPOSITORY)!
  }

  onSurfaceCreated(surfaceId: string): void {
    this.surfaceId = surfaceId
    this.player?.setSurfaceId(surfaceId)
    // console.log("XController onSurfaceCreated surfaceId = " + surfaceId)
  }

  onSurfaceChanged(surfaceId: string, rect: SurfaceRect): void {
    // console.log("XController onSurfaceChanged surfaceId = " + surfaceId + ", rect = " + JSON.stringify(rect))
    this.player?.setSurfaceId(surfaceId)
    if (rect.surfaceWidth > rect.surfaceHeight) {
      if (this.windowWidth <= 0 || this.windowHeight <= 0) {
        this.windowWidth = rect.surfaceWidth
        this.windowHeight = rect.surfaceHeight
        this.updateFitType()
      }
    }
  }

  onSurfaceDestroyed(surfaceId: string): void {
    // console.log("XController onSurfaceDestroyed surfaceId = " + surfaceId)
    this.surfaceId = undefined
    this.player?.setSurfaceId(undefined)
  }

  /**
   * Set fit type
   * @param type
   */
  public setFitType(type: "Inside" | "Crop"): void {
    // console.log("XController setFitType type = " + type)
    if (this.avFitMode === type) {
      return
    }
    this.avFitMode = type
    this.updateFitType()
  }

  private updateFitType() {
    if (this.player === undefined) return
    let videoWidth = this.player.getWidth()
    let videoHeight = this.player.getHeight()
    let impl = this.player.getName()
    if (videoWidth && videoHeight && this.windowWidth > 0 && this.windowHeight > 0) {
      let width = 0
      let height = 0
      let videoAspectRatio = videoWidth / (videoHeight * 1.0)
      let windowAspectRatio = this.windowWidth / this.windowHeight
      if (this.avFitMode == 'Inside') {
        if (videoAspectRatio > windowAspectRatio) {
          width = this.windowWidth
          height = this.windowWidth / videoAspectRatio
        } else if (videoAspectRatio < windowAspectRatio) {
          width = this.windowHeight * videoAspectRatio
          height = this.windowHeight
        } else {
          width = this.windowWidth
          height = this.windowHeight
        }
      } else {
        if (impl === "AVPlayer") {
          // AVPlayer默认就会裁剪
          width = this.windowWidth
          height = this.windowHeight
        } else {
          if (videoAspectRatio > windowAspectRatio) {
            width = this.windowHeight * videoAspectRatio
            height = this.windowHeight
          } else if (videoAspectRatio < windowAspectRatio) {
            width = this.windowWidth
            height = this.windowWidth / videoAspectRatio
          } else {
            width = this.windowWidth
            height = this.windowHeight
          }
        }
      }
      // console.log("XController updateFitType width = " + width + ", height = " + height)
      this.setXComponentSurfaceRect({
        surfaceWidth: width,
        surfaceHeight: height
      })
    }
  }

  async setData(item: FinItem): Promise<void> {
    // 加载播放媒体源
    let source = await this.repository.getMediaSource(item.id)

    // 根据偏好和视频是否是hdr，决定调用的播放器
    let impl = this.appPrefer.getPlayerImpl()
    let implName: string
    if (impl == PlayerImpl.AVPlayer) {
      implName = "AVPlayer"
    } else if (impl === PlayerImpl.WL_MEDIA){
      implName = "WLMedia"
    } else {
      implName = source.sdr ? "WLMedia" : "AVPlayer"
    }

    // 创建或重置播放器
    if (!this.player || this.player.getName() !== implName) {
      this.player?.release()
      this.player = undefined
      this.player = implName === "WLMedia" ? new WLPlayer(this.context) : new AVPlayer(this.context)
      if (this.surfaceId) {
        this.player.setSurfaceId(this.surfaceId)
      }
      this.player.onStateChange((state, reason) => {
        if (state == 'prepared') {
          this.updateFitType()
        }
        this.stateChangeCallback?.(state, reason)
      })
      this.player.onError((error) => {
        this.errorCallback?.(error)
      })
      this.player.onProgressChange((progress) => {
        this.progressCallback?.(progress)
      })
      this.player.onSub((sub) => {
        this.subCallback?.(sub)
      })
    } else {
      await this.player.reset()
    }
    await this.player.setData(source.url, item)
  }

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

  /**
   * Add subtitle callback
   * @param type
   * @param callback
   */
  onSub(callback: Callback<media.SubtitleInfo>): void {
    this.subCallback = callback
  }

  /**
   * Remove subtitle callback
   * @param type
   * @param callback
   */
  offSub(callback?: Callback<media.SubtitleInfo>): void {
    this.subCallback = undefined
  }

  release() {
    // console.log("XController release")
    this.player?.offProgressChange()
    this.player?.offStateChange()
    this.player?.offError()
    this.player?.release()
    this.player = undefined
    this.progressCallback = undefined
    this.stateChangeCallback = undefined
    this.errorCallback = undefined
  }
}