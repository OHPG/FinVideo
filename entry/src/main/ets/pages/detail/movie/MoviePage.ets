import { window } from '@kit.ArkUI'
import { DetailArgs } from '../DetailArgs'
import { MovieViewModel } from './MovieViewModel'
import { CommonConstants } from '../../common/CommonConstants'
import { DetailCover, DetailFooter, DetailHeader } from '../DetailComponent'
import { ScrollRefreshView } from '@ohpg/fin-framework'
import { BaseItemDto } from '@ohpg/jellyfin'
import { ToolBar } from '@ohpg/fin-framework'
import { BreakpointSystem } from '@ohpg/fin-core'

let movieStorage: LocalStorage = new LocalStorage();
@Entry(movieStorage)
@Component
struct MoviePage {

  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  @StorageProp(BreakpointSystem.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_SM

  @StorageProp(BreakpointSystem.CURRENT_HEIGHT_BREAKPOINT) currentHeightBreakpoint: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM

  private args = this.getUIContext().getRouter().getParams() as DetailArgs

  private viewModel = new MovieViewModel(getContext(), this.args)

  aboutToAppear(): void {
    movieStorage.setOrCreate("viewModel", this.viewModel)
  }

  @Builder
  movieScrollView(item?: BaseItemDto) {
    Column({space: CommonConstants.SPACE_12}) {
      DetailCover({itemDto: item})
      DetailHeader({itemDto: item})
      DetailFooter({itemDto: item})
    }
    .padding({
      bottom: px2vp(this.avoidArea?.bottomRect.height)
    })
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
  }

  build() {
    Stack() {
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
    .alignContent(Alignment.Top)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

}