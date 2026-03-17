import { display, window } from '@kit.ArkUI'
import { DeviceUtil } from '@ohpg/fin-framework'
import { AvoidAreaSystem } from '@ohpg/fin-core'
import { CommonConstants } from '../common/CommonConstants'
import { deviceInfo } from '@kit.BasicServicesKit'
import { KeyCode } from '@kit.InputKit'
import { AVPlayerView, MediaControl } from '@ohpg/player'
import { AppPlayer } from '../../player/AppPlayer'

@Entry
@Component
struct PlayerPage {
  
  private currenWindow = AppStorage.get<window.Window>(AvoidAreaSystem.CURRENT_WINDOW)!

  private readonly avControl: MediaControl = AppStorage.get(AppPlayer.MEDIA_CONTROL)!

  private readonly appPlayer: AppPlayer = AppStorage.get(AppPlayer.APP_PLAYER)!

  private windowStatusCallback?: Callback<WindowStatusType> = undefined

  private preferOrientation?: number

  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  aboutToAppear(): void {
    DeviceUtil.restoreUserBrightness()
    this.currenWindow.setWindowSystemBarEnable([])
    let orientation = display.getDefaultDisplaySync().orientation
    if (orientation == display.Orientation.LANDSCAPE
      || orientation === display.Orientation.LANDSCAPE_INVERTED) {
      this.preferOrientation = undefined
    } else {
      this.preferOrientation = this.currenWindow.getPreferredOrientation()
      this.currenWindow.setPreferredOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE)
    }
    if (deviceInfo.deviceType === "2in1") {
      this.update2in1Window()
      this.windowStatusCallback = (type) => {
        this.update2in1Window()
      }
      this.currenWindow.on("windowStatusChange", this.windowStatusCallback)
    }
  }

  /**
   * 只有2合一才支持此共功能。
   */
  private update2in1Window() {
    if (deviceInfo.deviceType !== "2in1") return
    if (this.currenWindow.getWindowStatus() === window.WindowStatusType.MAXIMIZE) {
      this.currenWindow.maximize(window.MaximizePresentation.ENTER_IMMERSIVE)
    }
  }

  build() {
    Stack() {
      AVPlayerView({
        control: this.avControl,
        config: this.appPlayer.getPlayerConfig()
      })
    }
    .onKeyEvent((event): Boolean => {
      return this.onPageKeyEvent(event)
    })
    .backgroundColor($r('sys.color.black'))
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

  private onPageKeyEvent(event: KeyEvent): boolean {
    if (event.type == KeyType.Up) {
      if (event.keyCode === KeyCode.KEYCODE_ESCAPE) {
        let windowStatus = this.currenWindow.getWindowStatus()
        if (windowStatus === window.WindowStatusType.FULL_SCREEN) {
          this.currenWindow.recover()
        } else {
          // ignore
        }
      } else if (event.keyCode === KeyCode.KEYCODE_ENTER) {
        if (deviceInfo.deviceType === "2in1") {
          this.currenWindow.maximize(window.MaximizePresentation.ENTER_IMMERSIVE)
        }
      }
    }
    return true
  }

  aboutToDisappear(): void {
    if (this.windowStatusCallback) {
      this.currenWindow.off("windowStatusChange", this.windowStatusCallback)
    }
    this.currenWindow.setWindowSystemBarEnable(['status', 'navigation'])
    if (this.preferOrientation !== undefined) {
      this.currenWindow.setPreferredOrientation(this.preferOrientation)
    }
    DeviceUtil.restoreDefaultBrightness(getContext())
  }

}