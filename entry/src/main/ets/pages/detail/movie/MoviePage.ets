import { window } from '@kit.ArkUI'
import { DetailArgs } from '../DetailArgs'
import { MovieViewModel } from './MovieViewModel'
import { CommonConstants } from '../../common/CommonConstants'
import { DetailCover, DetailFooter, DetailPosterRow, DetailContent, DetailSourceBar } from '../DetailComponent'
import { ScrollRefreshView } from '@ohpg/fin-framework'
import { BreakpointSystem, FinItem } from '@ohpg/fin-core'
import { ToolBar } from '@ohpg/fin-framework'

let movieStorage: LocalStorage = new LocalStorage();
@Entry(movieStorage)
@Component
struct MoviePage {

  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  @StorageProp(BreakpointSystem.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_SM

  @StorageProp(BreakpointSystem.CURRENT_HEIGHT_BREAKPOINT) currentHeightBreakpoint: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM

  /** 当前选中的版本索引（供 VersionSelector 和 DetailSourceBar 共享） */
  @Provide selectedSourceIndex: number = 0

  private args = this.getUIContext().getRouter().getParams() as DetailArgs

  private viewModel = new MovieViewModel(getContext(), this.args)

  aboutToAppear(): void {
    movieStorage.setOrCreate("viewModel", this.viewModel)
  }

  @Builder
  movieScrollView(item?: FinItem) {
    Column({ space: CommonConstants.SPACE_12 }) {
      DetailCover({ itemDto: item }) {
        DetailPosterRow({ itemDto: item })
      }
      DetailContent({ itemDto: item })
      if (item && item.person && item.person.length > 0) {
        DetailFooter({ itemDto: item })
      }
      // 底部 Source 信息栏（放在内容流中，确保数据加载后能正确渲染）
      DetailSourceBar()
    }
    .padding({
      bottom: (px2vp(this.avoidArea?.bottomRect.height) || 0) + CommonConstants.SPACE_16
    })
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      ScrollRefreshView({
        source: this.viewModel,
        itemLayout: (info: ESObject) => {
          this.movieScrollView(info)
        }
      })

      ToolBar({
        color: $r('sys.color.font_on_primary')
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}
