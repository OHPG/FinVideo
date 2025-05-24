import { CommonConstants } from '../../common/CommonConstants'
import { DetailArgs } from '../DetailArgs'
import { DetailCover, DetailFooter, DetailHeader } from '../DetailComponent'
import { ShowViewModel } from './ShowViewModel'
import { window } from '@kit.ArkUI'
import { ShowInfo } from './ShowInfo'
import { ShowNextUp, ShowSeasons } from './ShowComponent'
import { ScrollRefreshView } from '@ohpg/fin-framework'
import { ToolBar } from '@ohpg/fin-framework'
import { BreakpointSystem } from '@ohpg/fin-core'

let showStorage: LocalStorage = new LocalStorage();
@Entry(showStorage)
@Component
struct ShowPage {

  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  @StorageProp(BreakpointSystem.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_SM

  @StorageProp(BreakpointSystem.CURRENT_HEIGHT_BREAKPOINT) currentHeightBreakpoint: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM

  private args = this.getUIContext().getRouter().getParams() as DetailArgs

  private viewModel = new ShowViewModel(getContext(), this.args)

  aboutToAppear(): void {
    showStorage.setOrCreate("viewModel", this.viewModel)
  }

  @Builder
  showScrollView(info?: ShowInfo) {
    Column({space: CommonConstants.SPACE_12}) {
      DetailCover({itemDto: info?.show})
      if (this.currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM) {
        DetailHeader({itemDto: info?.show})
        // 季及接下来
        if (info?.nextUp) {
          ShowNextUp({
            nextDto: info.nextUp
          })
        }
      } else {
        Row() {
          // 简介
          DetailHeader({itemDto: info?.show})
            .width(info?.nextUp ? '50%' : '100%')
            .height('auto')
          // 季及接下来
          if (info?.nextUp) {
            ShowNextUp({
              nextDto: info.nextUp
            })
              .width('50%')
              .height('auto')
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.Start)
      }
      if (info?.seasons) {
        ShowSeasons({
          args: this.args,
          seasonDto: info.seasons
        })
      }
      DetailFooter({itemDto: info?.show})
    }
    .padding({
      bottom: px2vp(this.avoidArea?.bottomRect.height)
    })
    .width(CommonConstants.FULL_PERCENT)
  }

  build() {
    Stack() {
      ScrollRefreshView({
        source: this.viewModel,
        itemLayout: (info: ESObject) => {
          this.showScrollView(info)
        }
      })
      ToolBar({
        color: $r('sys.color.font_on_primary')
      })
    }
    .alignContent(Alignment.Top)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

  aboutToDisappear(): void {
  }

}