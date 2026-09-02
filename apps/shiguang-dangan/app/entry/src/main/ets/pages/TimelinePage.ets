import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { CategoryChips } from '../components/archive/CategoryChips'
import { TimelineRail } from '../components/archive/TimelineRail'
import { TimelineNode } from '../models/ArchiveModels'
import { ArchiveStore } from '../services/ArchiveStore'
import { ArchiveDetailNav } from '../services/ArchiveDetailNav'
import { DateHelper } from '../services/DateHelper'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State allNodes: TimelineNode[] = []
  @State filtered: TimelineNode[] = []
  @State selectedCategory: string = ''
  @State selectedTag: string = ''
  @State selectedYear: string = ''
  @State catLabels: string[] = []
  @State catKeys: string[] = []
  @State tagLabels: string[] = []
  @State yearLabels: string[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const nodes = await ArchiveStore.loadNodes()
    nodes.sort((a, b) => DateHelper.compareKeys(a.dateKey, b.dateKey))
    this.allNodes = nodes
    const cats = await ArchiveStore.loadCategories()
    const labels: string[] = []
    const keys: string[] = []
    for (const c of cats) {
      labels.push(c.label)
      keys.push(c.key)
    }
    this.catLabels = labels
    this.catKeys = keys
    const tags = await ArchiveStore.loadTags()
    this.tagLabels = tags
    const years: string[] = []
    const seen: Set<string> = new Set()
    for (const n of nodes) {
      const y = DateHelper.yearFromKey(n.dateKey)
      if (y.length > 0 && !seen.has(y)) {
        seen.add(y)
        years.push(y)
      }
    }
    years.sort((a, b) => b.localeCompare(a))
    this.yearLabels = years
    await this.applyFilter()
  }

  private async applyFilter(): Promise<void> {
    const archives = await ArchiveStore.loadArchives()
    const archiveCat: Map<string, string> = new Map()
    for (const a of archives) {
      archiveCat.set(a.id, a.categoryKey)
    }
    const out: TimelineNode[] = []
    for (const n of this.allNodes) {
      if (this.selectedYear.length > 0 && !n.dateKey.startsWith(this.selectedYear)) {
        continue
      }
      if (this.selectedCategory.length > 0) {
        const cat = archiveCat.get(n.archiveId) ?? ''
        if (cat !== this.selectedCategory) {
          continue
        }
      }
      if (this.selectedTag.length > 0) {
        let hasTag = false
        for (const t of n.tags) {
          if (t === this.selectedTag) {
            hasTag = true
          }
        }
        if (!hasTag) {
          continue
        }
      }
      out.push(n)
    }
    this.filtered = out
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('时间轴')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Text('年份')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Scroll() {
          Row({ space: Theme.space.s2 }) {
            Text('全部')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.selectedYear.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.selectedYear.length === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.selectedYear = ''
                void this.applyFilter()
              })
            ForEach(this.yearLabels, (y: string) => {
              Text(y)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.selectedYear === y ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.selectedYear === y ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.selectedYear = y
                  void this.applyFilter()
                })
            }, (y: string) => y)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        CategoryChips({
          labels: this.catLabels,
          keys: this.catKeys,
          selectedKey: this.selectedCategory,
          showAll: true,
          onSelect: (key: string): void => {
            this.selectedCategory = key
            void this.applyFilter()
          }
        })

        if (this.tagLabels.length > 0) {
          Text('标签')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Scroll() {
            Row({ space: Theme.space.s2 }) {
              Text('全部')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.selectedTag.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.selectedTag.length === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.selectedTag = ''
                  void this.applyFilter()
                })
              ForEach(this.tagLabels, (tag: string) => {
                Text(tag)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.selectedTag === tag ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .backgroundColor(this.selectedTag === tag ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    this.selectedTag = tag
                    void this.applyFilter()
                  })
              }, (tag: string) => tag)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }

        if (this.filtered.length === 0) {
          AppEmpty({
            title: '暂无节点',
            description: '在档案中添加关键时间节点，这里将呈现完整人生轨迹',
            actionLabel: '创建档案',
            onAction: (): void => { ArchiveDetailNav.openCreateArchive() }
          })
        } else {
          TimelineRail({
            nodes: this.filtered,
            onNodeTap: (id: string): void => { ArchiveDetailNav.openNodeDetail(id) }
          })
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: this.bottomInset + Theme.space.s6
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
