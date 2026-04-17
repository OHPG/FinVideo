import { window } from '@kit.ArkUI'
import { CommonConstants, ToolBar } from '@ohpg/fin-framework'
import { MarketUtil } from '@ohpg/fin-core'
import { common } from '@kit.AbilityKit'
import { AppPrefer } from '../../prefer/AppPrefer'
import { RotationType } from '../../enum/RotationType'
import { AVCodecType, AVRenderType } from '@ohpg/player'
import { OperationItem } from '../../widget/comp/OperationItem'
import { groupAttributeModifier, itemDividerBuilder, windowAttributeModifier } from '../../style/Modifier'
import { deviceInfo } from '@kit.BasicServicesKit'

@Entry
@Component
struct VideoSettingPage {

  @StorageProp('currentAvoidArea') avoidArea?: window.AvoidArea = undefined

  private appPrefer: AppPrefer = AppStorage.get(AppPrefer.PREFER)!

  @State autoNext: boolean = true

  @State backPlay: boolean = false

  @State autoPip: boolean = false

  @State forwardRewindDC: boolean = true

  @State volumeBrightnessSL: boolean = true

  @State aoSpdif: boolean = false

  @State rotation: RotationType = RotationType.FOLLOW_WINDOW

  private rotationArray: Array<SelectOption> = [
    { value: $r('app.string.prefer_video_rotation_keep') },
    { value: $r('app.string.prefer_video_rotation_portrait') },
    { value: $r('app.string.prefer_video_rotation_landscape') },
    { value: $r('app.string.prefer_video_rotation_video') }
  ]

  @State fastForward: number = 30

  @State fastRewind: number = 30

  private fastInterval: Array<number> = [5, 10, 15, 30, 45, 60]

  private fastIntervalOption: Array<SelectOption> = [
    { value: $r('app.string.prefer_video_rotation_fast_5') },
    { value: $r('app.string.prefer_video_rotation_fast_10') },
    { value: $r('app.string.prefer_video_rotation_fast_15') },
    { value: $r('app.string.prefer_video_rotation_fast_30') },
    { value: $r('app.string.prefer_video_rotation_fast_45') },
    { value: $r('app.string.prefer_video_rotation_fast_60') }
  ]

  private voDescArray: Array<ResourceStr> = [
    $r('app.string.player_video_vo_embed_desc'),
    $r('app.string.player_video_vo_gpu_desc'),
    $r('app.string.player_video_vo_gpu_next_desc')
  ]

  private voArray: Array<SelectOption> = [
    { value: $r('app.string.player_video_vo_embed') },
    { value: $r('app.string.player_video_vo_gpu') },
    { value: $r('app.string.player_video_vo_gpu_next') }
  ]

  @State voIndex: number = AVRenderType.GPU

  private codecPreferValues: Array<number> = [AVCodecType.HW, AVCodecType.HW_PLUS, AVCodecType.SW]

  private codecPreferArray: Array<SelectOption> = [
    { value: $r('app.string.prefer_video_codec_hw') },
    { value: $r('app.string.prefer_video_codec_hw_plus') },
    { value: $r('app.string.prefer_video_codec_sw') }
  ]

  @State codecPreferIndex: number = 0

  aboutToAppear(): void {
    this.autoNext = this.appPrefer.getPlayerAutoNext()
    this.backPlay = this.appPrefer.getPlayerBackPlay()
    this.autoPip = this.appPrefer.getPlayerAutoPip()
    this.forwardRewindDC = this.appPrefer.getPlayerGestureDcFr()
    this.volumeBrightnessSL = this.appPrefer.getPlayerGestureSlVb()
    this.aoSpdif = this.appPrefer.isAoSpdif()
    this.rotation = this.appPrefer.getPlayerRotation()
    this.fastForward = this.appPrefer.getPlayerFastForward()
    this.fastRewind = this.appPrefer.getPlayerFastRewind()
    this.voIndex = this.appPrefer.getPlayerVo()
    const codecPrefer = this.appPrefer.getCodecPrefer()
    this.codecPreferIndex = this.codecPreferValues.indexOf(codecPrefer)
    if (this.codecPreferIndex < 0) {
      this.codecPreferIndex = 0
    }
  }

  build() {
    Column({ space: CommonConstants.SPACE_8 }) {
      ToolBar({
        title: $r('app.string.prefer_video'),
      })

      Scroll() {
        Column({ space: CommonConstants.SPACE_8 }) {

          Column() {
            OperationItem({
              icon: $r('sys.symbol.music_note_list_fill'),
              title: $r('app.string.prefer_video_auto_next')
            }) {
              Toggle({ type: ToggleType.Switch, isOn: this.autoNext })
                .onChange((isOn) => {
                  this.autoNext = isOn
                })
            }

            itemDividerBuilder()

            OperationItem({
              icon: $r('sys.symbol.headphones_fill'),
              title: $r('app.string.prefer_video_background_play')
            }) {
              Toggle({ type: ToggleType.Switch, isOn: this.backPlay })
                .onChange((isOn) => {
                  this.backPlay = isOn
                })
            }

            itemDividerBuilder()

            OperationItem({
              icon: $r('sys.symbol.dual_view_PIP'),
              title: $r('app.string.prefer_video_auto_pip')
            }) {
              Toggle({ type: ToggleType.Switch, isOn: this.autoPip })
                .onChange((isOn) => {
                  this.autoPip = isOn
                })
            }

            itemDividerBuilder()

            OperationItem({
              icon: $r('sys.symbol.hand_point_up_tap_fill_1'),
              title: $r('app.string.player_gesture_dc_forward_rewind')
            }) {
              Toggle({ type: ToggleType.Switch, isOn: this.forwardRewindDC })
                .onChange((isOn) => {
                  this.forwardRewindDC = isOn
                })
            }

            Column() {
              itemDividerBuilder()

              OperationItem({
                icon: $r('sys.symbol.arrow_up_and_down_square_portrait'),
                title: $r('app.string.player_gesture_dc_volume_brightness')
              }) {
                Toggle({ type: ToggleType.Switch, isOn: this.volumeBrightnessSL })
                  .onChange((isOn) => {
                    this.volumeBrightnessSL = isOn
                  })
              }

              itemDividerBuilder()

              OperationItem({
                icon: $r('sys.symbol.screen_rotation'),
                title: $r('app.string.prefer_video_rotation')
              }) {
                Select(this.rotationArray)
                  .selected(this.rotation)
                  .value(this.rotationArray[this.rotation].value)
                  .onSelect((index) => {
                    this.rotation = index
                  })
              }
            }
            .width(CommonConstants.FULL_PERCENT)
            .visibility(deviceInfo.deviceType !== 'tv' ? Visibility.Visible : Visibility.None)

            itemDividerBuilder()

            OperationItem({
              icon: $r('sys.symbol.fast_forward'),
              title: $r('app.string.prefer_video_rotation_fast_rewind')
            }) {
              Select(this.fastIntervalOption)
                .selected(this.fastInterval.indexOf(this.fastRewind))
                .value($r('app.string.prefer_video_rotation_fast_suffix', this.fastRewind.toString()))
                .onSelect((index) => {
                  this.fastRewind = this.fastInterval[index]
                })
            }

            itemDividerBuilder()

            OperationItem({
              icon: $r('sys.symbol.fast_forward'),
              title: $r('app.string.prefer_video_rotation_fast_forward')
            }) {
              Select(this.fastIntervalOption)
                .selected(this.fastInterval.indexOf(this.fastForward))
                .value($r('app.string.prefer_video_rotation_fast_suffix', this.fastForward.toString()))
                .onSelect((index) => {
                  this.fastForward = this.fastInterval[index]
                })
            }
          }
          .attributeModifier(groupAttributeModifier)

          Column() {
            OperationItem({
              icon: $r('sys.symbol.hardware'),
              title: $r('app.string.prefer_video_codec_prefer')
            }) {
              Select(this.codecPreferArray)
                .selected(this.codecPreferIndex)
                .value(this.codecPreferArray[this.codecPreferIndex].value)
                .onSelect((index) => {
                  this.codecPreferIndex = index
                })
            }

            itemDividerBuilder()

            OperationItem({
              icon: $r('sys.symbol.play_hexagon_fill'),
              title: $r('app.string.prefer_video_vo')
            }) {
              Select(this.voArray)
                .selected(this.voIndex)
                .value(this.voArray[this.voIndex].value)
                .onSelect((index) => {
                  this.voIndex = index
                })
            }

            Text(this.voDescArray[this.voIndex])
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .width(CommonConstants.FULL_PERCENT)
              .padding({
                left: CommonConstants.SPACE_16,
                right: CommonConstants.SPACE_16,
                bottom: CommonConstants.SPACE_8
              })

            itemDividerBuilder()

            OperationItem({
              icon: $r('sys.symbol.sound'),
              title: $r('app.string.prefer_audio_spdif')
            }) {
              Toggle({ type: ToggleType.Switch, isOn: this.aoSpdif })
                .onChange((isOn) => {
                  this.aoSpdif = isOn
                })
            }
          }
          .attributeModifier(groupAttributeModifier)

          Text() {
            Span($r('app.string.player_video_thanks_01'))
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            Span("FinPlayer")
              .fontSize(18)
              .fontColor($r('sys.color.ohos_id_color_component_activated'))
              .onClick(() => {
                MarketUtil.gotoMarket(this.getUIContext().getHostContext()! as common.UIAbilityContext
                  , "org.ohpg.fin.player")
              })
            Span($r('app.string.player_video_thanks_02'))
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
          .width(CommonConstants.FULL_PERCENT)
          .textAlign(TextAlign.Center)
          .padding({ top: CommonConstants.SPACE_8, bottom: CommonConstants.SPACE_8 })

        }
        .padding({
          bottom: px2vp(this.avoidArea?.bottomRect.height)
        })
      }
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Fade)
      .width(CommonConstants.FULL_PERCENT)
      .height('auto')
      .layoutWeight(1)
    }
    .attributeModifier(windowAttributeModifier)
  }

  aboutToDisappear(): void {
    this.appPrefer.setPlayerAutoNext(this.autoNext)
    this.appPrefer.setPlayerBackPlay(this.backPlay)
    this.appPrefer.setPlayerAutoPip(this.autoPip)
    this.appPrefer.setPlayerGestureDcFr(this.forwardRewindDC)
    this.appPrefer.setPlayerGestureSlVb(this.volumeBrightnessSL)
    this.appPrefer.setAoSpdif(this.aoSpdif)
    this.appPrefer.setPlayerRotation(this.rotation)
    this.appPrefer.setPlayerFastForward(this.fastForward)
    this.appPrefer.setPlayerFastRewind(this.fastRewind)
    this.appPrefer.setPlayerVo(this.voIndex)
    this.appPrefer.setCodecPrefer(this.codecPreferValues[this.codecPreferIndex])
    this.appPrefer.flush()
  }

}
