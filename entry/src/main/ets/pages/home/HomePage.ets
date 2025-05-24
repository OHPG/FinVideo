import { window } from '@kit.ArkUI';
import { FavouriteComponent } from './favourite/FavouriteComponent';
import { MainComponent } from './main/MainComponent';
import { PreferComponent } from './prefer/PreferComponent';
import { MediaComponent } from './media/MediaComponent';
import { CommonConstants } from '../common/CommonConstants';
import { BreakpointSystem } from '@ohpg/fin-core';

@Entry
@Component
struct HomePage {

  @State currentIndex: number = 0;

  @StorageProp('currentAvoidArea') currentAvoidArea?: window.AvoidArea = undefined

  @StorageProp(BreakpointSystem.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_SM

  @StorageProp(BreakpointSystem.CURRENT_HEIGHT_BREAKPOINT) currentHeightBreakpoint: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM

  private tabsController: TabsController = new TabsController();

  aboutToAppear(): void {

  }

  @Builder TabBuilder(title: ResourceStr, targetIndex: number, img: Resource) {
    Column({
      space: CommonConstants.SPACE_4
    }) {
      SymbolGlyph(img)
        .fontSize(24)
        .fontColor([this.currentIndex === targetIndex ?  '#1698CE' : '#6B6B6B' ])
      Text(title)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(this.currentIndex === targetIndex ? '#1698CE' : '#6B6B6B')
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }

  // https://developer.huawei.com/consumer/cn/design/harmonyos-symbol/
  build() {
    Tabs({ barPosition: this.currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM
      ? BarPosition.End : BarPosition.Start, controller: this.tabsController }) {
      TabContent() {
        MainComponent()
      }
      .tabBar(this.TabBuilder($r('app.string.home_main'), 0, $r('sys.symbol.house_fill')))

      TabContent() {
        MediaComponent()
      }
      .tabBar(this.TabBuilder($r('app.string.home_media'), 1, $r('sys.symbol.externaldrive_fill')))

      TabContent() {
        FavouriteComponent()
      }
      .tabBar(this.TabBuilder($r('app.string.home_favourite'), 2, $r('sys.symbol.heart_fill')))

      TabContent() {
        PreferComponent()
      }
      .tabBar(this.TabBuilder($r('app.string.home_prefer'), 3, $r('sys.symbol.square_fill_grid_2x2')))
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .vertical(!(this.currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM))
    .barWidth(this.currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM ? '100%' : 72)
    .barHeight(this.currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM ? 50 : '100%')
    .animationDuration(0)
    .backgroundColor($r('sys.color.background_primary'))
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .scrollable(false)
    .width('100%')
    .height('100%')
    .padding({
      top: px2vp(this.currentAvoidArea?.topRect.height),
      bottom: px2vp(this.currentAvoidArea?.bottomRect.height)
    })
  }

  aboutToDisappear(): void {
  }

}