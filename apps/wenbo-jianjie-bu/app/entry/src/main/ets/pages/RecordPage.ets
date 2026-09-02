import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { WorkbenchHeader } from '../components/book/WorkbenchHeader'
import { EntryListCard } from '../components/book/EntryListCard'
import { TimelineRow, InsightEntry } from '../models/InsightModels'
import { ActivityItem, AdvancedFilter, ThinkingPlanWeek, WorkbenchStats } from '../models/GrowthModels'
import { DateHelper } from '../services/DateHelper'
import { InsightStore } from '../services/InsightStore'
import { WorkbenchService } from '../services/WorkbenchService'
import { GrowthStore } from '../services/GrowthStore'

@Component
export struct RecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop @Watch('onFilterChange') advancedFilter: AdvancedFilter = new AdvancedFilter()
  @Prop bottomInset: number = 76
  onCreate: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}
  onAskDelete: (id: string) => void = (_id: string) => {}
  onOpenOverlay: (kind: string) => void = (_k: string) => {}
  onOpenTool: (kind: string) => void = (_k: string) => {}
  onToast: (msg: string) => void = (_m: string) => {}
  @State rows: TimelineRow[] = []
  @State keyword: string = ''
  @State loaded: boolean = false
  @State filterMode: number = 0
  @State stats: WorkbenchStats = new WorkbenchStats()
  @State statStamp: number = 0
  @State plan: ThinkingPlanWeek = new ThinkingPlanWeek()
  @State activities: ActivityItem[] = []
  @StorageLink('themeRevision') themeRevision: number = 0
  @StorageLink('entryStamp') @Watch('onStampChange') entryStamp: number = 0

  aboutToAppear(): void {
    void this.reloadAll()
  }

  onRefreshTokenChange(): void {
    void this.reloadAll()
  }

  onStampChange(): void {
    void this.reloadAll()
  }

  onFilterChange(): void {
    void this.reloadTimeline()
  }

  private async reloadAll(): Promise<void> {
    await Promise.all([
      this.reloadWorkbench(),
      this.reloadTimeline()
    ])
  }

  private async reloadWorkbench(): Promise<void> {
    this.stats = await WorkbenchService.loadStats()
    this.plan = await GrowthStore.syncPlanFromEntries()
    this.activities = await GrowthStore.recentActivities(3)
    this.statStamp++
  }

  private filterActive(): boolean {
    return this.advancedFilter.keyword.length > 0 ||
      this.advancedFilter.starredOnly ||
      this.advancedFilter.frameKind.length > 0 ||
      this.advancedFilter.verdict.length > 0 ||
      this.advancedFilter.notebookId.length > 0 ||
      this.advancedFilter.monthKey.length > 0
  }

  private async reloadTimeline(): Promise<void> {
    let entries: InsightEntry[] = []
    const kw = this.keyword.length > 0 ? this.keyword : this.advancedFilter.keyword
    if (this.filterActive()) {
      const f = new AdvancedFilter()
      f.keyword = kw
      f.starredOnly = this.advancedFilter.starredOnly
      f.frameKind = this.advancedFilter.frameKind
      f.verdict = this.advancedFilter.verdict
      f.notebookId = this.advancedFilter.notebookId
      f.monthKey = this.advancedFilter.monthKey
      entries = await WorkbenchService.filterEntries(f)
    } else {
      const groups = await InsightStore.groupedByDay(kw)
      for (const g of groups) {
        for (const it of g.items) {
          entries.push(it)
        }
      }
    }
    InsightStore.sortEntries(entries)
    const rows: TimelineRow[] = []
    let lastDate = ''
    for (const it of entries) {
      if (this.filterMode === 1 && !it.starred) {
        continue
      }
      if (this.filterMode === 2 && !it.pinned) {
        continue
      }
      if (it.dateKey !== lastDate) {
        lastDate = it.dateKey
        const head = new TimelineRow()
        head.rowId = `h_${it.dateKey}`
        head.isHeader = true
        head.dateKey = it.dateKey
        rows.push(head)
      }
      const row = new TimelineRow()
      row.rowId = `${it.id}_${it.starred ? 's' : 'n'}_${it.pinned ? 'p' : 'u'}_${it.updatedAt}`
      row.isHeader = false
      row.dateKey = it.dateKey
      row.entry = it
      rows.push(row)
    }
    this.rows = rows
    this.loaded = true
  }

  private async handleCheckIn(): Promise<void> {
    if (this.stats.checkedIn) {
      this.onToast('今日已打卡')
      return
    }
    await GrowthStore.checkInToday('手动打卡')
    await this.reloadWorkbench()
    this.onToast('已完成今日书写打卡')
  }

  private async handleTogglePlan(index: number): Promise<void> {
    this.plan = await GrowthStore.togglePlanSlot(index)
    this.stats = await WorkbenchService.loadStats()
    this.plan = await GrowthStore.loadPlan()
    this.statStamp++
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        List() {
          ForEach([this.statStamp], (stamp: number) => {
            ListItem() {
              WorkbenchHeader({
                statStamp: stamp,
                total: this.stats.total,
                pendingJudge: this.stats.pendingJudge,
                starCount: this.stats.starCount,
                weekWrite: this.stats.weekWrite,
                streak: this.stats.streak,
                planDone: this.stats.planDone,
                planTotal: this.stats.planTotal,
                todayWritten: this.stats.todayWritten,
                checkedIn: this.stats.checkedIn,
                plan: this.plan,
                activities: this.activities,
                onCreate: (): void => { this.onCreate() },
                onOpenTool: (kind: string) => { this.onOpenTool(kind) },
                onOpenFavorites: (): void => { this.onOpenOverlay('favorites') },
                onOpenReview: (): void => { this.onOpenOverlay('review') },
                onOpenActivity: (): void => { this.onOpenOverlay('activity') },
                onOpenFilter: (): void => { this.onOpenOverlay('filter') },
                onTogglePlan: (index: number) => { void this.handleTogglePlan(index) },
                onCheckIn: (): void => { void this.handleCheckIn() }
              })
            }
          }, (stamp: number) => `wb_${stamp}`)
          ListItem() {
            this.FilterRow()
          }
          ListItem() {
            this.SearchRow()
          }
          if (this.loaded && this.rows.length === 0) {
            ListItem() {
              AppEmpty({
                title: this.keyword.length > 0 || this.filterActive() ? '没有匹配的见解' : '簿页还是空白',
                description: this.keyword.length > 0 || this.filterActive() ? '换个关键词或筛选条件' : '点右下角 + ，写下第一条见解',
                actionLabel: this.keyword.length > 0 || this.filterActive() ? '' : '写下见解',
                onAction: (): void => { this.onCreate() }
              })
            }
          } else {
            ForEach(this.rows, (row: TimelineRow) => {
              if (row.isHeader) {
                ListItem() {
                  Text(DateHelper.displayDate(row.dateKey))
                    .fontSize(Theme.type.caption)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textSecondary)
                    .padding({ top: 8, bottom: 8 })
                    .width('100%')
                }
              } else {
                ListItem() {
                  EntryListCard({
                    item: row.entry,
                    highlight: this.keyword,
                    starredFlag: row.entry.starred,
                    stamp: row.entry.updatedAt,
                    onOpen: (): void => { this.onOpen(row.entry.id) }
                  })
                    .margin({ bottom: 10 })
                }
              }
            }, (row: TimelineRow) => row.rowId)
          }
          ListItem() {
            Column().height(this.bottomInset)
          }
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: '#FFFFFF' })
      }
      .width(56)
      .height(56)
      .borderRadius(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .shadow({ radius: 16, color: 'rgba(59,45,142,0.28)', offsetY: 6 })
      .margin({ right: 20, bottom: 12 })
      .onClick((): void => { this.onCreate() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .opacity(this.themeRevision >= 0 ? 1 : 1)
  }

  @Builder
  FilterRow() {
    Row({ space: 8 }) {
      this.FilterChip('全部', 0)
      this.FilterChip('星标', 1)
      this.FilterChip('置顶', 2)
    }
    .width('100%')
    .padding({ bottom: Theme.space.s2 })
  }

  @Builder
  SearchRow() {
    Row({ space: 8 }) {
      AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
      TextInput({ text: this.keyword, placeholder: '搜索标题、正文或标签' })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textSecondary)
        .onChange((v: string) => {
          this.keyword = v
          void this.reloadTimeline()
        })
    }
    .width('100%')
    .height(44)
    .padding({ left: 12, right: 12 })
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.pill)
    .margin({ bottom: Theme.space.s4 })
  }

  @Builder
  FilterChip(label: string, mode: number) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filterMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.filterMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.sm)
      .onClick((): void => {
        this.filterMode = mode
        void this.reloadTimeline()
      })
  }
}
