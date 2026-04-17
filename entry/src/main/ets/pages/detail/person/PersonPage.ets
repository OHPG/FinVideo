import { window } from '@kit.ArkUI'
import { BreakpointSystem, FinItem, FinItemType } from '@ohpg/fin-core'
import { ScrollRefreshView, ToolBar } from '@ohpg/fin-framework'
import { CommonConstants } from '../../common/CommonConstants'
import { MediaRouter } from '../../common/MediaRouter'
import { AppRouter } from '../../../router/AppRouter'
import { PlayerArgs } from '../../player/PlayerArgs'
import { PersonArgs } from './PersonArgs'
import { PersonData, PersonViewModel } from './PersonViewModel'
import LazyDataSource from '../../common/LazyDataSource'
import { ObservedArray } from '../../common/ObservedArray'

@Entry
@Component
struct PersonPage {

  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  @StorageProp(BreakpointSystem.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint =
    WidthBreakpoint.WIDTH_SM

  private args = this.getUIContext().getRouter().getParams() as PersonArgs

  private viewModel = new PersonViewModel(getContext(), this.args)

  private itemDataSource: LazyDataSource<FinItem> = new LazyDataSource()

  private isPad(): boolean {
    return this.currentWidthBreakpoint >= WidthBreakpoint.WIDTH_MD
  }

  @Builder
  personContent(data?: PersonData) {
    Column({ space: CommonConstants.SPACE_12 }) {
      // 头像 + 信息
      Row({ space: CommonConstants.SPACE_16 }) {
        Image(data?.args.image)
          .alt($r('app.media.alt'))
          .objectFit(ImageFit.Cover)
          .autoResize(true)
          .width(120)
          .height(180)
          .borderRadius($r('app.float.lg_border_radius'))

        Column({ space: CommonConstants.SPACE_8 }) {
          Text(data?.args.name)
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(data?.args.role)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(1)
            .visibility(data?.args.role ? Visibility.Visible : Visibility.None)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: CommonConstants.SPACE_16,
        right: CommonConstants.SPACE_16,
        top: CommonConstants.SPACE_16
      })

      // 相关作品标题
      Text($r('app.string.person_related_works'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .padding({ left: CommonConstants.SPACE_16, right: CommonConstants.SPACE_16 })
        .visibility(data?.items && data.items.length > 0 ? Visibility.Visible : Visibility.None)

      // 作品列表
      this.itemGrid(data)
    }
    .padding({ bottom: px2vp(this.avoidArea?.bottomRect.height) })
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  itemGrid(data?: PersonData) {
    Column() {
      List({ space: CommonConstants.SPACE_12 }) {
        LazyForEach(this.itemDataSource, (item: FinItem) => {
          ListItem() {
            PersonMediaItem({ item: item })
          }
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .contentStartOffset(CommonConstants.SPACE_16)
      .contentEndOffset(CommonConstants.SPACE_16)
      .scrollBar(BarState.Off)
      .lanes(this.isPad() ? 2 : 1)
    }
    .width(CommonConstants.FULL_PERCENT)
    .layoutWeight(1)
    .visibility(data?.items && data.items.length > 0 ? Visibility.Visible : Visibility.None)
  }

  build() {
    Stack() {
      ScrollRefreshView({
        source: this.viewModel,
        itemLayout: (info: ESObject) => {
          let data = info as PersonData
          if (data?.items) {
            this.itemDataSource.pushArrayData(new ObservedArray<FinItem>(data.items))
          }
          this.personContent(data)
        }
      })

      ToolBar()
    }
    .alignContent(Alignment.Top)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

}

@Reusable
@Component
struct PersonMediaItem {

  @Require @State item?: FinItem = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as FinItem
  }

  build() {
    Row({ space: CommonConstants.SPACE_12 }) {
      Image(this.item?.image?.primary)
        .alt($r('app.media.alt'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .width(80)
        .aspectRatio(CommonConstants.ITEM_RATIO)
        .borderRadius($r('app.float.sm_border_radius'))

      Column({ space: CommonConstants.SPACE_4 }) {
        Text(this.item?.name)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: CommonConstants.SPACE_8 }) {
          Text(this.item?.productionYear)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .visibility(this.item?.productionYear ? Visibility.Visible : Visibility.None)

          Text(this.item?.type === FinItemType.Movie
            ? $r('app.string.person_type_movie')
            : $r('app.string.person_type_series'))
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_tertiary'))
        }

        Text(this.item?.overview)
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .visibility(this.item?.overview ? Visibility.Visible : Visibility.None)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)

      // 电影直接显示播放按钮
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.play_fill'))
          .fontColor([$r('sys.color.font_on_primary')])
          .fontSize($r('sys.float.Body_L'))
      }
      .width(36)
      .height(36)
      .visibility(this.item?.type === FinItemType.Movie ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        if (this.item) {
          let args: PlayerArgs = {
            id: this.item.id,
            name: this.item.name,
            type: this.item.type!
          }
          AppRouter.goToPlayer(this.getUIContext(), args)
        }
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.SPACE_16,
      right: CommonConstants.SPACE_16,
      top: CommonConstants.SPACE_8,
      bottom: CommonConstants.SPACE_8
    })
    .onClick(() => {
      if (this.item) {
        MediaRouter.openDetail(this.item)
      }
    })
  }

}
