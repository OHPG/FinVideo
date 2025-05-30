import { display, promptAction, router, window } from '@kit.ArkUI'
import { DeviceUtil, Option, OptionDialog } from '@ohpg/fin-framework'
import { AvoidAreaSystem } from '@ohpg/fin-core'
import { CommonConstants } from '../common/CommonConstants'
import { PlayerViewModel } from './PlayerViewModel'
import { PlayerArgs } from './PlayerArgs'
import { TimeTool } from '@ohpg/fin-core'
import { media } from '@kit.MediaKit'
import { BaseItemDto, MediaSourceType, MediaStreamType, VideoRange, VideoRangeType } from '@ohpg/jellyfin'
import { AbstractController } from '../../player/AbstractController'
import { WLController } from '../../player/WLController'
import { AVController } from '../../player/AVController'
import { AVVolumePanel } from '@kit.AudioKit'
import { AppPrefer } from '../../prefer/AppPrefer'
import { PlayerImpl } from '../../player/PlayerImpl'

@Entry
@Component
struct PlayerPage {
  
  private args = router.getParams() as PlayerArgs

  private currenWindow = AppStorage.get<window.Window>(AvoidAreaSystem.CURRENT_WINDOW)!

  private appPrefer: AppPrefer = AppStorage.get(AppPrefer.PREFER)!
  
  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  private readonly viewModel = new PlayerViewModel(getContext(), this.args)

  private preferOrientation?: number

  private itemDto?: BaseItemDto

  private videoController?: AbstractController = undefined

  @State videoControllerReady :boolean = false

  @State loading: boolean = false

  @State state: media.AVPlayerState = 'idle'

  private shouldResumePlay = false

  @State prepared: boolean = false

  @State progress: number = -1

  @State duration: number = -1

  @State ui: boolean = true

  private uiTimeoutId?: number

  @State locked: boolean = false

  private saveSpeed?: media.PlaybackSpeed = undefined

  @State gesturing: boolean = false

  @State gestureSpeed?: string = undefined

  private gestureInitValue: number = 0

  @State gestureBrightness: boolean = false

  @State gestureBrightnessValue: number = 0

  private volumePosition?: Position

  // Note:
  // If show AVVolumePanel when gesture, the volume ui may not show.
  @State gestureVolume: boolean = false

  @State gestureVolumeValue: number = 0

  private gestureForwardOrBackwardTimeoutId?: number = undefined

  @State gestureForward?: number = undefined

  @State gestureBackward?: number = undefined

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
    this.initData()
  }

  private initData() {
    this.loading = true
    this.viewModel.loadData()
      .then((item) => {
        let sdr = true
        item.MediaSources?.[0].MediaStreams?.forEach((source) => {
          if (source.Type === MediaStreamType.Video) {
            if (source.VideoRangeType) {
              sdr = source.VideoRangeType === VideoRangeType.Sdr
                || source.VideoRangeType == VideoRangeType.Unknown
            } else if (source.VideoRange) {
              sdr = source.VideoRange !== VideoRange.Hdr
            }
          }
        })
        this.itemDto = item
        this.initPlayer(!sdr)
        this.videoController!.setData(item)
      })
      .catch((error: Error) => {
        this.itemDto = undefined
        this.loading = false
        promptAction.showToast({message: "加载失败，" + error.message})
      })
  }
  
  private initPlayer(hdr: boolean) {
    let impl = this.appPrefer.getPlayerImpl()
    if (impl == PlayerImpl.AVPlayer) {
      this.videoController = new AVController(getContext())
    } else if (impl === PlayerImpl.WL_MEDIA){
      this.videoController = new WLController(getContext())
    } else {
      this.videoController = hdr ? new AVController(getContext()) : new WLController(getContext())
    }
    console.log("create player: " + this.videoController.getName())
    this.videoControllerReady = true
    this.videoController.onProgressChange((progress) => {
      this.progress = progress
    })
    this.videoController.onStateChange((state, reason) => {
      this.state = state
      DeviceUtil.setWindowKeepScreenState(state === 'playing')
      if (state === 'playing') {
        this.addUITimeout()
      } else {
        this.clearUITimeout()
      }
      if (state === 'idle') {

      } else if (state === 'initialized') {
        this.videoController!.prepare()
      } else if (state === 'prepared') {
        this.loading = false
        this.prepared = true
        this.duration = this.videoController!.getDuration()
        this.videoController!.start()
      } else if (state === "playing") {
      } else if (state === 'paused') {
      } else if (state === 'completed') {
        router.back()
      } else if (state === 'stopped') {
        this.prepared = false
      } else if (state === 'released') {
        this.prepared = false
      } else if (state === 'error') {
        this.loading = false
        this.prepared = false
      }
    })
    this.videoController.onError((error) => {
      this.loading = false
      promptAction.showToast({message: "播放失败，" + error.code + "：" + error.message})
    })
  }

  build() {
    Stack() {
      // video
      if (this.videoControllerReady) {
        XComponent({
          id: "player_surface",
          type: XComponentType.SURFACE,
          controller: this.videoController
        })
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
      }

      // gesture
      if (!this.locked) {
        RelativeContainer() {

          // speed
          if (this.gestureSpeed) {
            Row({space: 6}) {
              SymbolGlyph($r('sys.symbol.fast_forward'))
                .fontSize(48)
                .fontColor([$r('sys.color.font_on_primary')])
              Text(this.gestureSpeed)
                .fontSize(20)
                .fontColor($r('sys.color.font_on_primary'))
            }
            .width('auto')
            .height('auto')
            .alignRules({
              middle: {
                anchor: "__container__",
                align: HorizontalAlign.Center
              },
              top: {
                anchor: "__container__",
                align: VerticalAlign.Top
              },
              bottom: {
                anchor: "__container__",
                align: VerticalAlign.Center
              }
            })
          }

          // backward
          if (this.gestureBackward) {
            SymbolGlyph($r('sys.symbol.gobackward_30'))
              .fontSize(48)
              .fontColor([$r('sys.color.font_on_primary')])
              .width('auto')
              .height('auto')
              .alignRules({
                center: {
                  anchor: "__container__",
                  align: VerticalAlign.Center
                },
                start: {
                  anchor: "__container__",
                  align: HorizontalAlign.Start
                },
                end: {
                  anchor: "__container__",
                  align: HorizontalAlign.Center
                }
              })
          }

          // forward
          if (this.gestureForward) {
            SymbolGlyph($r('sys.symbol.goforward_30'))
              .fontSize(48)
              .fontColor([$r('sys.color.font_on_primary')])
              .width('auto')
              .height('auto')
              .alignRules({
                center: {
                  anchor: "__container__",
                  align: VerticalAlign.Center
                },
                start: {
                  anchor: "__container__",
                  align: HorizontalAlign.Center
                },
                end: {
                  anchor: "__container__",
                  align: HorizontalAlign.End
                }
              })
          }

          // light
          if (this.gestureBrightness) {
            Stack({alignContent: Alignment.Bottom}) {
              Slider({value: this.gestureBrightnessValue, max: 1, min: 0
              , reverse: true, style: SliderStyle.NONE, direction: Axis.Vertical})
                .trackThickness(40)
                .selectedColor(Color.White)
                .height(160)
                .width(40)

              SymbolGlyph($r('sys.symbol.sun_max_fill'))
                .fontColor([(Color.Gray)])
                .margin({bottom: 8})
                .fontSize(22)
            }
            .width('auto')
            .height('auto')
            .alignRules({
              center: {
                anchor: "__container__",
                align: VerticalAlign.Center
              },
              start: {
                anchor: "__container__",
                align: HorizontalAlign.Center
              },
              end: {
                anchor: "__container__",
                align: HorizontalAlign.End
              }
            })
          }

          // volume
          if (this.gestureVolume) {
            AVVolumePanel({
              volumeLevel: this.gestureVolumeValue * DeviceUtil.MAX_VOLUME,
              volumeParameter: {
                position: this.volumePosition
              }
            })
          }

        }
          .gesture(GestureGroup(GestureMode.Exclusive,
            // forward & backward
            TapGesture({ count: 2 })
              .onAction((event) => {
                if (this.videoController === undefined || this.state !== 'playing') {
                  return
                }
                let width = event.target.area.width as number
                let x = event.fingerList[0].localX as number
                let position = this.videoController!.getPosition()
                if (x > width / 2) {
                  this.gestureForward = 30
                  position += this.gestureForward * 1000
                } else {
                  this.gestureBackward = 30
                  if (position < 30 * 1000) {
                    position = 0
                  } else {
                    position -= this.gestureBackward * 1000
                  }
                }
                if (this.gestureForwardOrBackwardTimeoutId !== undefined) {
                  clearTimeout(this.gestureForwardOrBackwardTimeoutId)
                }
                this.gestureForwardOrBackwardTimeoutId = setTimeout(() => {
                  this.gestureForward = undefined
                  this.gestureBackward = undefined
                  this.gestureForwardOrBackwardTimeoutId = undefined
                }, 600)
                this.videoController!.seek(position)
              }),

            // speedup
            LongPressGesture()
              .onAction((event) => {
                if (this.videoController == undefined || this.state !== 'playing') {
                  return
                }
                let speed = this.videoController!.getSpeed()
                if (speed === media.PlaybackSpeed.SPEED_FORWARD_3_00_X) {
                  return
                }
                this.saveSpeed = speed
                this.gesturing = true
                if (this.saveSpeed === media.PlaybackSpeed.SPEED_FORWARD_2_00_X) {
                  this.gestureSpeed = "3x"
                  this.videoController!.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_3_00_X)
                } else {
                  this.videoController!.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X)
                  this.gestureSpeed = "2x"
                }
              })
              .onActionEnd((event) => {
                this.gesturing = false
                if (this.saveSpeed === undefined) {
                  return
                }
                this.videoController?.setSpeed(this.saveSpeed)
                this.saveSpeed = undefined
                this.gestureSpeed = undefined
              }),

            // brightness&volume
            PanGesture({fingers: 1, direction: PanDirection.Vertical})
              .onActionStart((event) => {
                let width = event.target.area.width as number
                let x = event.fingerList[0].localX as number
                if (x > width / 2) {
                  // https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-video-playback-development-practice#section1877775522017
                  this.gestureInitValue = DeviceUtil.getVolume() / DeviceUtil.MAX_VOLUME
                  this.gestureVolume = true
                } else {
                  this.gestureBrightness = true
                  // https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-page-brightness-settings#section02121449165218
                  let brightness = DeviceUtil.getBrightness(getContext())
                  this.gestureInitValue = brightness
                }
                this.gestureBrightnessValue = this.gestureInitValue
                this.gesturing = true
              })
                // 当触发拖动手势时，根据回调函数修改组件的布局位置信息
              .onActionUpdate((event) => {
                let offset = -event.offsetY / 200
                let newValue = this.gestureInitValue + offset
                if (newValue < 0) {
                  newValue = 0
                }
                if (newValue > 1) {
                  newValue = 1
                }
                if (this.gestureBrightness) {
                  DeviceUtil.setBrightness(getContext(), newValue)
                  this.gestureBrightnessValue = newValue
                } else {
                  this.gestureVolumeValue = newValue
                }
              })
              .onActionEnd((event) => {
                this.gesturing = false
                this.gestureVolume = false
                this.gestureBrightness = false
              }),
            // scale type
            PinchGesture({fingers: 2})
              .onActionEnd((event) => {
                this.videoController?.setFitType(event.scale > 1
                  ? 'Crop'
                  : 'Inside')
              })
          ))
        .onSizeChange((oldValue, newValue) => {
          this.volumePosition = {
            x: vp2px(newValue.width as number / 4 - 10),
            y: vp2px(newValue.height as number / 2 - 80 - 10)
          }
        })
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
      }

      // controller
      if (this.ui && !this.locked && !this.gesturing) {
        RelativeContainer() {
          // top
          Row({space: CommonConstants.SPACE_16}) {
            Image($r('sys.media.ohos_ic_back'))
              .id("toolbar_icon")
              .fillColor($r('sys.color.font_on_primary'))
              .width($r('sys.float.ohos_id_toolbar_item_icon_size'))
              .height($r('sys.float.ohos_id_toolbar_item_icon_size'))
              .onClick(() => {
                router.back()
              })

            Text(this.args.name)
              .fontSize($r('sys.float.titlebar_title_secondary_size'))
              .fontColor($r('sys.color.font_on_primary'))

            Blank()

            SymbolGlyph($r('sys.symbol.lock_open'))
              .fontSize(28)
              .fontColor([$r('sys.color.font_on_primary')])
              .onClick(() => {
                this.lock()
              })

            // SymbolGlyph($r('sys.symbol.dual_view_PIP'))
            //   .fontSize(28)
            //   .fontColor([$r('sys.color.font_on_primary')])
            //   .onClick(() => {
            //     this.pip()
            //   })

            SymbolGlyph($r('sys.symbol.speed_multiple'))
              .fontSize(28)
              .fontColor([$r('sys.color.font_on_primary')])
              .enabled(this.prepared)
              .onClick(() => {
                this.chooseSpeed()
              })

            SymbolGlyph($r('sys.symbol.AI_sound'))
              .fontSize(28)
              .fontColor([$r('sys.color.font_on_primary')])
              .enabled(this.prepared)
              .onClick(() => {
                this.chooseAudioTrack()
              })

            SymbolGlyph($r('sys.symbol.AI_subtitles'))
              .fontSize(28)
              .fontColor([$r('sys.color.font_on_primary')])
              .enabled(this.prepared)
              .onClick(() => {
                this.chooseSubtitleTrack()
              })

          }
          .height($r('sys.float.ohos_id_navigation_bar_height'))
          .alignRules({
            left: {
              anchor: '__container__',
              align: HorizontalAlign.Start
            },
            right: {
              anchor: '__container__',
              align: HorizontalAlign.End
            },
            top: {
              anchor: '__container__',
              align: VerticalAlign.Top
            }
          })

          if (this.loading) {
            LoadingProgress()
              .width(48)
              .height(48)
              .alignRules({
                center: {
                  anchor: '__container__',
                  align: VerticalAlign.Center
                },
                middle: {
                  anchor: '__container__',
                  align: HorizontalAlign.Center
                }
              })
          } else {
            // center
            Row({space: 32}) {

              // Image($r('sys.media.ohos_ic_public_play_last'))
              //   .fillColor($r('sys.color.font_on_primary'))
              //   .width(32)
              //   .height(32)

              Image(this.state === 'playing' ? $r('sys.media.ohos_ic_public_pause') : $r('sys.media.ohos_ic_public_play'))
                .fillColor($r('sys.color.font_on_primary'))
                .width(48)
                .height(48)
                .onClick(() => {
                  if (this.itemDto) {
                    if (this.state === 'playing') {
                      this.videoController?.pause()
                    } else {
                      this.videoController?.start()
                    }
                  } else {
                    this.initData()
                  }
                })

              // Image($r('sys.media.ohos_ic_public_play_next'))
              //   .fillColor($r('sys.color.font_on_primary'))
              //   .width(32)
              //   .height(32)

            }
            .alignRules({
              center: {
                anchor: '__container__',
                align: VerticalAlign.Center
              },
              middle: {
                anchor: '__container__',
                align: HorizontalAlign.Center
              }
            })
          }

          // bottom
          Column({space: CommonConstants.SPACE_4}) {
            Row() {
              Text(TimeTool.formatMillionSecondsToHMS(this.progress))
                .fontColor($r('sys.color.font_on_primary'))
              Blank()
                .layoutWeight(1)
              Text(TimeTool.formatMillionSecondsToHMS(this.duration))
                .fontColor($r('sys.color.font_on_primary'))
            }
            .width('auto')
            Slider({
              value: this.progress > 0 ? this.progress : 0,
              max: this.duration > 0 ? this.duration : 100
            })
              .enabled(this.prepared)
              .onChange((num, mode) => {
                if (this.duration > 0 && mode === SliderChangeMode.End) {
                  this.videoController?.seek(num)
                }
              })
          }
          .width(CommonConstants.FULL_PERCENT)
          .height('auto')
          .alignRules({
            left: {
              anchor: '__container__',
              align: HorizontalAlign.Start
            },
            right: {
              anchor: '__container__',
              align: HorizontalAlign.End
            },
            bottom: {
              anchor: '__container__',
              align: VerticalAlign.Bottom
            }
          })
        }
        .padding({
          left: Math.max(px2vp(this.avoidArea?.leftRect.width), CommonConstants.SPACE_16),
          top: Math.max(px2vp(this.avoidArea?.topRect.height), CommonConstants.SPACE_16),
          right: Math.max(px2vp(this.avoidArea?.rightRect.width), CommonConstants.SPACE_16),
          bottom: Math.max(px2vp(this.avoidArea?.bottomRect.height), CommonConstants.SPACE_16)
        })
        .hitTestBehavior(HitTestMode.Transparent)
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
      }

      // lock
      if (this.ui && this.locked) {
        Stack({alignContent: Alignment.End}) {
          SymbolGlyph($r('sys.symbol.lock'))
            .fontSize(32)
            .fontColor([$r('sys.color.font_on_primary')])
            .alignRules({
              center: {
                anchor: '__container__',
                align: VerticalAlign.Center
              },
              right: {
                anchor: '__container__',
                align: HorizontalAlign.End
              }
            })
            .margin(CommonConstants.SPACE_16)
            .onClick(() => {
              this.unlock()
            })
        }
        .hitTestBehavior(HitTestMode.Default)
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
      }
    }
    .onClick(() => {
      this.toggleUI()
    })
    .backgroundColor($r('sys.color.black'))
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

  onPageShow(): void {
    this.ui = true
    if (this.shouldResumePlay) {
      this.videoController?.start()
    }
    this.shouldResumePlay = false
    this.addUITimeout()
  }

  private clearUITimeout() {
    if (this.uiTimeoutId !== undefined) {
      clearTimeout(this.uiTimeoutId)
      this.uiTimeoutId = undefined
    }
  }

  private addUITimeout() {
    this.clearUITimeout()
    if (this.ui && this.state === 'playing') {
        this.uiTimeoutId = setTimeout(() => {
          this.ui = false
          this.uiTimeoutId = undefined
        }, 3000)
    }
  }

  private toggleUI() {
    this.ui = !this.ui
    this.addUITimeout()
  }

  private lock() {
    this.locked = true
  }

  private unlock() {
    this.locked = false
  }

  private pip() {

  }

  private chooseSpeed() {
    let speedModeArray = [media.PlaybackSpeed.SPEED_FORWARD_0_50_X
      , media.PlaybackSpeed.SPEED_FORWARD_0_75_X
      , media.PlaybackSpeed.SPEED_FORWARD_1_00_X
      , media.PlaybackSpeed.SPEED_FORWARD_1_50_X
      , media.PlaybackSpeed.SPEED_FORWARD_1_75_X
      , media.PlaybackSpeed.SPEED_FORWARD_2_00_X
      , media.PlaybackSpeed.SPEED_FORWARD_3_00_X]
    let speedNameArray = ["0.5x", "0.75x", "1.0x", "1.5x", "1.75x", "2.0x", "3.0x"]
    let speedDialog = new OptionDialog(this.getUIContext())
    let currentSpeed = this.videoController!.getSpeed()
    speedDialog.setTitle($r('app.string.player_select_speed_title'))
    let optionArray = new Array<Option>()
    speedNameArray.forEach((value, index) => {
      optionArray.push({
        title: value,
        checked: currentSpeed === speedModeArray[index]
      })
    })
    speedDialog.setOptions(optionArray)
    speedDialog.setOptionCallback((index) => {
      this.videoController!.setSpeed(speedModeArray[index])
    })
    speedDialog.show()
  }

  private async chooseAudioTrack() {
    this.chooseTrack(media.MediaType.MEDIA_TYPE_AUD)
  }

  private async chooseSubtitleTrack() {
    this.chooseTrack(media.MediaType.MEDIA_TYPE_SUBTITLE)
  }

  private async chooseTrack(type: media.MediaType) {
    let selectedTrack = await this.videoController!.getCurrentTrack(type)
    let trackArray = await this.videoController!.getTrackInfo(type)
    if (trackArray.length <= 0) {
      this.getUIContext().getPromptAction().showToast({message: type === media.MediaType.MEDIA_TYPE_SUBTITLE
        ? $r('app.string.player_no_subtitle_track') : $r('app.string.player_no_audio_track')})
      return
    }
    let title = type === media.MediaType.MEDIA_TYPE_SUBTITLE
      ? $r('app.string.player_subtitle_track_title')
      : $r('app.string.player_audio_track_title')
    let optionArray = new Array<Option>()
    trackArray.forEach((track) => {
      let index = track[media.MediaDescriptionKey.MD_KEY_TRACK_INDEX] as number
      optionArray.push({
        title: track[media.MediaDescriptionKey.MD_KEY_TRACK_NAME] as string
          + "-"
          + track[media.MediaDescriptionKey.MD_KEY_CODEC_MIME],
        checked: selectedTrack == index
      })
    })
    let trackDialog = new OptionDialog(this.getUIContext())
    trackDialog.setTitle(title)
    trackDialog.setOptions(optionArray)
    trackDialog.setOptionCallback((index) => {
      let track = trackArray[index]
      let trackIndex = track[media.MediaDescriptionKey.MD_KEY_TRACK_INDEX] as number
      this.videoController!.selectTrack(type, trackIndex)
    })
    await trackDialog.show()
  }

  onPageHide(): void {
    if (this.state === 'playing' && this.videoController) {
      this.videoController!.pause()
      this.shouldResumePlay = true
    }
  }

  aboutToDisappear(): void {
    this.clearUITimeout()
    this.videoController?.offStateChange()
    this.videoController?.offError()
    this.videoController?.release()
    this.currenWindow.setWindowSystemBarEnable(['status', 'navigation'])
    if (this.preferOrientation !== undefined) {
      this.currenWindow.setPreferredOrientation(this.preferOrientation)
    }
    DeviceUtil.restoreDefaultBrightness(getContext())
  }

}