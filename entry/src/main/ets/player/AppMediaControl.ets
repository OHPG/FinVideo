import { AVCodecType, AVConfigEvent, AVPlayerConfig, MediaControl, MediaPip, avSessionExt } from '@ohpg/player'
import { AppPrefer } from '../prefer/AppPrefer'
import { AppPlayer } from './AppPlayer'
import { FinItem, FinItemType } from '@ohpg/fin-core'
import { Repository } from '../data/Repository'
import { AppRouter } from '../router/AppRouter'
import { avSession } from '@kit.AVSessionKit'
import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import observer from '@ohos.arkui.observer'
import BuildProfile from 'BuildProfile'
import { media } from '@kit.MediaKit'

export class AppMediaControl {

  public static readonly MEDIA_CONTROL_KEY = 'AppMediaControl'

  public static readonly AV_CONTROL_KEY = 'MediaControl'

  private readonly context: UIContext

  private readonly appPrefer: AppPrefer

  private readonly repository: Repository

  private mediaControl?: MediaControl

  private mediaPlayer?: AppPlayer

  private mediaPip?: MediaPip

  private mediaConfig?: AVPlayerConfig

  private avMetadata?: avSession.AVMetadata

  private avMediaDescription?: avSession.AVMediaDescription

  private duration?: number

  private progress?: number

  private shouldResumePlay = false

  private reportingPlayback = false

  private reportPosition?: number = undefined

  private routerCallback: Callback<observer.RouterPageInfo> = (pageInfo) => {
    if (pageInfo.name !== 'pages/player/PlayerPage') return
    switch (pageInfo.state) {
      case observer.RouterPageState.ABOUT_TO_DISAPPEAR:
        this.shouldResumePlay = false
        this.reportPlaybackStop()
        this.avMetadata = undefined
        this.avMediaDescription = undefined
        this.reportPosition = 0
        if (!this.mediaPip?.isInPiP()) {
          this.destroyPlayer()
        }
        break
      case observer.RouterPageState.ON_PAGE_SHOW:
        this.mediaPip?.restoreIfNeeded()
        if (this.shouldResumePlay) {
          this.mediaControl?.play()
        }
        this.shouldResumePlay = false
        break
      case observer.RouterPageState.ON_PAGE_HIDE:
        if (this.mediaPip?.isActive()) return
        if (this.isPlaying() && !this.appPrefer.getPlayerBackPlay()) {
          this.mediaControl?.pause()
          this.shouldResumePlay = true
        }
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
    switch (state.state) {
      case avSession.PlaybackState.PLAYBACK_STATE_PREPARE:
        this.duration = state.duration!
        await this.applyState()
        break
      case avSession.PlaybackState.PLAYBACK_STATE_PLAY:
        if (this.avMediaDescription) {
          this.avMediaDescription.startPosition = this.progress
        }
        this.reportPlaybackUpdate(false)
        break
      case avSession.PlaybackState.PLAYBACK_STATE_PAUSE:
        this.reportPlaybackUpdate(false)
        break
      case avSession.PlaybackState.PLAYBACK_STATE_COMPLETED:
        this.skipNextOrExit()
        break
      case avSession.PlaybackState.PLAYBACK_STATE_ERROR:
        let error: BusinessError | undefined = state.extras?.['error'] as BusinessError
        if (error) {
          this.context.getPromptAction().showToast({ message: $r('app.string.player_error_with_code', error.code, error.message) })
        } else {
          this.context.getPromptAction().showToast({ message: $r('app.string.player_error_generic') })
        }
        break
    }
  }

  private trackCallback: Callback<avSessionExt.AVTrackInfo> = (_info) => {
    // reserved
  }

  private configCallback: Callback<AVConfigEvent> = (event) => {
    switch (event) {
      case AVConfigEvent.SUB_STYLE:
        this.updateSubStyle()
        break
      case AVConfigEvent.LOOP_MODE:
      case AVConfigEvent.BACKGROUND_PLAY:
      case AVConfigEvent.SUB_DELAY:
      default:
        this.updateConfig()
        break
    }
  }

  constructor(context: UIContext) {
    this.context = context
    this.appPrefer = AppStorage.get(AppPrefer.PREFER)!
    this.repository = AppStorage.get(Repository.REPOSITORY)!
    observer.on('routerPageUpdate', this.context.getHostContext() as common.UIAbilityContext, this.routerCallback)
  }

  private initPlayer() {
    let vo = this.appPrefer.getPlayerVo()
    this.mediaPlayer = new AppPlayer(
      this.context.getHostContext()!,
      vo,
      this.appPrefer.getCodecPrefer() as AVCodecType
    )

    // 默认语言
    this.mediaPlayer.setOptions('option', 'alang', 'zh')
    this.mediaPlayer.setOptions('option', 'slang', 'zh')
    // 字幕缩放模式
    this.mediaPlayer.setOptions('option', 'sub-scale-by-window', 'true')
    // 字幕样式（从用户配置读取）
    this.mediaPlayer.setOptions('option', 'sub-font-size', this.appPrefer.getSubSize().toString())
    this.mediaPlayer.setOptions('option', 'sub-color', this.appPrefer.getSubColor())
    this.mediaPlayer.setOptions('option', 'sub-back-color', this.appPrefer.getSubShadowColor())
    this.mediaPlayer.setOptions('option', 'sub-shadow-offset', this.appPrefer.getSubShadowRadius().toString())
    this.mediaPlayer.setOptions('option', 'sub-pos', this.appPrefer.getSubVerticalPosition().toString())
    // 音频直通
    this.mediaPlayer.setOptions('option', 'audio-spdif', this.appPrefer.isAoSpdif() ? 'ac3,eac3,dts-hd,truehd' : '')
    // 解复用器缓冲
    this.mediaPlayer.setOptions('option', 'demuxer-max-bytes', `${64 * 1024 * 1024}`)
    this.mediaPlayer.setOptions('option', 'demuxer-max-back-bytes', `${32 * 1024 * 1024}`)
    // 日志级别
    this.mediaPlayer.setOptions('option', 'msg-level', `all=${BuildProfile.DEBUG ? 'debug' : 'warn'}`)

    this.mediaControl = new MediaControl(this.context.getHostContext()!, this.mediaPlayer)
    this.mediaControl.onPlaybackStateChange(this.playbackStateCallback)
    this.mediaControl.onMetadataChange(this.metadataCallback)
    this.mediaControl.onTrackInfoChange(this.trackCallback)
    this.mediaControl.setSkipInterval(this.appPrefer.getPlayerFastRewind(), this.appPrefer.getPlayerFastForward())
    this.mediaControl.queue.setMode(this.appPrefer.getPlayerLoopMode())

    // 画中画
    this.mediaPip = new MediaPip(this.context.getHostContext()!, this.mediaControl, (enter: boolean) => {
      if (enter) {
        AppRouter.goToPlayer(this.context)
      } else {
        AppRouter.goBack(this.context)
      }
    })
    this.mediaPip.onClose(() => {
      this.reportPlaybackStop()
      this.destroyPlayer()
    })
    this.mediaPip.setAutoStartEnabled(this.appPrefer.getPlayerAutoPip())

    AppStorage.setOrCreate(AppMediaControl.AV_CONTROL_KEY, this.mediaControl)

    this.mediaConfig = {
      loopMode: this.appPrefer.getPlayerLoopMode(),
      backgroundPlay: this.appPrefer.getPlayerBackPlay(),
      forwardStep: this.appPrefer.getPlayerFastForward(),
      backwardStep: this.appPrefer.getPlayerFastRewind(),
      gestureConfig: {
        dcForFR: this.appPrefer.getPlayerGestureDcFr(),
        slForVB: this.appPrefer.getPlayerGestureSlVb()
      },
      subConfig: {
        color: this.appPrefer.getSubColor(),
        size: this.appPrefer.getSubSize(),
        shadowRadius: this.appPrefer.getSubShadowRadius(),
        shadowColor: this.appPrefer.getSubShadowColor(),
        verticalPosition: this.appPrefer.getSubVerticalPosition()
      },
      callbacks: new Set([this.configCallback])
    }
  }

  public async destroyPlayer(): Promise<void> {
    AppStorage.delete(AppMediaControl.AV_CONTROL_KEY)
    try {
      this.mediaControl?.offMetadataChange(this.metadataCallback)
      this.mediaControl?.offPlaybackStateChange(this.playbackStateCallback)
      this.mediaControl?.offTrackInfoChange(this.trackCallback)
      await this.mediaControl?.reset()
      await this.mediaControl?.release()
    } catch (e) {
      if (BuildProfile.DEBUG) {
        console.error('AppMediaControl destroy control ' + JSON.stringify(e))
      }
    } finally {
      this.mediaControl = undefined
    }
    try {
      await this.mediaPip?.reset()
      await this.mediaPip?.release()
    } catch (e) {
      if (BuildProfile.DEBUG) {
        console.error('AppMediaControl destroy pip ' + JSON.stringify(e))
      }
    } finally {
      this.mediaPip = undefined
    }
    try {
      await this.mediaPlayer?.reset()
      await this.mediaPlayer?.release()
    } catch (e) {
      if (BuildProfile.DEBUG) {
        console.error('AppMediaControl destroy player ' + JSON.stringify(e))
      }
    } finally {
      this.mediaPlayer = undefined
    }
  }

  private async applyState() {
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

  public getPip(): MediaPip | undefined {
    return this.mediaPip
  }

  /**
   * 播放列表
   * @returns true=可以播放，false=繁忙
   */
  public playAll(items: Array<FinItem>, index: number = 0): boolean {
    if (this.mediaPlayer) {
      if (this.mediaPip?.isInPiP()) {
        this.replaceAndPlay(items, index)
        return true
      }
      return false
    }
    this.initPlayer()
    this.startPlay(items, index)
    return true
  }

  private async startPlay(items: Array<FinItem>, index: number): Promise<void> {
    let queueItemArray = this.buildQueueItems(items)
    try {
      await this.mediaControl!.session.setQueueItems(queueItemArray)
      await this.mediaControl!.playItem(items[index].id)
    } catch (e) {
      if (BuildProfile.DEBUG) {
        console.error('AppMediaControl startPlay ' + JSON.stringify(e))
      }
    }
  }

  private async replaceAndPlay(items: Array<FinItem>, index: number): Promise<void> {
    this.reportPlaybackStop()
    try {
      await this.mediaControl!.stop()
      let queueItemArray = this.buildQueueItems(items)
      await this.mediaControl!.setQueueItems(queueItemArray)
      await this.mediaControl!.playItem(items[index].id)
    } catch (e) {
      if (BuildProfile.DEBUG) {
        console.error('AppMediaControl replaceAndPlay ' + JSON.stringify(e))
      }
    }
    try {
      await this.mediaPip?.stopPiP()
    } catch (e) {
      if (BuildProfile.DEBUG) {
        console.error('AppMediaControl stopPiP ' + JSON.stringify(e))
      }
    }
  }

  private buildQueueItems(items: Array<FinItem>): Array<avSession.AVQueueItem> {
    let queueItemArray = new Array<avSession.AVQueueItem>()
    items.forEach((item: FinItem, i: number) => {
      let extra: Record<string, Object> = {}
      queueItemArray.push({
        itemId: i,
        description: {
          assetId: item.id,
          title: item.name,
          description: item.overview,
          mediaUri: item.id,
          mediaImage: item.type === FinItemType.Episode
            ? item.image?.primary : item.image?.backdrop,
          mediaType: 'video',
          startPosition: item.data?.playedPositionTicks,
          duration: item.runtimeTicks,
          extras: extra
        }
      })
    })
    return queueItemArray
  }

  private skipNextOrExit() {
    if (!this.mediaControl) return
    if (this.mediaControl.queue.getMode() === avSession.LoopMode.LOOP_MODE_SINGLE) {
      this.mediaControl.seek(0)
      this.mediaControl.play()
      return
    }
    this.reportPlaybackStop()
    if (this.appPrefer.getPlayerAutoNext() && this.mediaControl.queue.canSkipNext()) {
      this.mediaControl.next()
    } else {
      this.context.getRouter().back()
    }
  }

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

  private updateSubStyle() {
    if (!this.mediaConfig?.subConfig) return
    let sub = this.mediaConfig.subConfig
    this.appPrefer.setSubSize(sub.size)
    this.appPrefer.setSubColor(sub.color)
    this.appPrefer.setSubShadowRadius(sub.shadowRadius)
    this.appPrefer.setSubShadowColor(sub.shadowColor)
    this.appPrefer.setSubVerticalPosition(sub.verticalPosition)
    this.appPrefer.flush()
  }

  private reportPlaybackStart() {
    if (!this.mediaControl || !this.avMetadata) return
    this.reportingPlayback = true
    this.repository.onPlaybackStart(this.avMetadata.assetId)
      .then(() => { this.reportingPlayback = false })
      .catch((_e: Error) => { this.reportingPlayback = false })
  }

  private reportPlaybackUpdate(force: boolean) {
    if (!this.mediaControl || !this.avMetadata || !this.progress) return
    if (!force && Math.abs(this.progress - (this.reportPosition || 0)) < 5000) return
    this.reportingPlayback = true
    this.reportPosition = this.progress
    this.repository.onPlaybackProgress(this.avMetadata.assetId, this.reportPosition, this.mediaControl.isPlaying())
      .then(() => { this.reportingPlayback = false })
      .catch((_e: Error) => { this.reportingPlayback = false })
  }

  private reportPlaybackStop() {
    if (!this.mediaControl || !this.avMetadata) return
    this.reportingPlayback = true
    this.repository.onPlaybackStopped(this.avMetadata.assetId, this.reportPosition || 0)
      .then(() => { this.reportingPlayback = false })
      .catch((_e: Error) => { this.reportingPlayback = false })
  }

  public async release(): Promise<void> {
    observer.off('routerPageUpdate', this.context.getHostContext() as common.UIAbilityContext, this.routerCallback)
  }

}
