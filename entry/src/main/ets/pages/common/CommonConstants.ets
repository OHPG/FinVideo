/**
 * Common constants for common component.
 */
export class CommonConstants {
  // Font family
  static readonly HARMONY_HEI_TI_FONT_FAMILY = 'HarmonyHeiTi';
  static readonly HARMONY_HEITI_MEDIUM_FONT_FAMILY = 'HarmonyHeiTi-Medium';
  static readonly HARMONY_HEITI_BOLD_FONT_FAMILY = 'HarmonyHeiTi-Bold';
  // Font weight
  static readonly DIALOG_TITLE_FONT_WEIGHT: number = 700;
  static readonly DIALOG_BUTTON_FONT_WEIGHT: number = 500;
  static readonly NORMAL_FONT_WEIGHT: number = 400;
  // Opacity
  static readonly FIRST_LEVEL_OPACITY: number = 0.9;
  static readonly SECOND_LEVEL_OPACITY: number = 0.6;
  static readonly HALF_OPACITY: number = 0.5;
  static readonly THIRD_LEVEL_OPACITY: number = 0.3;
  static readonly Divider_OPACITY: number = 0.05;
  // Blur
  static readonly REGULAR_BLUR: number = 250;
  // Space
  static readonly SPACE_4: number = 4;
  static readonly SPACE_8: number = 8;
  static readonly SPACE_12: number = 12;
  static readonly SPACE_16: number = 16;
  // MaxLines
  static readonly MAX_LINE_TWO: number = 2;

  // Column count
  static readonly SM_COLUMN_COUNT: number = 1;
  static readonly MD_COLUMN_COUNT: number = 2;
  static readonly LG_COLUMN_COUNT: number = 3;

  // Swiper duration
  static readonly SWIPER_DURATION: number = 1000;
  // Percent
  static readonly FULL_PERCENT: string = '100%';
  static readonly HALF_PERCENT: string = '50%';
  static readonly NAVI_BAR_WIDTH: string = '40%';
  // Skeleton animation config
  static readonly SKELETON_ANIMATION: AnimateParam = {
    duration: 400,
    tempo: 0.6,
    curve: Curve.EaseInOut,
    delay: 200,
    iterations: -1,
    playMode: PlayMode.Alternate
  }

  // item
  static readonly ITEM_WIDTH = 140

  static readonly ITEM_RATIO = 0.67

  static readonly ITEM_HEIGHT = 240


}