import { SymbolGlyphModifier } from "@kit.ArkUI"
import { AppEvents, FinSortBy, FinSortOrder } from "@ohpg/fin-core"
import { AppConfig } from "../../config/AppConfig"
import { AppPrefer } from "../../prefer/AppPrefer"

@Component
export struct SortMenu {

  @StorageLink(AppPrefer.PREFER) appPrefer?: AppPrefer = undefined

  @StorageLink(AppConfig.CONFIG) appConfig?: AppConfig = undefined

  /**
   * 是否显示排序的菜单
   */
  @State sortMenu: boolean = false

  /**
   * 是否显示文件夹
   */
  @State enableSortDir: boolean = true

  private uncheckedModifier = new SymbolGlyphModifier(($r('sys.symbol.circle')))

  private checkedModifier = new SymbolGlyphModifier(($r('sys.symbol.circle_inset_filled')))

  private notifySort() {
    this.getUIContext().getHostContext()?.eventHub.emit(AppEvents.EVENT_SORT_INFO_CHANGED)
  }

  @Builder
  bindSortMenu() {
    Menu() {
      MenuItemGroup() {
        MenuItem({
          content: $r('app.string.menu_sort_by_name'),
          symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.textformat')),
          symbolEndIcon: this.appConfig?.sortBy === FinSortBy.Name ? this.checkedModifier : this.uncheckedModifier
        })
          .onClick(() => {
            this.appConfig!.sortBy = FinSortBy.Name
            this.appPrefer?.setSortBy(FinSortBy.Name)
            this.notifySort()
          })

        MenuItem({
          content: $r('app.string.menu_sort_by_sort_name'),
          symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.character_arrow_clockwise')),
          symbolEndIcon: this.appConfig?.sortBy === FinSortBy.SortName ? this.checkedModifier : this.uncheckedModifier
        })
          .onClick(() => {
            this.appConfig!.sortBy = FinSortBy.SortName
            this.appPrefer?.setSortBy(FinSortBy.SortName)
            this.notifySort()
          })

        MenuItem({
          content: $r('app.string.menu_sort_by_time'),
          symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.time_inerval')),
          symbolEndIcon: this.appConfig?.sortBy === FinSortBy.DateCreated ? this.checkedModifier : this.uncheckedModifier
        })
          .onClick(() => {
            this.appConfig!.sortBy = FinSortBy.DateCreated
            this.appPrefer?.setSortBy(FinSortBy.DateCreated)
            this.notifySort()
          })
      }
      MenuItemGroup() {
        MenuItem({
          content: $r('app.string.menu_sort_order_asc'),
          symbolStartIcon: (new SymbolGlyphModifier($r('sys.symbol.text_and_arrow_up'))).scale({y: -1}),
          symbolEndIcon: this.appConfig?.sortOrder === FinSortOrder.Ascending ? this.checkedModifier : this.uncheckedModifier
        })
          .onClick(() => {
            this.appConfig!.sortOrder = FinSortOrder.Ascending
            this.appPrefer?.setSortOrder(FinSortOrder.Ascending)
            this.notifySort()
          })

        MenuItem({
          content: $r('app.string.menu_sort_order_desc'),
          symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.text_and_arrow_down')),
          symbolEndIcon: this.appConfig?.sortOrder === FinSortOrder.Descending ? this.checkedModifier : this.uncheckedModifier
        })
          .onClick(() => {
            this.appConfig!.sortOrder = FinSortOrder.Descending
            this.appPrefer?.setSortOrder(FinSortOrder.Descending)
            this.notifySort()
          })
      }
    }
  }

  build() {

    SymbolGlyph($r('sys.symbol.text_aligncenter'))
      .fontSize($r('sys.float.Title_M'))
      .fontColor([$r('sys.color.font_primary')])
      .bindContextMenu(this.sortMenu, this.bindSortMenu, {
        aboutToDisappear: () => {
          this.sortMenu = false
        }
      })
      .onClick(() => {
        this.sortMenu = true
      })

  }

}