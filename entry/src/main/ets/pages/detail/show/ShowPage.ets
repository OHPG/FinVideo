import { CommonConstants } from '../../common/CommonConstants'
import { DetailArgs } from '../DetailArgs'
import { DetailCover, DetailFooter, DetailPosterRow, DetailContent } from '../DetailComponent'
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
      DetailPosterRow({itemDto: info?.show})
      if (this.currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM) {
        DetailContent({itemDto: info?.show})
        if (info?.nextUp) {
          ShowNextUp({
            nextDto: info.nextUp
          })
        }
      } else {
        Row({ space: CommonConstants.SPACE_12 }) {
          DetailContent({itemDto: info?.show})
            .layoutWeight(1)
          if (info?.nextUp) {
            ShowNextUp({
              nextDto: info.nextUp
            })
              .layoutWeight(1)
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .alignItems(VerticalAlign.Top)
      }
      if (info?.seasons) {
        ShowSeasons({
          args: this.args,
          seasonDto: info.seasons
        })
      }
      if (info?.show && info.show.person && info.show.person.length > 0) {
        DetailFooter({itemDto: info?.show})
      }
      // 剧集的版本信息在剧集详情页展示，此处不需要底部 Source 信息栏
    }
    .padding({
      bottom: (px2vp(this.avoidArea?.bottomRect.height) || 0) + CommonConstants.SPACE_16
    })
    .width(CommonConstants.FULL_PERCENT)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
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
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

  aboutToDisappear(): void {
  }
}
