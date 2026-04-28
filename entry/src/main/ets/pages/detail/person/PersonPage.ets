import { window } from '@kit.ArkUI'
import { BreakpointSystem, FinItem } from '@ohpg/fin-core'
import { ScrollRefreshView, ToolBar } from '@ohpg/fin-framework'
import { CommonConstants } from '../../common/CommonConstants'
import { MediaRouter } from '../../common/MediaRouter'
import { PersonArgs } from './PersonArgs'
import { PersonData, PersonViewModel } from './PersonViewModel'

@Entry
@Component
struct PersonPage {

  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  @StorageProp(BreakpointSystem.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint =
    WidthBreakpoint.WIDTH_SM

  private args = this.getUIContext().getRouter().getParams() as PersonArgs

  private viewModel = new PersonViewModel(getContext(), this.args)

  private isPad(): boolean {
    return this.currentWidthBreakpoint >= WidthBreakpoint.WIDTH_MD
  }

  @Builder
  personContent(data?: PersonData) {
    Column() {
      // 顶部头像区域 - 大图居中展示
      this.heroSection(data)

      // 分类作品区域
      Column({ space: CommonConstants.SPACE_16 }) {
        // 电影分类
        if (data?.movies && data.movies.length > 0) {
          this.worksSection($r('app.string.person_movies'), data.movies)
        }

        // 剧集分类
        if (data?.series && data.series.length > 0) {
          this.worksSection($r('app.string.person_series'), data.series)
        }

        // 无作品提示
        if ((!data?.movies || data.movies.length === 0) && (!data?.series || data.series.length === 0)) {
          Column() {
            Text($r('app.string.person_no_works'))
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_tertiary'))
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(120)
          .justifyContent(FlexAlign.Center)
        }
      }
      .padding({
        top: CommonConstants.SPACE_4,
        bottom: px2vp(this.avoidArea?.bottomRect.height) + CommonConstants.SPACE_16
      })
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  heroSection(data?: PersonData) {
    Column({ space: CommonConstants.SPACE_12 }) {
      // 头像 - 居中大图
      Image(data?.args.image)
        .alt($r('app.media.alt'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .width(this.isPad() ? 200 : 160)
        .aspectRatio(0.75)
        .borderRadius($r('app.float.lg_border_radius'))
        .shadow({
          radius: 20,
          color: '#40000000',
          offsetY: 8
        })

      // 名字
      Text(data?.args.name)
        .fontSize($r('sys.float.Title_L'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 角色
      Text(data?.args.role)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .visibility(data?.args.role ? Visibility.Visible : Visibility.None)

      // 简介
      Text(data?.overview)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .maxLines(4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .visibility(data?.overview ? Visibility.Visible : Visibility.None)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Center)
    .padding({
      left: CommonConstants.SPACE_16,
      right: CommonConstants.SPACE_16,
      top: px2vp(this.avoidArea?.topRect.height) + CommonConstants.SPACE_16,
      bottom: CommonConstants.SPACE_8
    })
  }

  @Builder
  worksSection(title: ResourceStr, items: Array<FinItem>) {
    Column({ space: CommonConstants.SPACE_12 }) {
      // 分类标题
      Row({ space: CommonConstants.SPACE_8 }) {
        Text(title)
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)

        Text(items.length.toString())
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_tertiary'))
      }
      .padding({ left: CommonConstants.SPACE_16, right: CommonConstants.SPACE_16 })

      // 海报网格 - 横向滚动
      List({ space: CommonConstants.SPACE_12 }) {
        ForEach(items, (item: FinItem) => {
          ListItem() {
            PersonWorkCard({ item: item })
          }
        })
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .contentStartOffset(CommonConstants.SPACE_16)
      .contentEndOffset(CommonConstants.SPACE_16)
      .width(CommonConstants.FULL_PERCENT)
      .height(this.isPad() ? 280 : 240)
    }
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
  }

  build() {
    Stack() {
      ScrollRefreshView({
        source: this.viewModel,
        itemLayout: (info: ESObject) => {
          this.personContent(info as PersonData)
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
struct PersonWorkCard {

  @Require @State item?: FinItem = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as FinItem
  }

  build() {
    Column({ space: CommonConstants.SPACE_4 }) {
      Stack() {
        Image(this.item?.image?.primary)
          .alt($r('app.media.alt'))
          .objectFit(ImageFit.Cover)
          .autoResize(true)
          .width(CommonConstants.ITEM_WIDTH)
          .aspectRatio(CommonConstants.ITEM_RATIO)
          .borderRadius($r('app.float.md_border_radius'))
      }

      // 标题
      Text(this.item?.name)
        .fontSize($r('sys.float.Body_S'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(CommonConstants.ITEM_WIDTH)

      // 年份
      Text(this.item?.productionYear)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_tertiary'))
        .maxLines(1)
        .visibility(this.item?.productionYear ? Visibility.Visible : Visibility.None)
        .width(CommonConstants.ITEM_WIDTH)
    }
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      if (this.item) {
        MediaRouter.openDetail(this.item)
      }
    })
  }

}
