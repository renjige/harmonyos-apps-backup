import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspirationListCard } from '../components/inspiration/InspirationListCard'
import { InspirationItem, TagPresetItem } from '../models/InspirationModels'
import { RecentBrowseItem } from '../models/GrowthModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { WeeklyReviewService } from '../services/WeeklyReviewService'
import { GrowthService } from '../services/GrowthService'
import { AuthService } from '../services/AuthService'

@Component
export struct OrganizePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onOpenStats: () => void = () => {}
  onOpenAchievements: () => void = () => {}
  onOpenTopics: () => void = () => {}
  onOpenReview: () => void = () => {}
  @Prop embedded: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State filterDate: string = ''
  @State filterTag: string = ''
  @State filterWeek: boolean = false
  @State searchQuery: string = ''
  @State results: InspirationItem[] = []
  @State tagPresets: TagPresetItem[] = []
  @State recent: RecentBrowseItem[] = []
  @State searched: boolean = false
  @State sortMode: string = 'date_desc'
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.loadTags()
    void this.runFilter()
    void this.loadRecent()
  }

  onRefreshTokenChange(): void {
    void this.runFilter()
    void this.loadRecent()
  }

  private async loadTags(): Promise<void> {
    this.tagPresets = await InspirationBizService.loadTagPresets()
  }

  private async loadRecent(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.recent = []
      return
    }
    this.recent = await GrowthService.loadValidRecent(this.currentUsername, 4)
  }

  private openRecent(row: RecentBrowseItem): void {
    if (row.kind === 'featured') {
      InspirationDetailNav.openFeatured(row.id)
      return
    }
    if (row.kind === 'inspiration') {
      InspirationDetailNav.openInspiration(row.id)
      return
    }
    if (row.kind === 'board') {
      InspirationDetailNav.openBoard(row.id)
      return
    }
    if (row.kind === 'plan') {
      InspirationDetailNav.openPlan(row.id)
    }
  }

  private async runFilter(): Promise<void> {
    this.searched = true
    const q = this.searchQuery.trim()
    if (q.length > 0) {
      const res = await InspirationBizService.search(q, this.currentUsername)
      this.results = []
      for (const w of res.inspirations) {
        this.results.push(InspirationItem.fromWire(w))
      }
      this.applySort()
      return
    }
    let items = await InspirationBizService.loadInspirations(this.currentUsername)
    if (this.filterWeek) {
      const weekStart = WeeklyReviewService.weekStartIso()
      const filtered: InspirationItem[] = []
      for (const item of items) {
        if (WeeklyReviewService.inThisWeek(WeeklyReviewService.itemDate(item), weekStart)) {
          filtered.push(item)
        }
      }
      items = filtered
    }
    if (this.filterDate.length > 0) {
      const filtered: InspirationItem[] = []
      for (const item of items) {
        if (item.recordDate === this.filterDate) {
          filtered.push(item)
        }
      }
      items = filtered
    }
    if (this.filterTag.length > 0) {
      const filtered: InspirationItem[] = []
      for (const item of items) {
        let matched = false
        for (const t of item.tags) {
          if (t === this.filterTag) {
            matched = true
          }
        }
        if (matched) {
          filtered.push(item)
        }
      }
      items = filtered
    }
    this.results = items
    this.applySort()
  }

  private applySort(): void {
    if (this.results.length <= 1) {
      return
    }
    const sorted: InspirationItem[] = []
    for (const item of this.results) {
      sorted.push(item)
    }
    for (let i = 0; i < sorted.length - 1; i++) {
      for (let j = i + 1; j < sorted.length; j++) {
        if (this.shouldSwap(sorted[i], sorted[j])) {
          const tmp = sorted[i]
          sorted[i] = sorted[j]
          sorted[j] = tmp
        }
      }
    }
    this.results = sorted
  }

  private itemDateKey(item: InspirationItem): string {
    if (item.recordDate.length > 0) {
      return item.recordDate
    }
    return item.createdAt
  }

  private shouldSwap(a: InspirationItem, b: InspirationItem): boolean {
    if (this.sortMode === 'title') {
      return a.title > b.title
    }
    const da = this.itemDateKey(a)
    const db = this.itemDateKey(b)
    if (this.sortMode === 'date_asc') {
      return da > db
    }
    return da < db
  }

  private setSortMode(mode: string): void {
    if (this.sortMode === mode) {
      return
    }
    this.sortMode = mode
    this.applySort()
  }

  build() {
    Column() {
      if (!this.embedded) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => this.onClose())
          Text('归档回顾')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
      } else {
        Column({ space: 4 }) {
          Text('归档回顾')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('检索筛选 · 标签归档 · 日周月回顾')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY
        })
        .alignItems(HorizontalAlign.Start)
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s2 }) {
            Text('统计')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimaryPressed)
              .padding({ left: 10, right: 10, top: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.onOpenStats() })
            Text('成就')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimaryPressed)
              .padding({ left: 10, right: 10, top: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.onOpenAchievements() })
            Text('专题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimaryPressed)
              .padding({ left: 10, right: 10, top: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.onOpenTopics() })
            Text('回顾')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimaryPressed)
              .padding({ left: 10, right: 10, top: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.onOpenReview() })
          }
          .width('100%')

          if (this.recent.length > 0) {
            Column({ space: 6 }) {
              Text('最近浏览')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              ForEach(this.recent, (row: RecentBrowseItem) => {
                Text(row.title)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
                  .width('100%')
                  .padding({ top: 4, bottom: 4 })
                  .onClick((): void => { this.openRecent(row) })
              }, (row: RecentBrowseItem) => `${row.kind}_${row.id}`)
            }
            .width('100%')
          }

          Text(this.filterWeek ? '本周记录（点击取消）' : '只看本周')
            .fontSize(Theme.type.caption)
            .fontColor(this.filterWeek ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.filterWeek ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => {
              this.filterWeek = !this.filterWeek
              void this.runFilter()
            })

          AppDatePickerField({
            label: '按日期筛选',
            value: this.filterDate,
            placeholder: '不限日期',
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string) => { this.filterDate = v }
          })

          Column({ space: 8 }) {
            Text('按标签筛选')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tagPresets, (tag: TagPresetItem) => {
                Text(tag.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.filterTag === tag.title ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.filterTag === tag.title ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => {
                    this.filterTag = this.filterTag === tag.title ? '' : tag.title
                  })
              }, (tag: TagPresetItem) => tag.id)
            }
            .width('100%')
          }
          .width('100%')

          Row({ space: Theme.space.s2 }) {
            Text(this.sortMode === 'date_desc' ? '最新 ✓' : '最新')
              .fontSize(Theme.type.caption)
              .fontColor(this.sortMode === 'date_desc' ?
                Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.sortMode === 'date_desc' ?
                Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.setSortMode('date_desc') })
            Text(this.sortMode === 'date_asc' ? '最早 ✓' : '最早')
              .fontSize(Theme.type.caption)
              .fontColor(this.sortMode === 'date_asc' ?
                Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.sortMode === 'date_asc' ?
                Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.setSortMode('date_asc') })
            Text(this.sortMode === 'title' ? '标题 ✓' : '标题')
              .fontSize(Theme.type.caption)
              .fontColor(this.sortMode === 'title' ?
                Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.sortMode === 'title' ?
                Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.setSortMode('title') })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('关键词搜索')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.searchQuery, placeholder: '标题或正文关键词…' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.searchQuery = v })
          }
          .width('100%')

          AppButton({
            label: this.searched ? '刷新筛选' : '开始整理',
            onTap: (): void => { void this.runFilter() }
          })

          if (this.results.length === 0) {
            AppEmpty({
              title: this.searched ? '暂无匹配结果' : '还没有可整理的灵感',
              description: this.searched ? '试试调整日期、标签、本周或关键词' : '先去记录 Tab 写一条，这里会列出全部备忘'
            })
          } else {
            Text(`共 ${this.results.length} 条`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            ForEach(this.results, (item: InspirationItem) => {
              InspirationListCard({
                item: item,
                onTap: (): void => { InspirationDetailNav.openInspiration(item.id) }
              })
            }, (item: InspirationItem) => item.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
