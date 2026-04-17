import { display, window } from '@kit.ArkUI'
import { deviceInfo } from '@kit.BasicServicesKit'
import { KeyCode } from '@kit.InputKit'
import { AVOrientation, AVPlayerView, MediaControl } from '@ohpg/player'
import { DeviceUtil } from '@ohpg/fin-framework'
import { AvoidAreaSystem } from '@ohpg/fin-core'
import { CommonConstants } from '../common/CommonConstants'
import { AppMediaControl } from '../../player/AppMediaControl'
import { AppPrefer } from '../../prefer/AppPrefer'
import { RotationType } from '../../enum/RotationType'
import { avSession } from '@kit.AVSessionKit'
import { GestureGuide } from '../../widget/comp/GestureGuide'

@Entry
@Component
struct PlayerPage {

  private avControl?: MediaControl

  private readonly currentWindow = AppStorage.get<window.Window>(AvoidAreaSystem.CURRENT_WINDOW)!

  private appMediaControl?: AppMediaControl

  @StorageLink('prefer') appPrefer?: AppPrefer = undefined

  private windowStatusCallback?: Callback<WindowStatusType> = undefined

  @StorageProp('currentAvoidArea') avoidArea?: window.AvoidArea = undefined

  private avOrientation?: AVOrientation

  private prepared: boolean = false

  private keyEventSet: Set<Callback<KeyEvent, boolean>> = new Set()

  @State gestureGuideFinished: boolean = false

  private stateChangeCallback: Callback<avSession.AVPlaybackState> = (state) => {
    this.updatePlaybackState(state)
  }

  aboutToAppear(): void {
    this.avControl = AppStorage.get<MediaControl>(AppMediaControl.AV_CONTROL_KEY)
    this.appMediaControl = AppStorage.get<AppMediaControl>(AppMediaControl.MEDIA_CONTROL_KEY)

    this.gestureGuideFinished = (this.appPrefer?.isPlayerGestureGuideFinished() ?? false)
      || deviceInfo.deviceType === 'tv'

    this.avOrientation = new AVOrientation(this.currentWindow)
    this.avOrientation.save()

    let userRotation = this.appPrefer?.getPlayerRotation()
    if (userRotation === RotationType.FORCE_PORTRAIT) {
      this.avOrientation.setOrientation(display.Orientation.PORTRAIT)
    } else if (userRotation === RotationType.FORCE_LANDSCAPE) {
      this.avOrientation.setOrientation(display.Orientation.LANDSCAPE)
    } else if (userRotation === RotationType.FOLLOW_VIDEO) {
      this.updateWindowOrientation()
    }

    if (deviceInfo.deviceType === '2in1') {
      this.update2in1Window()
      this.windowStatusCallback = (_type) => {
        this.update2in1Window()
      }
      this.currentWindow.on('windowStatusChange', this.windowStatusCallback)
    }

    let state = this.avControl?.getPlaybackState()
    if (state) {
      this.updatePlaybackState(state)
    }
    this.avControl?.onPlaybackStateChange(this.stateChangeCallback)

    DeviceUtil.restoreUserBrightness()
  }

  private updatePlaybackState(state: avSession.AVPlaybackState) {
    let prepared = state.state
      && state.state >= avSession.PlaybackState.PLAYBACK_STATE_PREPARE
      && state.state <= avSession.PlaybackState.PLAYBACK_STATE_REWIND
      ? true : false
    if (this.prepared !== prepared) {
      this.prepared = prepared
      if (this.prepared) {
        this.updateWindowOrientation()
      }
    }
  }

  private update2in1Window() {
    if (deviceInfo.deviceType !== '2in1') return
    if (this.currentWindow.getWindowStatus() === window.WindowStatusType.MAXIMIZE) {
      this.currentWindow.maximize(window.MaximizePresentation.ENTER_IMMERSIVE)
    }
  }

  private updateWindowOrientation() {
    let userRotation = this.appPrefer?.getPlayerRotation()
    if (userRotation !== RotationType.FOLLOW_VIDEO) return
    if (!this.avControl?.isPrepared()) return
    let width = this.avControl?.getWidth()
    let height = this.avControl?.getHeight()
    if (width && height) {
      if (width > height) {
        this.avOrientation?.setOrientation(display.Orientation.LANDSCAPE)
      } else {
        this.avOrientation?.setOrientation(display.Orientation.PORTRAIT)
      }
    }
  }

  build() {
    Stack() {
      AVPlayerView({
        control: this.avControl,
        pip: this.appMediaControl?.getPip(),
        config: this.appMediaControl?.getPlayerConfig(),
        keyEvent: this.keyEventSet
      })

      Stack() {
        GestureGuide({ callback: () => {
          this.gestureGuideFinished = true
          this.appPrefer?.setGestureGuideFinished()
        }})
      }
      .visibility(this.gestureGuideFinished ? Visibility.None : Visibility.Visible)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .onKeyEvent((event): Boolean => {
      return this.onPageKeyEvent(event)
    })
    .backgroundColor($r('sys.color.black'))
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

  private onPageKeyEvent(event: KeyEvent): boolean {
    for (const callback of this.keyEventSet) {
      let result = callback(event)
      if (result) return true
    }
    if (event.type == KeyType.Up) {
      if (event.keyCode === KeyCode.KEYCODE_ESCAPE) {
        let windowStatus = this.currentWindow.getWindowStatus()
        if (windowStatus === window.WindowStatusType.FULL_SCREEN) {
          this.currentWindow.recover()
        }
      } else if (event.keyCode === KeyCode.KEYCODE_ENTER) {
        if (deviceInfo.deviceType === '2in1') {
          this.currentWindow.maximize(window.MaximizePresentation.ENTER_IMMERSIVE)
        }
      }
    }
    return event.keyCode === KeyCode.KEYCODE_ESCAPE || event.keyCode === KeyCode.KEYCODE_ENTER
  }

  onBackPress(): boolean | void {
    if (!this.gestureGuideFinished) {
      return true
    }
    return false
  }

  aboutToDisappear(): void {
    this.avControl?.offPlaybackStateChange(this.stateChangeCallback)
    if (this.windowStatusCallback) {
      this.currentWindow.off('windowStatusChange', this.windowStatusCallback)
    }
    this.keyEventSet.clear()
    this.avOrientation?.restore()
    DeviceUtil.restoreDefaultBrightness(getContext())
  }

}
