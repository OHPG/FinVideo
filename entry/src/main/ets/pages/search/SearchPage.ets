import { ToolBar } from '@ohpg/fin-framework'
import { CommonConstants } from '../common/CommonConstants'
import { SearchViewModel } from './SearchViewModel'

@Entry
@Component
struct SearchPage {

  private viewModel = new SearchViewModel(getContext())

  build() {
    Column() {
      ToolBar({
        title: $r('app.string.search_title')
      })
      Text("Search")
    }
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)

  }

}