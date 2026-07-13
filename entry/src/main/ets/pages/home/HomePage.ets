import { window } from '@kit.ArkUI';
import { FavouriteComponent } from './favourite/FavouriteComponent';
import { MainComponent } from './main/MainComponent';
import { PreferComponent } from './prefer/PreferComponent';
import { MediaComponent } from './media/MediaComponent';
import { CommonConstants } from '../common/CommonConstants';
import { ActiveInfo, AppStorageKeys, BreakpointSystem } from '@ohpg/fin-core';
import { FinRouter, EmptyStateView } from '@ohpg/fin-framework';

enum HomeTabType {
  Main = 'main',
  Media = 'media',
  Favourite = 'favourite',
  Prefer = 'prefer',
}

interface HomeTabMeta {
  type: HomeTabType
  title: ResourceStr
  icon: Resource
}

@Entry
@Component
struct HomePage {
  @State currentIndex: number = 0;

  @StorageLink(AppStorageKeys.KEY_ACTIVE_INFO) activeInfo?: ActiveInfo = undefined

  @StorageProp('currentAvoidArea') @Watch('onAvoidAreaChanged') currentAvoidArea?: window.AvoidArea = undefined

  @StorageProp(BreakpointSystem.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_SM

  @StorageProp(BreakpointSystem.CURRENT_HEIGHT_BREAKPOINT) currentHeightBreakpoint: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM

  private swiperController: SwiperController = new SwiperController()

  @Provide("bottomOffset") bottomOffset: number = 66

  private homeTabs: HomeTabType[] = [HomeTabType.Main, HomeTabType.Media, HomeTabType.Favourite, HomeTabType.Prefer]

  private tabMetaMap: Map<HomeTabType, HomeTabMeta> = new Map<HomeTabType, HomeTabMeta>()

  aboutToAppear(): void {
    this.updateBottomOffset()
    this.tabMetaMap.set(HomeTabType.Main, { type: HomeTabType.Main, title: $r('app.string.home_main'), icon: $r('sys.symbol.house_fill') } as HomeTabMeta)
    this.tabMetaMap.set(HomeTabType.Media, { type: HomeTabType.Media, title: $r('app.string.home_media'), icon: $r('sys.symbol.externaldrive_fill') } as HomeTabMeta)
    this.tabMetaMap.set(HomeTabType.Favourite, { type: HomeTabType.Favourite, title: $r('app.string.home_favourite'), icon: $r('sys.symbol.heart_fill') } as HomeTabMeta)
    this.tabMetaMap.set(HomeTabType.Prefer, { type: HomeTabType.Prefer, title: $r('app.string.home_prefer'), icon: $r('sys.symbol.square_fill_grid_2x2') } as HomeTabMeta)
  }

  private updateBottomOffset(): void {
    // 导航栏高度52 + 上下padding + margin到安全区底部
    let safeBottom = px2vp(this.currentAvoidArea?.bottomRect.height) || CommonConstants.SPACE_8
    this.bottomOffset = 52 + safeBottom + CommonConstants.SPACE_8
  }

  private onAvoidAreaChanged(): void {
    this.updateBottomOffset()
  }

  @Builder TabBuilder(title: ResourceStr, targetIndex: number, img: Resource) {
    Column({ space: 2 }) {
      SymbolGlyph(img)
        .fontSize(24)
        .fontColor([this.currentIndex === targetIndex
          ? $r('sys.color.ohos_id_color_activated')
          : $r('sys.color.ohos_id_color_text_secondary')])
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === targetIndex
          ? $r('sys.color.ohos_id_color_activated')
          : $r('sys.color.ohos_id_color_text_secondary'))
    }
    .width(56)
    .height(52)
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.Transparent)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(() => {
      this.currentIndex = targetIndex
      this.swiperController.changeIndex(this.currentIndex, false)
    })
  }

  @Builder
  renderTab(type: HomeTabType) {
    if (type === HomeTabType.Main) {
      MainComponent()
    } else if (type === HomeTabType.Media) {
      MediaComponent()
    } else if (type === HomeTabType.Favourite) {
      FavouriteComponent()
    } else if (type === HomeTabType.Prefer) {
      PreferComponent()
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.activeInfo) {
        // 内容区
        Swiper(this.swiperController) {
          ForEach(this.homeTabs, (type: HomeTabType) => {
            this.renderTab(type)
          }, (type: HomeTabType) => type)
        }
        .index(this.currentIndex)
        .indicator(false)
        .loop(false)
        .disableSwipe(true)
        .duration(0)
        .width('100%')
        .height('100%')

        // 悬浮底部导航
        Row({ space: 4 }) {
          ForEach(this.homeTabs, (type: HomeTabType, index: number) => {
            this.TabBuilder(
              this.tabMetaMap.get(type)!.title,
              index,
              this.tabMetaMap.get(type)!.icon
            )
          }, (type: HomeTabType) => type)
        }
        .padding({
          left: 12,
          right: 12,
        })
        .margin({ bottom: px2vp(this.currentAvoidArea?.bottomRect.height) || CommonConstants.SPACE_8 })
        .borderRadius(28)
        .backgroundBlurStyle(BlurStyle.Thin)
        .backgroundColor($r('sys.color.comp_background_secondary'))
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)
      } else {
        EmptyStateView({
          icon: $r('sys.symbol.externaldrive'),
          title: $r('app.string.home_no_server_tips'),
          subtitle: $r('app.string.home_no_server_desc')
        })
          .width('100%')
          .height('100%')
          .onClick(() => {
            FinRouter.auth(this.getUIContext())
          })
      }
    }
    .width('100%')
    .height('100%')
    .padding({
      top: px2vp(this.currentAvoidArea?.topRect.height)
    })
    .backgroundColor($r('sys.color.background_primary'))
  }

  aboutToDisappear(): void {
  }

}
