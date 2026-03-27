import { FinItem, FinItemType } from "@ohpg/fin-core"
import { AVPlayerConfig, MediaControl, avSessionExt } from "@ohpg/player"
import { AppPrefer } from "../prefer/AppPrefer"
import observer from '@ohos.arkui.observer';
import { avSession } from "@kit.AVSessionKit";
import { common } from "@kit.AbilityKit";
import BuildProfile from 'BuildProfile';
import { AppPlayer } from "./AppPlayer";
import { Repository } from "../data/Repository";
import { media } from "@kit.MediaKit";

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

  private mediaPlayer?: AppPlayer

  private mediaConfig?: AVPlayerConfig

  private avMetadata?: avSession.AVMetadata

  private avMediaDescription?: avSession.AVMediaDescription

  private duration?: number

  private state?: avSession.PlaybackState

  private progress?: number

  private shouldResumePlay = false

  private reportingPlayback = false

  private reportPosition?: number = undefined

  private routerCallback: Callback<observer.RouterPageInfo> = (pageInfo) => {
    if (pageInfo.name !== "pages/player/PlayerPage") return
    switch (pageInfo.state) {
      case observer.RouterPageState.ABOUT_TO_APPEAR:
        break
      case observer.RouterPageState.ABOUT_TO_DISAPPEAR:
        this.shouldResumePlay = false
        this.reportPlaybackStop()
        this.avMetadata = undefined
        this.avMediaDescription = undefined
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
    if (metadata.assetId !== this.avMetadata?.assetId) {
      this.reportPlaybackStop()
      this.reportPosition = undefined
    }
    this.avMetadata = metadata
    this.avMediaDescription = this.mediaControl?.queue.getItemById(metadata.assetId)?.description
  }

  private playbackStateCallback: Callback<avSession.AVPlaybackState> = async (state) => {
    this.progress = state.position?.elapsedTime
    this.duration = state.duration
    this.state = state.state
    this.reportPlayback()
    switch (state.state) {
      case avSession.PlaybackState.PLAYBACK_STATE_PREPARE:
        this.duration = state.duration!
        this.applyState()
        break
      case avSession.PlaybackState.PLAYBACK_STATE_PLAY:
        // 在播放时，更新进度
        if (this.avMediaDescription) {
          this.avMediaDescription.startPosition = this.progress
        }
        break
      case avSession.PlaybackState.PLAYBACK_STATE_PAUSE:
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
    let vo = this.appPrefer!.getPlayerVo()
    this.mediaPlayer = new AppPlayer(this.context.getHostContext()!, vo)
    this.mediaControl = new MediaControl(this.context.getHostContext()!, this.mediaPlayer)
    this.mediaControl.onPlaybackStateChange(this.playbackStateCallback)
    this.mediaControl.onMetadataChange(this.metadataCallback)
    this.mediaControl.queue.setMode(this.appPrefer.getPlayerLoopMode())

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

  private async applyState() {
    // 有历史记录，并且未完成
    await this.applySub()
    if (this.avMediaDescription?.startPosition && this.duration
      && this.duration - this.avMediaDescription.startPosition > 1000) {
      this.mediaPlayer?.seek(this.avMediaDescription.startPosition)
    }
    this.mediaPlayer?.start()
  }

  private async applySub() {
    let subs = this.mediaPlayer?.getAppSource()?.sub
    if (!this.mediaPlayer || !subs || subs.length <= 0) return
    let curSub = await this.mediaPlayer.getCurrentTrack(media.MediaType.MEDIA_TYPE_SUBTITLE)
    for (const sub of subs) {
      await this.mediaPlayer.addSubtitle(sub.url)
    }
    if (curSub <= 0) {
      let index = subs.findIndex((sub) => sub.force || sub.default ? true : false)
      let subIndex = index >= 0 ? index + 1 : 1
      await this.mediaPlayer.selectTrack(media.MediaType.MEDIA_TYPE_SUBTITLE, subIndex)
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
          mediaImage: item.type === FinItemType.Episode
            ? item.image?.primary : item.image?.backdrop,
          mediaType: "video",
          startPosition: item.data?.playedPositionTicks,
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
    if (!this.mediaControl || !this.avMetadata) return
    if (BuildProfile.DEBUG) {
      console.log("AppMediaControl: reportPlaybackStart " + this.avMetadata.assetId)
    }
    this.reportingPlayback = true
    this.repository.onPlaybackStart(this.avMetadata.assetId)
      .then(() => {
        this.reportingPlayback = false
        if (BuildProfile.DEBUG) {
          console.log("AppMediaControl: reportPlaybackStart success.")
        }
      })
      .catch((error: Error) => {
        this.reportingPlayback = false
        if (BuildProfile.DEBUG) {
          console.warn("AppMediaControl: reportPlaybackStart fail " + JSON.stringify(error))
        }
      })
  }

  private lastState?: avSession.PlaybackState

  private reportPlayback() {
    let stateChanged = this.state !== this.lastState
    this.lastState = this.state
    switch (this.state) {
      case avSession.PlaybackState.PLAYBACK_STATE_PREPARE:
        this.reportPlaybackStart()
        break
      case avSession.PlaybackState.PLAYBACK_STATE_PLAY:
        this.reportPlaybackUpdate(stateChanged)
        break
      case avSession.PlaybackState.PLAYBACK_STATE_PAUSE:
        this.reportPlaybackUpdate(stateChanged)
        break
      case avSession.PlaybackState.PLAYBACK_STATE_STOP:
      case avSession.PlaybackState.PLAYBACK_STATE_COMPLETED:
      case avSession.PlaybackState.PLAYBACK_STATE_ERROR:
        this.reportPlaybackStop()
        break
    }
  }

  private reportPlaybackUpdate(force?: boolean) {
    if (!this.mediaControl || !this.avMetadata || !this.progress) return
    if (!force && Math.abs(this.progress - (this.reportPosition || 0)) < 5000) {
      return
    }
    this.reportingPlayback = true
    this.reportPosition = this.progress
    if (BuildProfile.DEBUG) {
      console.log("AppMediaControl: reportPlaybackUpdate " + this.avMetadata.assetId
        + ", position = " + this.reportPosition + ", playing = " + this.mediaControl.isPlaying())
    }
    this.repository.onPlaybackProgress(this.avMetadata.assetId, this.reportPosition, this.mediaControl?.isPlaying())
      .then(() => {
        this.reportingPlayback = false
        if (BuildProfile.DEBUG) {
          console.log("AppMediaControl: reportPlaybackUpdate success.")
        }
      })
      .catch((error: Error) => {
        this.reportingPlayback = false
        if (BuildProfile.DEBUG) {
          console.warn("AppMediaControl: reportPlaybackUpdate fail " + JSON.stringify(error))
        }
      })
  }

  private reportPlaybackStop() {
    if (!this.mediaControl || !this.avMetadata) return
    this.reportingPlayback = true
    if (BuildProfile.DEBUG) {
      console.log("AppMediaControl: reportPlaybackStop " + this.avMetadata.assetId)
    }
    this.repository.onPlaybackStopped(this.avMetadata.assetId, this.reportPosition || 0)
      .then(() => {
        this.reportingPlayback = false
        if (BuildProfile.DEBUG) {
          console.log("AppMediaControl: reportPlaybackStop success.")
        }
      })
      .catch((error: Error) => {
        this.reportingPlayback = false
        if (BuildProfile.DEBUG) {
          console.warn("AppMediaControl: reportPlaybackStop fail " + JSON.stringify(error))
        }
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