import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { YdSearchHit, YdTag } from '../../models/YdModels'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdDetailNav } from '../../services/YdDetailNav'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct SearchSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State keyword: string = ''
  @State filter: string = 'all'
  @State tagId: string = ''
  @State daysBack: number = 0
  @State hits: YdSearchHit[] = []
  @State tags: YdTag[] = []

  aboutToAppear(): void {
    void this.loadTags()
  }

  private async loadTags(): Promise<void> {
    this.tags = await YdLocalStore.loadTags()
  }

  private async runSearch(): Promise<void> {
    this.hits = await YdLocalStore.searchAll(this.keyword, this.filter, this.tagId, this.daysBack)
  }

  private hasQuery(): boolean {
    return this.keyword.trim().length > 0 || this.tagId.length > 0 || this.daysBack > 0
  }

  build() {
    DetailShell({
      title: '搜索',
      onClose: (): void => { YdDetailNav.closeSearch() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s3 }) {
      TextInput({ text: this.keyword, placeholder: '搜任务、篇章、目标、微记…' })
        .onChange((v: string): void => {
          this.keyword = v
          void this.runSearch()
        })
      Row({ space: Theme.space.s2 }) {
        this.FilterChip('全部', 'all')
        this.FilterChip('任务', 'task')
        this.FilterChip('篇章', 'chapter')
        this.FilterChip('目标', 'goal')
      }
      .width('100%')

      Row({ space: Theme.space.s2 }) {
        this.DayChip('全部时间', 0)
        this.DayChip('近7天', 7)
        this.DayChip('近30天', 30)
      }
      .width('100%')

      if (this.tags.length > 0) {
        Scroll() {
          Row({ space: Theme.space.s2 }) {
            this.TagChip('全部标签', '')
            ForEach(this.tags, (t: YdTag) => {
              this.TagChip(t.label, t.id)
            }, (t: YdTag) => t.id)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }

      if (!this.hasQuery()) {
        Text('输入关键词、选标签或时间范围开始检索')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textTertiary)
      } else if (this.hits.length === 0) {
        AppEmpty({
          title: '没有匹配结果',
          description: '换个关键词或筛选条件试试',
          actionLabel: '',
          onAction: (): void => {}
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s2 }) {
            ForEach(this.hits, (h: YdSearchHit) => {
              Row({ space: Theme.space.s3 }) {
                Column() {
                  AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                }
                .width(40)
                .height(40)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.md)
                Column({ space: 2 }) {
                  Text(h.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(2)
                  Text(h.subtitle)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { YdDetailNav.openFromSearch(h.entityType, h.entityId) })
            }, (h: YdSearchHit) => `${h.entityType}_${h.entityId}`)
          }
          .width('100%')
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .padding(Theme.space.pageX)
    .height('100%')
  }

  @Builder
  FilterChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filter === value ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.filter === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.filter = value
        void this.runSearch()
      })
  }

  @Builder
  DayChip(label: string, days: number) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.daysBack === days ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.daysBack === days ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.daysBack = days
        void this.runSearch()
      })
  }

  @Builder
  TagChip(label: string, id: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.tagId === id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.tagId === id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.tagId = id
        void this.runSearch()
      })
  }
}
