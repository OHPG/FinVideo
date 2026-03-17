import { DataStore, FinItem } from "@ohpg/fin-core"
import { MpvPlayer } from "@ohpg/mpv"
import { AVPlayer, AVPlayerConfig, MediaControl, MediaPip } from "@ohpg/player"
import { AppPrefer } from "../prefer/AppPrefer"
import observer from '@ohos.arkui.observer';
import { avSession } from "@kit.AVSessionKit";
import { common } from "@kit.AbilityKit";
import BuildProfile from 'BuildProfile';

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2026/3/17 11:52
 * @Version V1.0
 * @Description 
 */
export class AppPlayer {

  public static readonly APP_PLAYER = 'AppPlayer'

  public static readonly MEDIA_CONTROL = 'MediaControl'

  private readonly context: UIContext

  private readonly appPrefer: AppPrefer

  private readonly dataStore: DataStore

  private mediaControl?: MediaControl

  private mediaPlayer?: AVPlayer

  private mediaPip?: MediaPip

  private mediaConfig?: AVPlayerConfig

  private shouldResumePlay = false

  private routerCallback: Callback<observer.RouterPageInfo> = (pageInfo) => {
    if (pageInfo.name !== "pages/player/PlayerPage") return
    switch (pageInfo.state) {
      case observer.RouterPageState.ABOUT_TO_APPEAR:
        break
      case observer.RouterPageState.ABOUT_TO_DISAPPEAR:
        this.shouldResumePlay = false
        this.saveHistory()
        // 如果是播放器页面销毁，则需要判定是否要销毁播放器。
        if (!this.mediaPip?.isInPiP()) {
          this.destroyPlayer()
        }
        break
      case observer.RouterPageState.ON_PAGE_SHOW:
        if (this.mediaPip?.isInPiP()) return
        if (this.shouldResumePlay) {
          this.mediaControl?.play()
        }
        this.shouldResumePlay = false
        break
      case observer.RouterPageState.ON_PAGE_HIDE:
        if (this.mediaPip?.isInPiP()) return
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
    let description = this.mediaControl?.queue.getItemById(metadata.assetId)?.description
    if (!description) return
    // 如果变更，则保存之前的。
    if (this.avHistory?.id !== metadata.assetId) {
      this.saveHistory()
      this.ignoreSkip = false
    }
    this.avHistory = description.extras?.["history"] as VideoHistory
    if (!this.avHistory) {
      this.avHistory = {
        id: metadata.assetId,
        source: description.mediaUri!,
        time: 0,
        speed: 1.0,
        position: 0,
        duration: 0,
        videoId: 0,
        videoDelay: 0,
        audioId: 0,
        audioDelay: 0,
        subId: 0,
        subDelay: 0
      }
      if (!description.extras) {
        description.extras = {}
      }
      description.extras['history'] = this.avHistory
    }
  }

  private playbackStateCallback: Callback<avSession.AVPlaybackState> = async (state) => {
    this.canSkipPre = state.extras?.["canSkipPre"] ? true : false
    this.canSkipNext = state.extras?.["canSkipNext"] ? true : false
    this.progress = state.position?.elapsedTime
    this.duration = state.duration
    switch (state.state) {
      case avSession.PlaybackState.PLAYBACK_STATE_PREPARE:
        this.duration = state.duration!
        await this.applySub()
        // 根据历史记录恢复现场
        if (this.avHistory) {
          this.avHistory.duration = this.duration
          if (this.avHistory.audioId > 0) {
            this.mediaPlayer?.selectTrack(media.MediaType.MEDIA_TYPE_AUD, this.avHistory.audioId)
          } else if (this.avHistory.audioId < 0) {
            this.mediaPlayer?.deselectTrack(media.MediaType.MEDIA_TYPE_AUD)
          } else {
            // not set
          }
          if (this.avHistory.subId > 0) {
            this.mediaPlayer?.selectTrack(media.MediaType.MEDIA_TYPE_SUBTITLE, this.avHistory.subId)
          } else if (this.avHistory.subId < 0) {
            this.mediaPlayer?.deselectTrack(media.MediaType.MEDIA_TYPE_SUBTITLE)
          } else {
            // not set
          }
          if (this.avHistory.speed) {
            this.mediaControl?.setSpeed(this.avHistory.speed)
          }
          if (this.avHistory.position && this.avHistory.duration - this.avHistory.position > 5000) {
            this.mediaControl?.seek(this.avHistory.position)
          } else {
            this.skipIntro()
          }
        } else {
          this.skipIntro()
        }
        this.mediaPlayer?.start()
        break
      case avSession.PlaybackState.PLAYBACK_STATE_PLAY:
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
    if (this.avHistory && this.mediaControl?.isPrepared()) {
      if (this.progress) {
        this.avHistory.position = this.progress
      }
      if (state.speed) {
        this.avHistory.speed = state.speed
      }
    }
  }

  private configCallback: Callback<void> = () => {
    this.updateConfig()
  }

  constructor(context: UIContext) {
    this.context = context
    this.appPrefer = AppStorage.get(AppPrefer.PREFER)!
    this.dataStore = AppStorage.get(DataStore.DATA_STORE)!
    observer.on('routerPageUpdate', this.context.getHostContext() as common.UIAbilityContext, this.routerCallback)
  }

  private initPlayer() {
    this.mediaPlayer = new MpvPlayer(this.context.getHostContext()!)
    this.mediaControl = new MediaControl(this.context.getHostContext()!, this.mediaPlayer)
    this.mediaControl.onPlaybackStateChange(this.playbackStateCallback)
    this.mediaControl.onMetadataChange(this.metadataCallback)
    this.mediaControl.queue.setMode(this.appPrefer.getPlayerLoopMode())
    this.mediaPip = new MediaPip(this.context.getHostContext()!, this.mediaControl)
    this.mediaPip.setAutoStartEnabled(true)
    let vo = this.appPrefer!.getPlayerVo()
    if (vo == 2) {
      this.mediaPlayer.setOptions('option', "vo", "gpu-next")
    } else if (vo === 1) {
      this.mediaPlayer.setOptions('option', "vo", "gpu")
    } else {
      this.mediaPlayer.setOptions('option', "vo", "ohcodec_embed")
    }
    this.mediaPlayer.setOptions('option', "hwdec", this.appPrefer?.isHWDecode() ? "auto" : "no")
    // this.mediaPlayer.setOptions('option', "ao", "opensles")
    this.mediaPlayer.setOptions('option', "profile", "fast")
    this.mediaPlayer.setOptions('option', "video-sync", "audio")
    this.mediaPlayer.setOptions('option', "vd-lavc-fast", "yes")
    this.mediaPlayer.setOptions('option', "vd-lavc-skiploopfilter", "nokey")

    // this.mediaPlayer.setOptions('option', "tone-mapping", "auto")
    // this.mediaPlayer.setOptions('option', "hdr-compute-peak", "yes")
    // this.mediaPlayer.setOptions('option', "target-colorspace-hint", "yes")
    // this.mediaPlayer.setOptions('option', "target-colorspace-hint-mode", "source")
    // this.mediaPlayer.setOptions('option', "fullscreen", "yes")
    // this.mediaPlayer.setOptions('option', "tone-mapping-mode", "auto")
    // this.mediaPlayer.setOptions('option', "tone-mapping-param", "auto")
    // this.mediaPlayer.setOptions('option', "dolbyvision", "yes")
    // this.mediaPlayer.setOptions('option', "tone-mapping", "bt.2390")
    // this.mediaPlayer.setOptions('option', "target-primaries", "bt2020")
    // this.mediaPlayer.setOptions('option', "target-luminance", "1000")
    // this.mediaPlayer.setOptions('option', "target-peek", "1000")

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
    AppStorage.setOrCreate(PlayerManager.MEDIA_CONTROL, this.mediaControl)
    this.mediaConfig = {
      loopMode: this.appPrefer.getPlayerLoopMode(),
      backgroundPlay: this.appPrefer.getPlayerBackPlay(),
      forwardStep: this.appPrefer.getPlayerFastForward(),
      backwardStep: this.appPrefer.getPlayerFastRewind(),
      gestureConfig: {
        dcForFR: this.appPrefer.getPlayerGestureDcFr()
      },
      subConfig: {
        color: this.appPrefer.getSubColor(),
        size: this.appPrefer.getSubSize(),
        shadowRadius: this.appPrefer.getSubShadowRadius(),
        shadowColor: this.appPrefer.getSubShadowColor()
      },
      callback: this.configCallback
    }
  }

  /**
   * 重置
   * @returns
   */
  public async destroyPlayer(): Promise<void> {
    AppStorage.delete(PlayerManager.MEDIA_CONTROL)
    try {
      this.mediaControl?.offMetadataChange(this.metadataCallback)
      this.mediaControl?.offPlaybackStateChange(this.playbackStateCallback)
      this.mediaControl?.offTrackInfoChange(this.trackCallback)
      await this.mediaControl?.reset()
      await this.mediaControl?.release()
    } catch (e) {
      if (BuildProfile.DEBUG) {
        console.error("PlayerManager destroy control " + JSON.stringify(e))
      }
    } finally {
      this.mediaControl = undefined
    }

    try {
      await this.mediaPip?.reset()
      await this.mediaPip?.release()
    } catch (e) {
      if (BuildProfile.DEBUG) {
        console.error("PlayerManager destroy pip " + JSON.stringify(e))
      }
    } finally {
      this.mediaPip = undefined
    }

    try {
      await this.mediaPlayer?.reset()
      await this.mediaPlayer?.release()
    } catch (e) {
      if (BuildProfile.DEBUG) {
        console.error("PlayerManager destroy player " + JSON.stringify(e))
      }
    } finally {
      this.mediaPlayer = undefined
    }
  }

  public hasPlayerInstance(): boolean {
    return this.mediaPlayer ? true : false
  }

  public isPlaying(): boolean {
    return this.mediaPlayer?.getState() === 'playing'
  }

  public isPiPEnabled(): boolean {
    return this.mediaPip?.isPiPEnabled() ? true : false
  }

  public getPlayerConfig(): AVPlayerConfig | undefined {
    return this.mediaConfig
  }

  public startPiP() {
    this.mediaPip?.startPiP()
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
          mediaUri: item.uri,
          albumCoverUri: item.thumb,
          mediaType: "video",
          // 生成封面
          mediaImage: undefined,
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

    if (this.avHistory && this.duration) {
      // 强制把进度设置成总时长
      this.avHistory.position = this.duration
    }
    this.saveHistory()

    if (this.canSkipNext) {
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

  /**
   * 释放资源
   * @returns
   */
  public async release(): Promise<void> {
    observer.off("routerPageUpdate", this.context.getHostContext() as common.UIAbilityContext, this.routerCallback)
  }

}