import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { ActivityLog, LabelBucket, TreasureItem } from '../models/TreasureModels'
import { CalendarDayCell, DateHelper } from '../services/DateHelper'
import { ReviewService } from '../services/ReviewService'
import { TreasureNav } from '../services/TreasureNav'
import { TreasureStore } from '../services/TreasureStore'

@Component
export struct ReviewHubPage {
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State segment: number = 0
  @State total: number = 0
  @State albumCount: number = 0
  @State organized: number = 0
  @State highlight: number = 0
  @State activities: ActivityLog[] = []
  @State categories: LabelBucket[] = []
  @State reviewTitle: string = ''
  @State reviewBody: string = ''
  @State monthAdded: number = 0
  @State calendarCells: CalendarDayCell[] = []
  @State monthLabel: string = ''
  @State cursorMonth: Date = new Date()
  @State selectedDateKey: string = ''
  @State dayActivities: ActivityLog[] = []
  @State dayItems: TreasureItem[] = []

  aboutToAppear(): void {
    this.selectedDateKey = DateHelper.todayKey()
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.total = TreasureStore.activeItems().length
    this.albumCount = TreasureStore.albums().length
    this.organized = TreasureStore.organizedCount()
    this.highlight = TreasureStore.highlightCount()
    this.activities = TreasureStore.activities().slice(0, 30)
    this.categories = TreasureStore.categoryBuckets()
    this.monthAdded = TreasureStore.monthAddedCount()
    const snip = ReviewService.todaySnippet()
    this.reviewTitle = snip.title
    this.reviewBody = snip.body
    this.buildCalendar()
    this.loadDayDetail(this.selectedDateKey)
  }

  private buildCalendar(): void {
    this.monthLabel = DateHelper.monthLabel(this.cursorMonth)
    this.calendarCells = DateHelper.buildMonthCells(this.cursorMonth, TreasureStore.datesWithActivity())
  }

  private loadDayDetail(dateKey: string): void {
    this.selectedDateKey = dateKey
    this.dayActivities = TreasureStore.activitiesOnDate(dateKey)
    this.dayItems = TreasureStore.itemsOnDate(dateKey)
  }

  private shiftMonth(delta: number): void {
    const d = new Date(this.cursorMonth)
    d.setMonth(d.getMonth() + delta)
    this.cursorMonth = d
    this.buildCalendar()
  }

  private organizedPercent(): number {
    if (this.total <= 0) {
      return 0
    }
    return Math.round((this.organized / this.total) * 100)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('收藏回顾')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, top: Theme.space.s4 })

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(['回顾', '时间轴', '日历', '统计'], (label: string, idx: number) => {
              Text(label)
                .fontSize(Theme.type.caption)
                .fontColor(this.segment === idx ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.segment === idx ? Theme.colors().brandDeep : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.segment = idx })
            }, (label: string, idx: number) => `${label}_${idx}`)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        if (this.segment === 0) {
          this.ReviewSegment()
        } else if (this.segment === 1) {
          this.TimelineSegment()
        } else if (this.segment === 2) {
          this.CalendarSegment()
        } else {
          this.StatsSegment()
        }
      }
      .padding({ bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  ReviewSegment() {
    AppCard({
      title: this.reviewTitle,
      content: (): void => { this.ReviewIntroContent() }
    }).padding({ left: Theme.space.pageX, right: Theme.space.pageX })

    AppCard({
      title: '本月数据',
      content: (): void => { this.MonthDataContent() }
    }).padding({ left: Theme.space.pageX, right: Theme.space.pageX })

    AppCard({
      title: '收藏历程',
      content: (): void => { this.JourneyContent() }
    }).padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  ReviewIntroContent() {
    Text(this.reviewBody).fontColor(Theme.colors().textSecondary).lineHeight(22)
  }

  @Builder
  MonthDataContent() {
    Text(this.monthAdded > 0 ?
      `本月新增 ${this.monthAdded} 件珍藏` :
      '本月还没有新珍藏，不妨为某件物品建一份档案。')
      .fontColor(Theme.colors().textPrimary)
  }

  @Builder
  JourneyContent() {
    Column({ space: Theme.space.s2 }) {
      if (this.total === 0) {
        Text('从第一件珍藏开始，这里会留下你的收藏足迹。').fontColor(Theme.colors().textSecondary)
      } else {
        Text(`你已建立 ${this.total} 件珍藏档案`).fontColor(Theme.colors().textPrimary)
        Text(`${this.albumCount} 个主题册 · ${this.organized} 件已整理`).fontColor(Theme.colors().textSecondary)
      }
    }
  }

  @Builder
  TimelineSegment() {
    AppCard({
      title: '珍藏时间轴',
      content: (): void => { this.TimelineContent() }
    }).padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  TimelineContent() {
    if (this.activities.length === 0) {
      AppEmpty({
        title: '还没有收藏足迹',
        description: '建档、整理、创建主题册后，时间轴会自动记录。',
        actionLabel: '去建档',
        onAction: (): void => { TreasureNav.openEditor('') }
      })
    } else {
      Column({ space: Theme.space.s3 }) {
        ForEach(this.activities, (a: ActivityLog) => {
          Row({ space: Theme.space.s3 }) {
            Column()
              .width(8)
              .height(8)
              .backgroundColor(Theme.colors().brandAccent)
              .borderRadius(Theme.radius.pill)
            Column({ space: 4 }) {
              Text(a.dateKey).fontSize(Theme.type.caption).fontColor(Theme.colors().brandPrimary)
              Text(a.label).fontSize(Theme.type.body).fontColor(Theme.colors().textPrimary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
        }, (a: ActivityLog) => a.id)
      }
    }
  }

  @Builder
  CalendarSegment() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        AppButton({ label: '上月', variant: 'secondary', onTap: (): void => { this.shiftMonth(-1) } })
        Text(this.monthLabel)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        AppButton({ label: '下月', variant: 'secondary', onTap: (): void => { this.shiftMonth(1) } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      GridRow({ columns: 7, gutter: 4 }) {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
          GridCol({ span: 1 }) {
            Text(w).fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary).textAlign(TextAlign.Center)
          }
        }, (w: string) => `w_${w}`)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      GridRow({ columns: 7, gutter: 4 }) {
        ForEach(this.calendarCells, (cell: CalendarDayCell, idx: number) => {
          GridCol({ span: 1 }) {
            this.CalendarCell(cell)
          }
        }, (cell: CalendarDayCell, idx: number) => `c_${idx}_${cell.dateKey}`)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      this.DayDetailSection()
    }
  }

  @Builder
  CalendarCell(cell: CalendarDayCell) {
    Column({ space: 2 }) {
      Text(cell.day > 0 ? `${cell.day}` : '')
        .fontSize(Theme.type.subhead)
        .fontColor(this.cellTextColor(cell))
      if (cell.hasDot && cell.day > 0) {
        Column()
          .width(5)
          .height(5)
          .backgroundColor(this.selectedDateKey === cell.dateKey ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
      }
    }
    .width('100%')
    .height(44)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.cellBg(cell))
    .borderRadius(Theme.radius.sm)
    .onClick((): void => {
      if (cell.dateKey.length > 0) {
        this.loadDayDetail(cell.dateKey)
      }
    })
  }

  private cellBg(cell: CalendarDayCell): string {
    if (cell.dateKey.length > 0 && cell.dateKey === this.selectedDateKey) {
      return Theme.colors().brandPrimary
    }
    return 'transparent'
  }

  private cellTextColor(cell: CalendarDayCell): string {
    if (cell.dateKey.length > 0 && cell.dateKey === this.selectedDateKey) {
      return Theme.colors().brandOnPrimary
    }
    if (!cell.isCurrentMonth) {
      return Theme.colors().textTertiary
    }
    return Theme.colors().textPrimary
  }

  @Builder
  DayDetailSection() {
    Column({ space: Theme.space.s3 }) {
      Text(this.selectedDateKey.length > 0 ? DateHelper.displayDate(this.selectedDateKey) : '选择日期')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')

      if (this.dayActivities.length === 0 && this.dayItems.length === 0) {
        AppEmpty({
          title: '这一天还没有收藏活动',
          description: '新增珍藏或整理档案后，日历会自动留下记录。',
          actionLabel: '',
          onAction: (): void => {}
        })
      } else {
        ForEach(this.dayItems, (item: TreasureItem) => {
          Row() {
            Text(`入藏 · ${item.name}`).fontColor(Theme.colors().textPrimary).layoutWeight(1)
          }
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { TreasureNav.openDetail(item.id) })
        }, (item: TreasureItem) => `di_${item.id}`)

        ForEach(this.dayActivities, (a: ActivityLog) => {
          Text(a.label)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
        }, (a: ActivityLog) => `da_${a.id}`)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  StatsSegment() {
    GridRow({ columns: 2, gutter: Theme.space.s3 }) {
      GridCol({ span: 1 }) { AppStatCard({ label: '珍藏总数', value: `${this.total}` }) }
      GridCol({ span: 1 }) { AppStatCard({ label: '主题数量', value: `${this.albumCount}` }) }
      GridCol({ span: 1 }) { AppStatCard({ label: '已整理', value: `${this.organized}` }) }
      GridCol({ span: 1 }) { AppStatCard({ label: '重点珍藏', value: `${this.highlight}` }) }
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

    AppCard({
      title: '分类占比',
      content: (): void => { this.CategoryShareContent() }
    }).padding({ left: Theme.space.pageX, right: Theme.space.pageX })

    AppCard({
      title: '整理进度',
      content: (): void => { this.OrganizeProgressContent() }
    }).padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  CategoryShareContent() {
    Column({ space: Theme.space.s2 }) {
      ForEach(this.categories, (c: LabelBucket) => {
        Row() {
          Text(c.label).layoutWeight(1).fontColor(Theme.colors().textPrimary)
          Text(this.total > 0 ? `${Math.round((c.count / this.total) * 100)}%` : '0%')
            .fontColor(Theme.colors().brandPrimary)
        }
      }, (c: LabelBucket) => c.label)
    }
  }

  @Builder
  OrganizeProgressContent() {
    Column({ space: Theme.space.s2 }) {
      Text(`${this.organizedPercent()}% 档案已整理`).fontColor(Theme.colors().textPrimary)
      Row()
        .width(`${this.organizedPercent()}%`)
        .height(8)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
    }
  }
}
