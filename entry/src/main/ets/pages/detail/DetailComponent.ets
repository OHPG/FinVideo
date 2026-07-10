import { LengthMetrics } from "@kit.ArkUI"
import { CommonConstants } from "../common/CommonConstants"
import { DetailViewModel } from "./DetailViewModel"
import { Repository } from "../../data/Repository"
import LazyDataSource from "../common/LazyDataSource"
import { PlayerArgs } from "../player/PlayerArgs"
import { BreakpointSystem, FinItem, FinPerson } from "@ohpg/fin-core"
import { FinItemType, FinPersonType } from "@ohpg/fin-core"
import { AppRouter } from "../../router/AppRouter"
import { FinItemSource } from "../../entity/FinItemSource"
import { FinMediaTrack } from "../../entity/FinMediaTrack"

// ─── 辅助工具 ──────────────────────────────────────────────────────────────

/**
 * 将 source 的 width/height 映射为分辨率标签：4K / 1080p / 720p / 480p / SD
 */
function resolutionLabel(source: FinItemSource): string {
  const size = Math.max(source.width ?? 0, source.height ?? 0)
  if (size >= 3840) return '4K'
  if (size >= 1920) return '1080p'
  if (size >= 1280) return '720p'
  if (size >= 854) return '480p'
  return 'SD'
}

/**
 * 将 bps 码率转换为 Mbps 字符串
 */
function bitrateLabel(source: FinItemSource): string {
  if (source.bitrate && source.bitrate > 0) {
    return (source.bitrate / 1_000_000).toFixed(1) + 'Mbps'
  }
  return ''
}

/**
 * 将编码名转为大写展示
 */
function codecLabel(source: FinItemSource): string {
  if (source.videoCodec) {
    return source.videoCodec.toUpperCase()
  }
  return ''
}

/**
 * 构建 source 的简短描述：4K HEVC · 15.0Mbps
 */
function sourceShortDesc(source: FinItemSource): string {
  const parts: string[] = []
  const res = resolutionLabel(source)
  if (res) parts.push(res)
  const codec = codecLabel(source)
  if (codec) parts.push(codec)
  const br = bitrateLabel(source)
  if (br) parts.push(br)
  return parts.join(' · ')
}

/**
 * 构建 source 的完整描述：4K HEVC · 15.0Mbps · HDR
 */
function sourceFullDesc(source: FinItemSource): string {
  let desc = sourceShortDesc(source)
  if (!source.sdr) {
    desc += ' · ' + 'HDR'
  }
  return desc
}

// ─── 操作栏 ──────────────────────────────────────────────────────────────────

@Component
export struct DetailOperate {

  @LocalStorageLink("viewModel") viewModel?: DetailViewModel = undefined

  @Require callback: Callback<PlayerArgs>

  @Link itemDto: FinItem

  @State collecting: boolean = false

  @State collected: boolean = false

  @State finishing: boolean = false

  @State finished: boolean = false

  aboutToAppear(): void {
    if (this.viewModel) {
      this.finished = this.viewModel.isFinished()
      this.collected = this.viewModel.isFavourite()
    }
  }

  build() {
    Row({ space: CommonConstants.SPACE_8 }) {
      Button({ type: ButtonType.Capsule }) {
        Row({ space: CommonConstants.SPACE_4 }) {
          SymbolGlyph($r('sys.symbol.play_fill'))
            .fontColor([$r('sys.color.font_on_primary')])
            .fontSize($r('sys.float.Title_M'))
          Text($r('app.string.detail_play'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize($r('sys.float.Body_M'))
            .maxLines(1)
        }
      }
      .id('episode_play')
      .height(40)
      .padding({ left: CommonConstants.SPACE_16, right: CommonConstants.SPACE_16 })
      .type(ButtonType.Capsule)
      .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
      .onClick(() => {
        this.playOrNot()
      })

      Blank()

      Button({ type: ButtonType.Circle }) {
        if (this.finishing) {
          SymbolGlyph($r('sys.symbol.loading'))
            .fontSize($r('sys.float.Title_M'))
        } else {
          SymbolGlyph($r('sys.symbol.checkmark'))
            .fontColor([this.finished ? Color.Red : Color.Gray])
            .fontSize($r('sys.float.Title_M'))
        }
      }
      .id('episode_finish')
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .enabled(!this.finishing)
      .padding(CommonConstants.SPACE_4)
      .onClick(() => {
        this.finishOrNot()
      })

      Button({ type: ButtonType.Circle }) {
        if (this.collecting) {
          SymbolGlyph($r('sys.symbol.loading'))
            .fontSize($r('sys.float.Title_M'))
        } else {
          SymbolGlyph(this.collected ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
            .fontColor([this.collected ? Color.Red : Color.Gray])
            .fontSize($r('sys.float.Title_M'))
        }
      }
      .id('episode_collect')
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .enabled(!this.collecting)
      .padding(CommonConstants.SPACE_4)
      .onClick(() => {
        this.collectOrNot()
      })
    }
  }

  private playOrNot() {
    let args: PlayerArgs = {
      id: this.itemDto!.id!,
      name: this.itemDto!.name!,
      type: this.itemDto!.type!,
      preferredSourceId: this.viewModel?.getSelectedSourceId()
    }
    this.callback?.(args)
  }

  private finishOrNot() {
    this.finishing = true
    this.viewModel?.finishOrNot()
      .then((finished) => {
        this.finishing = false
        this.finished = finished
        this.itemDto!.data!.played = finished
      })
      .catch((error: Error) => {
        this.finishing = false
      })
  }

  private collectOrNot() {
    this.collecting = true
    this.viewModel?.favouriteOrNot()
      .then((collected) => {
        this.collecting = false
        this.collected = collected
        this.itemDto!.data!.isFavorite = collected
      })
      .catch((error: Error) => {
        this.collecting = false
      })
  }

  aboutToDisappear(): void {

  }

}

// ─── 背景图（短小氛围条 + 渐变遮罩） ──────────────────────────────────────────

@Component
export struct DetailCover {

  @StorageLink("Repository") repository?: Repository = undefined

  @Prop itemDto: FinItem

  @StorageProp(BreakpointSystem.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_SM

  @StorageProp(BreakpointSystem.CURRENT_HEIGHT_BREAKPOINT) currentHeightBreakpoint: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM

  build() {
    Stack() {
      // backdrop 图片
      Image(this.itemDto?.image?.backdrop)
        .alt($r('app.media.alt'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)

      // 底部渐变遮罩：从透明过渡到页面背景色
      Column()
        .width(CommonConstants.FULL_PERCENT)
        .height('60%')
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(0,0,0,0)', 0.0],
            [$r('sys.color.background_secondary'), 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(this.currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM
      ? $r('app.float.detail_backdrop_height') : $r('app.float.detail_backdrop_height_tablet'))
    .clip(true)
    .alignContent(Alignment.Bottom)
  }

}

// ─── 元信息标签行（年份·时长·评分·分级） ──────────────────────────────────────────

@Component
struct DetailMetaTags {

  @Prop itemDto: FinItem

  build() {
    if (this.itemDto.productionYear || this.itemDto.runtimeTicks
      || this.itemDto.officialRating || this.itemDto.communityRating) {
      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(CommonConstants.SPACE_8), cross: LengthMetrics.vp(CommonConstants.SPACE_4) } }) {
        if (this.itemDto.productionYear) {
          Text(this.itemDto.productionYear.toString())
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .padding({ left: CommonConstants.SPACE_8, right: CommonConstants.SPACE_8 })
            .height($r('app.float.detail_meta_tag_height'))
            .borderRadius($r('app.float.sm_border_radius'))
            .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
            .textAlign(TextAlign.Center)
        }

        if (this.itemDto.runtimeTicks) {
          Text($r('app.string.detail_runtime_format', Math.round(this.itemDto.runtimeTicks / 60000)))
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .padding({ left: CommonConstants.SPACE_8, right: CommonConstants.SPACE_8 })
            .height($r('app.float.detail_meta_tag_height'))
            .borderRadius($r('app.float.sm_border_radius'))
            .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
            .textAlign(TextAlign.Center)
        }

        if (this.itemDto.officialRating) {
          Text(this.itemDto.officialRating)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .padding({ left: CommonConstants.SPACE_8, right: CommonConstants.SPACE_8 })
            .height($r('app.float.detail_meta_tag_height'))
            .borderRadius($r('app.float.sm_border_radius'))
            .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
            .textAlign(TextAlign.Center)
        }

        if (this.itemDto.communityRating) {
          Row({ space: CommonConstants.SPACE_4 }) {
            SymbolGlyph($r('sys.symbol.star_fill'))
              .fontColor([Color.Orange])
              .fontSize($r('sys.float.Body_S'))
            Text(parseFloat(this.itemDto.communityRating).toFixed(1))
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
          .padding({ left: CommonConstants.SPACE_8, right: CommonConstants.SPACE_8 })
          .height($r('app.float.detail_meta_tag_height'))
          .borderRadius($r('app.float.sm_border_radius'))
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        }
      }
    }
  }

}

// ─── 版本选择器（横向 Chip 列表） ───────────────────────────────────────────────

@Component
export struct VersionSelector {

  @LocalStorageLink("viewModel") viewModel?: DetailViewModel = undefined

  @Consume selectedSourceIndex: number

  build() {
    if (this.viewModel && this.viewModel.hasMultipleSources()) {
      Column({ space: CommonConstants.SPACE_8 }) {
        Text($r('app.string.detail_version'))
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))

        List({ space: 8 }) {
          ForEach(this.viewModel.getSources()!, (source: FinItemSource, index: number) => {
            ListItem() {
              this.versionChip(source, index)
            }
          })
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.detail_version_chip_height'))
      }
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.FULL_PERCENT)
      .margin({ top: CommonConstants.SPACE_4 })
    }
  }

  @Builder
  versionChip(source: FinItemSource, index: number) {
    Row({ space: CommonConstants.SPACE_4 }) {
      // 默认版本标记
      if (index === 0) {
        Text($r('app.string.detail_version_default'))
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_on_primary'))
          .padding({ left: CommonConstants.SPACE_4, right: CommonConstants.SPACE_4 })
          .height(18)
          .borderRadius($r('app.float.xs_border_radius'))
          .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
          .textAlign(TextAlign.Center)
      }

      Text(resolutionLabel(source))
        .fontSize($r('sys.float.Body_S'))
        .fontColor(index === this.selectedSourceIndex
          ? $r('sys.color.font_on_primary')
          : $r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Medium)

      if (source.videoCodec) {
        Text(codecLabel(source))
          .fontSize($r('sys.float.Body_S'))
          .fontColor(index === this.selectedSourceIndex
            ? $r('sys.color.font_on_primary')
            : $r('sys.color.ohos_id_color_text_secondary'))
      }

      if (!source.sdr) {
        Text($r('app.string.detail_hdr'))
          .fontSize($r('sys.float.Body_S'))
          .fontColor(index === this.selectedSourceIndex
            ? $r('sys.color.font_on_primary')
            : $r('sys.color.ohos_id_color_emphasize'))
      }
    }
    .height($r('app.float.detail_version_chip_height'))
    .padding({ left: CommonConstants.SPACE_12, right: CommonConstants.SPACE_12 })
    .borderRadius($r('app.float.lg_border_radius'))
    .backgroundColor(index === this.selectedSourceIndex
      ? $r('sys.color.ohos_id_color_emphasize')
      : $r('sys.color.ohos_id_color_button_normal'))
    .onClick(() => {
      this.selectedSourceIndex = index
      this.viewModel?.setSelectedSourceIndex(index)
    })
  }

}

// ─── 海报 + 标题 + 评分标签行 ────────────────────────────────────────────────

@Component
export struct DetailPosterRow {

  @Prop itemDto: FinItem

  @StorageProp(BreakpointSystem.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_SM

  build() {
    Row({ space: CommonConstants.SPACE_12 }) {
      Image(this.itemDto?.image?.primary)
        .alt($r('app.media.alt'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .borderRadius($r('app.float.lg_border_radius'))
        .width(this.currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM
          ? $r('app.float.detail_poster_width') : $r('app.float.detail_poster_width_tablet'))
        .aspectRatio(CommonConstants.ITEM_RATIO)
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)

      Column({ space: CommonConstants.SPACE_8 }) {
        Text(this.itemDto?.name)
          .fontSize($r('sys.float.Title_M'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .maxLines(2)
          .ellipsisMode(EllipsisMode.END)

        DetailMetaTags({ itemDto: this.itemDto })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .alignItems(VerticalAlign.Bottom)
    .width(CommonConstants.FULL_PERCENT)
    .margin({ top: this.currentWidthBreakpoint <= WidthBreakpoint.WIDTH_SM ? -100 : -130 })
    .padding({ left: CommonConstants.SPACE_16, right: CommonConstants.SPACE_16 })
  }

}

// ─── 详情内容区（操作按钮 + 简介 + 风格/导演/编剧） ───────────────────────────

@Component
export struct DetailContent {

  @StorageLink("Repository") repository?: Repository = undefined

  @Prop itemDto: FinItem

  @State genres?: string = undefined

  @State actors?: string = undefined

  @State authors?: string = undefined

  aboutToAppear(): void {
    this.genres = this.itemDto.genres?.join("、")
    this.actors = this.itemDto.person?.filter((people) => {
      return people.type === FinPersonType.Director
    })?.map((person) => {
      return person.name
    })?.join("、")
    this.authors = this.itemDto.person?.filter((people) => {
      return people.type === FinPersonType.Writer
    })?.map((people) => {
      return people.name
    }).join("、")
  }

  build() {
    Column({ space: CommonConstants.SPACE_12 }) {

      // 操作按钮
      if (this.itemDto.type === FinItemType.Movie) {
        DetailOperate({
          itemDto: this.itemDto,
          callback: (args) => {
            AppRouter.goToPlayer(this.getUIContext(), args)
          }
        })
      }

      // 版本选择器
      if (this.itemDto.type === FinItemType.Movie) {
        VersionSelector()
      }

      // 简介
      if (this.itemDto.overview) {
        Column({ space: CommonConstants.SPACE_4 }) {
          Text($r('app.string.detail_overview'))
            .fontSize($r('sys.float.Title_S'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
          Text(this.itemDto.overview)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .lineHeight(22)
        }
        .alignItems(HorizontalAlign.Start)
        .width(CommonConstants.FULL_PERCENT)
      }

      // 风格
      if (this.genres) {
        Row({ space: CommonConstants.SPACE_8 }) {
          Text($r('app.string.detail_genres'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          Text(this.genres)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .layoutWeight(1)
        }
        .width(CommonConstants.FULL_PERCENT)
      }

      // 导演
      if (this.actors) {
        Row({ space: CommonConstants.SPACE_8 }) {
          Text($r('app.string.detail_directors'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          Text(this.actors)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .layoutWeight(1)
            .maxLines(2)
            .ellipsisMode(EllipsisMode.END)
        }
        .width(CommonConstants.FULL_PERCENT)
      }

      // 编剧
      if (this.authors) {
        Row({ space: CommonConstants.SPACE_8 }) {
          Text($r('app.string.detail_writers'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          Text(this.authors)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .layoutWeight(1)
            .maxLines(2)
            .ellipsisMode(EllipsisMode.END)
        }
        .width(CommonConstants.FULL_PERCENT)
      }
    }
    .padding({
      left: CommonConstants.SPACE_16,
      right: CommonConstants.SPACE_16
    })
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
  }

  aboutToDisappear(): void {

  }

}

// ─── 媒体信息区（横向滚动轨道卡片） ──────────────────────────────────────────

@Component
export struct DetailSourceBar {

  @LocalStorageLink("viewModel") viewModel?: DetailViewModel = undefined

  @Consume selectedSourceIndex: number

  build() {
    if (this.viewModel && this.viewModel.getSources() && this.viewModel.getSources()!.length > 0) {
      Column({ space: CommonConstants.SPACE_12 }) {
        // 标题
        Text($r('app.string.detail_media_info'))
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .margin({ left: CommonConstants.SPACE_16 })

        // 横向滚动轨道卡片（读取 selectedSourceIndex 确保响应式）
        if (this.getSource(this.selectedSourceIndex)?.tracks
          && this.getSource(this.selectedSourceIndex)!.tracks!.length > 0) {
          Scroll() {
            Row({ space: CommonConstants.SPACE_12 }) {
              ForEach(this.getSource(this.selectedSourceIndex)!.tracks!, (track: FinMediaTrack) => {
                this.trackCard(track)
              })
            }
            .alignItems(VerticalAlign.Top)
            .padding({ left: CommonConstants.SPACE_16, right: CommonConstants.SPACE_16 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .align(Alignment.Start)
          .width(CommonConstants.FULL_PERCENT)
        }

        // 文件路径
        if (this.getSource(this.selectedSourceIndex)?.path) {
          Text(this.getSource(this.selectedSourceIndex)!.path!)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .maxLines(2)
            .wordBreak(WordBreak.BREAK_ALL)
            .ellipsisMode(EllipsisMode.END)
            .margin({ left: CommonConstants.SPACE_16, right: CommonConstants.SPACE_16 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.FULL_PERCENT)
    }
  }

  private getSource(index: number): FinItemSource | undefined {
    const sources = this.viewModel?.getSources()
    if (sources && sources.length > 0) {
      return sources[index] ?? sources[0]
    }
    return undefined
  }

  @Builder
  trackCard(track: FinMediaTrack) {
    Column({ space: CommonConstants.SPACE_4 }) {
      // 卡片标题
      Text(track.title)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .ellipsisMode(EllipsisMode.END)

      // 详细参数
      if (track.type === 'Video') {
        this.videoTrackInfo(track)
      } else if (track.type === 'Audio') {
        this.audioTrackInfo(track)
      } else {
        this.subtitleTrackInfo(track)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(CommonConstants.SPACE_12)
    .borderRadius($r('app.float.lg_border_radius'))
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    .width(200)
  }

  @Builder
  videoTrackInfo(track: FinMediaTrack) {
    Column({ space: CommonConstants.SPACE_4 }) {
      if (track.codec) {
        this.infoRow($r('app.string.detail_track_codec'), track.codec.toUpperCase())
      }
      if (track.width && track.height) {
        this.infoRow($r('app.string.detail_track_resolution'), `${track.width} x ${track.height}`)
      }
      if (track.frameRate) {
        this.infoRow($r('app.string.detail_track_framerate'), track.frameRate.toString())
      }
      if (track.bitrate) {
        this.infoRow($r('app.string.detail_track_bitrate'), `${(track.bitrate / 1_000_000).toFixed(1)} Mbps`)
      }
      if (track.videoRangeType) {
        this.infoRow($r('app.string.detail_track_range'), track.videoRangeType)
      }
      if (track.aspectRatio) {
        this.infoRow($r('app.string.detail_track_aspect'), track.aspectRatio)
      }
      if (track.profile) {
        this.infoRow($r('app.string.detail_track_profile'), track.profile)
      }
      if (track.bitDepth) {
        this.infoRow($r('app.string.detail_track_bitdepth'), track.bitDepth.toString())
      }
      if (track.pixelFormat) {
        this.infoRow($r('app.string.detail_track_pixfmt'), track.pixelFormat)
      }
    }
  }

  @Builder
  audioTrackInfo(track: FinMediaTrack) {
    Column({ space: CommonConstants.SPACE_4 }) {
      if (track.language) {
        this.infoRow($r('app.string.detail_track_language'), track.language)
      }
      if (track.codec) {
        this.infoRow($r('app.string.detail_track_codec'), track.codec.toUpperCase())
      }
      if (track.channelLayout) {
        this.infoRow($r('app.string.detail_track_layout'), track.channelLayout)
      }
      if (track.channels) {
        this.infoRow($r('app.string.detail_track_channels'), track.channels.toString())
      }
      if (track.bitrate) {
        this.infoRow($r('app.string.detail_track_bitrate'), `${(track.bitrate / 1000).toFixed(1)} Kbps`)
      }
      if (track.sampleRate) {
        this.infoRow($r('app.string.detail_track_samplerate'), `${track.sampleRate} Hz`)
      }
    }
  }

  @Builder
  subtitleTrackInfo(track: FinMediaTrack) {
    Column({ space: CommonConstants.SPACE_4 }) {
      if (track.language) {
        this.infoRow($r('app.string.detail_track_language'), track.language)
      }
      if (track.codec) {
        this.infoRow($r('app.string.detail_track_codec'), track.codec.toUpperCase())
      }
      if (track.isExternal !== undefined) {
        this.infoRow($r('app.string.detail_track_external'), track.isExternal ? '是' : '否')
      }
      if (track.isForced) {
        this.infoRow($r('app.string.detail_track_forced'), '是')
      }
    }
  }

  @Builder
  infoRow(label: ResourceStr, value: string) {
    Row() {
      Text(label)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .width(56)
        .textAlign(TextAlign.Start)
      Text(value)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .maxLines(1)
        .ellipsisMode(EllipsisMode.END)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .width(CommonConstants.FULL_PERCENT)
  }

}

// ─── 演职人员 ──────────────────────────────────────────────────────────────────

@Component
export struct DetailFooter {

  @Require itemDto?: FinItem

  private personDataSource: LazyDataSource<FinPerson> = new LazyDataSource();

  aboutToAppear(): void {
    if (this.itemDto?.person) {
      this.personDataSource.appendArrayData(this.itemDto.person)
    }
  }

  build() {
    Column({ space: CommonConstants.SPACE_12 }) {
      Text($r('app.string.detail_cast'))
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .margin({
          left: CommonConstants.SPACE_16
        })

      List({ space: CommonConstants.SPACE_12 }) {
        LazyForEach(this.personDataSource, (person: FinPerson, index) => {
          ListItem() {
            PersonItem({ item: person })
          }
        })
      }
      .contentStartOffset(CommonConstants.SPACE_16)
      .contentEndOffset(CommonConstants.SPACE_16)
      .listDirection(Axis.Horizontal)
      .width(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .height(240)
    }
    .alignItems(HorizontalAlign.Start)
  }

  aboutToDisappear(): void {

  }

}

// ─── 演职人员卡片 ──────────────────────────────────────────────────────────────

@Reusable
@Component
struct PersonItem {

  @StorageLink("Repository") repository?: Repository = undefined

  @Require @State item?: FinPerson = undefined

  aboutToReuse(params: Record<string, object>): void {
    this.item = params['item'] as FinPerson
  }

  build() {
    Column({space: CommonConstants.SPACE_4}) {
      Image(this.item?.image?.primary)
        .alt($r('app.media.alt'))
        .borderRadius($r('app.float.lg_border_radius'))
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .width(120)
        .height(180)
      Text(this.item?.name)
        .maxLines(1)
        .ellipsisMode(EllipsisMode.END)
        .height(20)
      Text(this.item?.role)
        .maxLines(1)
        .ellipsisMode(EllipsisMode.END)
        .height(20)
    }
    .alignItems(HorizontalAlign.Start)
    .width(120)
    .height(220)
    .onClick(() => {
      if (this.item) {
        AppRouter.goToPersonDetail(this.getUIContext(), this.item)
      }
    })
  }

}
