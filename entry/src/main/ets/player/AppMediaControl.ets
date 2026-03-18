import { FinItem } from "@ohpg/fin-core"
import { AVPlayer, AVPlayerConfig, MediaControl, avSessionExt } from "@ohpg/player"
import { AppPrefer } from "../prefer/AppPrefer"
import observer from '@ohos.arkui.observer';
import { avSession } from "@kit.AVSessionKit";
import { common } from "@kit.AbilityKit";
import BuildProfile from 'BuildProfile';
import { AppPlayer } from "./AppPlayer";
import { Repository } from "../data/Repository";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2026/3/17 11:52
 * @Version V1.0
 * @Description 
 */
export class AppMediaControl {

  public static readonly MEDIA_CONTROL = 'AppMediaControl'

  private readonly context: UIContext

  private readonly appPrefer: AppPrefer

  private readonly repository: Repository

  private mediaControl?: MediaControl

  private mediaPlayer?: AVPlayer

  private mediaConfig?: AVPlayerConfig

  private metadata?: avSession.AVMetadata

  private duration?: number

  private progress?: number

  private shouldResumePlay = false

  private reportingPlayback = false

  private reportPosition: number = 0

  private routerCallback: Callback<observer.RouterPageInfo> = (pageInfo) => {
    if (pageInfo.name !== "pages/player/PlayerPage") return
    switch (pageInfo.state) {
      case observer.RouterPageState.ABOUT_TO_APPEAR:
        break
      case observer.RouterPageState.ABOUT_TO_DISAPPEAR:
        this.shouldResumePlay = false
        this.reportPlaybackStop()
        this.metadata = undefined
        this.reportPosition = 0
        this.destroyPlayer()
        break
      case observer.RouterPageState.ON_PAGE_SHOW:
        if (this.shouldResumePlay) {
          this.mediaControl?.play()
        }
        this.shouldResumePlay = false
        break
      case observer.RouterPageState.ON_PAGE_HIDE:
        if (this.isPlaying() && !this.appPrefer.getPlayerBackPlay()) {
          this.mediaControl?.pause()
          this.shouldResumePlay = true
        }
        break
      case observer.RouterPageState.ON_BACK_PRESS:
        break
    }
  }

  private metadataCallback: Callback<avSession.AVMetadata> = (metadata) => {
    if (metadata.assetId !== this.metadata?.assetId) {
      this.reportPlaybackStop()
    }
    this.metadata = metadata
    let description = this.mediaControl?.queue.getItemById(metadata.assetId)?.description
    if (!description) return
  }

  private playbackStateCallback: Callback<avSession.AVPlaybackState> = async (state) => {
    // 上报进度
    let progress = state.position?.elapsedTime
    if (this.progress && progress && Math.abs(progress - this.progress) > 5000) {
      this.reportPlaybackUpdate()
    }
    this.progress = progress
    this.duration = state.duration
    switch (state.state) {
      case avSession.PlaybackState.PLAYBACK_STATE_PREPARE:
        this.duration = state.duration!
        let description = this.mediaControl?.queue.getItemById(this.metadata!.assetId)?.description
        if (description && description.startPosition) {
          this.mediaPlayer?.seek(description.startPosition)
        }
        this.mediaPlayer?.start()
        this.reportPlaybackStart()
        break
      case avSession.PlaybackState.PLAYBACK_STATE_PLAY:
        this.reportPlaybackUpdate()
        break
      case avSession.PlaybackState.PLAYBACK_STATE_PAUSE:
        this.reportPlaybackUpdate()
        break
      case avSession.PlaybackState.PLAYBACK_STATE_COMPLETED:
        this.skipNextOrExit()
        break
      case avSession.PlaybackState.PLAYBACK_STATE_ERROR:
        let error: BusinessError | undefined = state.extras?.["error"] as BusinessError;
        if (error) {
          this.context.getPromptAction().showToast({message: "播放失败，" + error.code + "：" + error.message})
        } else {
          this.context.getPromptAction().showToast({message: "播放失败"})
        }
        break
    }
  }

  private trackCallback: Callback<avSessionExt.AVTrackInfo> = (info) => {
    // this.updateTrack(info)
  }

  private configCallback: Callback<void> = () => {
    this.updateConfig()
  }

  constructor(context: UIContext) {
    this.context = context
    this.appPrefer = AppStorage.get(AppPrefer.PREFER)!
    this.repository = AppStorage.get(Repository.REPOSITORY)!
    observer.on('routerPageUpdate', this.context.getHostContext() as common.UIAbilityContext, this.routerCallback)
  }

  private initPlayer() {
    this.mediaPlayer = new AppPlayer(this.context.getHostContext()!)
    this.mediaControl = new MediaControl(this.context.getHostContext()!, this.mediaPlayer)
    this.mediaControl.onPlaybackStateChange(this.playbackStateCallback)
    this.mediaControl.onMetadataChange(this.metadataCallback)
    this.mediaControl.queue.setMode(this.appPrefer.getPlayerLoopMode())
    let vo = this.appPrefer!.getPlayerVo()
    if (vo > 0) {
      this.mediaPlayer.setOptions('option', "vo", "gpu")
    } else {
      this.mediaPlayer.setOptions('option', "vo", "ohcodec_embed")
    }
    this.mediaPlayer.setOptions('option', "hwdec", "auto")
    this.mediaPlayer.setOptions('option', "profile", "fast")
    this.mediaPlayer.setOptions('option', "video-sync", "audio")
    this.mediaPlayer.setOptions('option', "vd-lavc-fast", "yes")
    this.mediaPlayer.setOptions('option', "vd-lavc-skiploopfilter", "nokey")

    // log
    this.mediaPlayer.setOptions('option', "terminal", "yes")
    this.mediaPlayer.setOptions('option', "msg-level", "all=" + BuildProfile.DEBUG ? "debug" : "warn")

    // 默认语言
    this.mediaPlayer.setOptions('option', "alang", "zh")
    this.mediaPlayer.setOptions('option', "slang", "zh")

    // 字幕缩放模式
    this.mediaPlayer.setOptions('option', "sub-scale-by-window", "true")
    // 字幕大小
    this.mediaPlayer.setOptions('option', "sub-font-size", "60")

    // 防止切换媒体时花屏，但是会导致接收不到结束的回调。
    // this.mediaPlayer.setOptions("property", "keep-open", true)
    this.mediaPlayer.setOptions('option', "demuxer-max-bytes", `${64 * 1024 * 1024}`)
    this.mediaPlayer.setOptions('option', "demuxer-max-back-bytes", `${32 * 1024 * 1024}`)
    this.mediaConfig = {
      loopMode: this.appPrefer.getPlayerLoopMode(),
      backgroundPlay: this.appPrefer.getPlayerBackPlay(),
      forwardStep: this.appPrefer.getPlayerFastForward(),
      backwardStep: this.appPrefer.getPlayerFastRewind(),
      callback: this.configCallback
    }
  }

  /**
   * 重置
   * @returns
   */
  public async destroyPlayer(): Promise<void> {
    AppStorage.delete(AppMediaControl.MEDIA_CONTROL)
    try {
      this.mediaControl?.offMetadataChange(this.metadataCallback)
      this.mediaControl?.offPlaybackStateChange(this.playbackStateCallback)
      this.mediaControl?.offTrackInfoChange(this.trackCallback)
      await this.mediaControl?.reset()
      await this.mediaControl?.release()
    } catch (e) {
      if (BuildProfile.DEBUG) {
        console.error("AppPlayer destroy control " + JSON.stringify(e))
      }
    } finally {
      this.mediaControl = undefined
    }

    try {
      await this.mediaPlayer?.reset()
      await this.mediaPlayer?.release()
    } catch (e) {
      if (BuildProfile.DEBUG) {
        console.error("AppPlayer destroy player " + JSON.stringify(e))
      }
    } finally {
      this.mediaPlayer = undefined
    }
  }

  public getMediaControl(): MediaControl | undefined {
    return this.mediaControl
  }

  public hasPlayerInstance(): boolean {
    return this.mediaPlayer ? true : false
  }

  public isPlaying(): boolean {
    return this.mediaPlayer?.getState() === 'playing'
  }

  public getPlayerConfig(): AVPlayerConfig | undefined {
    return this.mediaConfig
  }

  public async playAll(items: Array<FinItem>, index: number = 0): Promise<void> {
    this.initPlayer()
    // 构造列表
    let queueItemArray = new Array<avSession.AVQueueItem>()
    items.forEach((item, index) => {
      let extra: Record<string, Object> = {}
      queueItemArray.push({
        itemId: index,
        description: {
          assetId: item.id,
          title: item.name,
          description: item.overview,
          mediaUri: item.id,
          mediaImage: item.image?.backdrop,
          mediaType: "video",
          startPosition: item.playbackPositionTicks,
          duration: item.runtimeTicks,
          extras: extra
        }
      })
    })
    try {
      await this.mediaControl!.session.setQueueItems(queueItemArray)
      await this.mediaControl!.playItem(items[index].id)
    } catch (e) {
      console.error("xxx: " + JSON.stringify(e))
    }
  }

  private skipNextOrExit() {
    if (!this.mediaControl) return
    // 单曲循环，需要重新跳转到片头并播放
    if (this.mediaControl.queue.getMode() === avSession.LoopMode.LOOP_MODE_SINGLE) {
      this.mediaControl.seek(0)
      this.mediaControl.play()
      return
    }
    // 上报停止播放状态
    this.reportPlaybackStop()

    if (this.mediaControl.queue.canSkipNext()) {
      this.mediaControl.next()
    } else {
      this.context.getRouter().back()
    }
  }

  /**
   * 更新配置
   */
  public updateConfig() {
    if (!this.mediaConfig) return
    if (this.mediaConfig.backgroundPlay !== undefined) {
      this.appPrefer.setPlayerBackPlay(this.mediaConfig.backgroundPlay)
    }
    if (this.mediaConfig.loopMode !== undefined) {
      this.appPrefer.setPlayerLoopMode(this.mediaConfig.loopMode)
    }
    this.appPrefer.flush()
  }

  private reportPlaybackStart() {
    if (!this.mediaControl || !this.metadata) return
    // console.log("AppMediaControl: reportPlaybackStart " + this.itemDto.Id)
    this.reportingPlayback = true
    this.repository.onPlaybackStart(this.metadata.assetId)
      .then(() => {
        this.reportingPlayback = false
        // console.log("AppMediaControl: reportPlaybackStart success.")
      })
      .catch((error: Error) => {
        this.reportingPlayback = false
        // console.warn("AppMediaControl: reportPlaybackStart fail " + JSON.stringify(error))
      })
  }

  private reportPlaybackUpdate() {
    if (!this.mediaControl || !this.metadata || this.reportingPlayback || !this.progress) return
    this.reportingPlayback = true
    this.reportPosition = this.progress
    // console.log("AppMediaControl: reportPlaybackUpdate " + this.itemDto.Id + ", position = " + this.lastPosition)
    this.repository.onPlaybackProgress(this.metadata.assetId, this.reportPosition, this.mediaControl?.isPlaying())
      .then(() => {
        this.reportingPlayback = false
        // console.log("AppMediaControl: reportPlaybackUpdate success.")
      })
      .catch((error: Error) => {
        this.reportingPlayback = false
        // console.warn("AppMediaControl: reportPlaybackUpdate fail " + JSON.stringify(error))
      })
  }

  private reportPlaybackStop() {
    if (!this.mediaControl || !this.metadata) return
    this.reportingPlayback = true
    // console.log("AppMediaControl: reportPlaybackStop " + this.itemDto.Id)
    this.repository.onPlaybackStopped(this.metadata.assetId, this.reportPosition)
      .then(() => {
        this.reportingPlayback = false
        // console.log("AppMediaControl: reportPlaybackStop success.")
      })
      .catch((error: Error) => {
        this.reportingPlayback = false
        // console.warn("AppMediaControl: reportPlaybackStop fail " + JSON.stringify(error))
      })
  }

  /**
   * 释放资源
   * @returns
   */
  public async release(): Promise<void> {
    observer.off("routerPageUpdate", this.context.getHostContext() as common.UIAbilityContext, this.routerCallback)
  }

}