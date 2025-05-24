import { window } from '@kit.ArkUI'
import { BaseItemDto, ImageType } from '@ohpg/jellyfin'
import { BreakpointTypeEnum } from '@ohpg/fin-core'
import { CommonConstants } from '../common/CommonConstants'
import { MediaListArgs } from './MediaListArgs'
import { Repository } from '../../data/Repository'
import { MediaRouter } from '../common/MediaRouter'
import { MediaListVewModel } from './MediaListVewModel'
import { GridRefreshView } from '@ohpg/fin-framework'
import { ToolBar } from '@ohpg/fin-framework'

@Entry
@Component
struct MediaListPage {

  private args = this.getUIContext().getRouter().getParams() as MediaListArgs

  private viewModel = new MediaListVewModel(this.args, this.getUIContext().getHostContext()!)

  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  @StorageProp('currentAvoidArea') currentAvoidArea?: window.AvoidArea = undefined

  @Builder
  mediaListView(info: BaseItemDto, index: number) {
    MediaItem({item: info})
  }

  build() {
    Column() {

      ToolBar({
        title: this.args.name
      })

      GridRefreshView({
        source: this.viewModel,
        gridAttribute: (attr) => {
          attr.padding = {
            left: CommonConstants.SPACE_16,
            right: CommonConstants.SPACE_16,
            bottom: px2vp(this.currentAvoidArea?.bottomRect.height)
          }
          attr.rowsGap = CommonConstants.SPACE_12
          attr.columnsGap = CommonConstants.SPACE_12
          attr.columnsTemplate = 'repeat(auto-fit, 140)'
          attr.width = CommonConstants.FULL_PERCENT
          attr.height = CommonConstants.FULL_PERCENT
        },
        itemLayout: this.mediaListView
      })
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
    }
  }

}

@Reusable
@Component
struct MediaItem {

  @StorageLink("Repository") repository?: Repository = undefined

  @Require @State item?: BaseItemDto = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as BaseItemDto
  }

  build() {
    Stack() {
      Image(this.repository?.buildImage(this.item!, ImageType.Primary))
        .alt($r('app.media.alt'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .borderRadius($r('app.float.lg_border_radius'))
        .width('100%')
        .aspectRatio(0.67)
    }
    .onClick(() => {
      MediaRouter.openDetail(this.item!.Type!, {
        id: this.item!.Id!,
        name: this.item!.Name!
      })
    })
  }

  aboutToRecycle(): void {
  }

}