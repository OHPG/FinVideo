@Component
export struct GestureGuide {

  spaceSize: number = 8
  iconSize: number = 42
  textSize: number = 18
  commentSize: number = 16

  callback?: Callback<void>

  @State guideFinished: boolean = false

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Swiper() {

        Stack() {
          Row() {
            Column({ space: this.spaceSize }) {
              SymbolGlyph($r('sys.symbol.hand_point_up_tap_fill'))
                .fontColor([$r('sys.color.white')])
                .fontSize(this.iconSize)
              Text($r('app.string.gesture_guide_double_click_left'))
                .fontColor($r('sys.color.white'))
                .fontSize(this.textSize)
              Text($r('app.string.gesture_guide_double_click_left_comment'))
                .fontColor($r('sys.color.ohos_id_color_component_activated'))
                .fontSize(this.commentSize)
            }

            Column({ space: this.spaceSize }) {
              SymbolGlyph($r('sys.symbol.hand_point_up_tap_fill'))
                .fontColor([$r('sys.color.white')])
                .fontSize(this.iconSize)
              Text($r('app.string.gesture_guide_double_click_center'))
                .fontColor($r('sys.color.white'))
                .fontSize(this.textSize)
              Text($r('app.string.gesture_guide_double_click_center_comment'))
                .fontColor($r('sys.color.ohos_id_color_component_activated'))
                .fontSize(this.commentSize)
            }

            Column({ space: this.spaceSize }) {
              SymbolGlyph($r('sys.symbol.hand_point_up_tap_fill'))
                .fontColor([$r('sys.color.white')])
                .fontSize(this.iconSize)
              Text($r('app.string.gesture_guide_double_click_right'))
                .fontColor($r('sys.color.white'))
                .fontSize(this.textSize)
              Text($r('app.string.gesture_guide_double_click_right_comment'))
                .fontColor($r('sys.color.ohos_id_color_component_activated'))
                .fontSize(this.commentSize)
            }
          }
          .justifyContent(FlexAlign.SpaceAround)
          .width('100%')
        }
        .width('100%')
        .height('100%')

        Stack() {
          Row() {
            Column({ space: this.spaceSize }) {
              Row() {
                SymbolGlyph($r('sys.symbol.reverse_order'))
                  .fontColor([$r('sys.color.white')])
                  .rotate({ angle: 90 })
                  .fontSize(this.iconSize)
                SymbolGlyph($r('sys.symbol.hand_point_up_tap_fill'))
                  .fontColor([$r('sys.color.white')])
                  .fontSize(this.iconSize)
              }
              Text($r('app.string.gesture_guide_scroll_left'))
                .fontColor($r('sys.color.white'))
                .fontSize(this.textSize)
              Text($r('app.string.gesture_guide_scroll_left_comment'))
                .fontColor($r('sys.color.ohos_id_color_component_activated'))
                .fontSize(this.commentSize)
            }

            Column({ space: this.spaceSize }) {
              Row() {
                SymbolGlyph($r('sys.symbol.reverse_order'))
                  .fontColor([$r('sys.color.white')])
                  .fontSize(this.iconSize)
                SymbolGlyph($r('sys.symbol.hand_point_up_tap_fill'))
                  .fontColor([$r('sys.color.white')])
                  .fontSize(this.iconSize)
              }
              Text($r('app.string.gesture_guide_swipe'))
                .fontColor($r('sys.color.white'))
                .fontSize(this.textSize)
              Text($r('app.string.gesture_guide_swipe_comment'))
                .fontColor($r('sys.color.ohos_id_color_component_activated'))
                .fontSize(this.commentSize)
            }

            Column({ space: this.spaceSize }) {
              Row() {
                SymbolGlyph($r('sys.symbol.reverse_order'))
                  .fontColor([$r('sys.color.white')])
                  .rotate({ angle: 90 })
                  .fontSize(this.iconSize)
                SymbolGlyph($r('sys.symbol.hand_point_up_tap_fill'))
                  .fontColor([$r('sys.color.white')])
                  .fontSize(this.iconSize)
              }
              Text($r('app.string.gesture_guide_scroll_right'))
                .fontColor($r('sys.color.white'))
                .fontSize(this.textSize)
              Text($r('app.string.gesture_guide_scroll_right_comment'))
                .fontColor($r('sys.color.ohos_id_color_component_activated'))
                .fontSize(this.commentSize)
            }
          }
          .justifyContent(FlexAlign.SpaceAround)
          .width('100%')
        }
        .width('100%')
        .height('100%')

        Stack() {
          Row() {
            Column({ space: this.spaceSize }) {
              Row() {
                SymbolGlyph($r('sys.symbol.arrow_down_right_and_arrow_up_left'))
                  .fontColor([$r('sys.color.white')])
                  .fontSize(this.iconSize * 0.8)
                SymbolGlyph($r('sys.symbol.hand_tap_fill'))
                  .fontColor([$r('sys.color.white')])
                  .fontSize(this.iconSize)
              }
              Text($r('app.string.gesture_guide_pinch'))
                .fontColor($r('sys.color.white'))
                .fontSize(this.textSize)
              Text($r('app.string.gesture_guide_pinch_comment'))
                .fontColor($r('sys.color.ohos_id_color_component_activated'))
                .fontSize(this.commentSize)
            }

            Column({ space: this.spaceSize }) {
              SymbolGlyph($r('sys.symbol.hand_point_up_tap_fill_1'))
                .fontColor([$r('sys.color.white')])
                .fontSize(this.iconSize)
              Text($r('app.string.gesture_guide_long_press'))
                .fontColor($r('sys.color.white'))
                .fontSize(this.textSize)
              Text($r('app.string.gesture_guide_long_press_comment'))
                .fontColor($r('sys.color.ohos_id_color_component_activated'))
                .fontSize(this.commentSize)
            }

            Column({ space: this.spaceSize }) {
              Row() {
                SymbolGlyph($r('sys.symbol.arrow_up_left_and_arrow_down_right'))
                  .fontColor([$r('sys.color.white')])
                  .fontSize(this.iconSize * 0.8)
                SymbolGlyph($r('sys.symbol.hand_tap_fill'))
                  .fontColor([$r('sys.color.white')])
                  .fontSize(this.iconSize)
              }
              Text($r('app.string.gesture_guide_stretch'))
                .fontColor($r('sys.color.white'))
                .fontSize(this.textSize)
              Text($r('app.string.gesture_guide_stretch_comment'))
                .fontColor($r('sys.color.ohos_id_color_component_activated'))
                .fontSize(this.commentSize)
            }
          }
          .justifyContent(FlexAlign.SpaceAround)
          .width('100%')
        }
        .width('100%')
        .height('100%')

      }
      .loop(false)
      .indicator(new DotIndicator()
        .color($r('sys.color.white'))
        .selectedColor($r('sys.color.ohos_id_color_component_activated'))
        .itemWidth(10)
        .itemHeight(10)
        .selectedItemWidth(10)
        .selectedItemHeight(10)
      )
      .autoPlay(false)
      .onChange((index) => {
        this.guideFinished = index >= 2
      })

      Button($r('app.string.gesture_guide_finish'))
        .margin(36)
        .visibility(this.guideFinished ? Visibility.Visible : Visibility.Hidden)
        .padding({ left: 40, right: 40 })
        .fontSize(this.textSize)
        .fontColor($r('sys.color.white'))
        .onClick(() => {
          this.callback?.()
        })
    }
    .backgroundColor(0xAA000000)
    .width('100%')
    .height('100%')
  }

}
