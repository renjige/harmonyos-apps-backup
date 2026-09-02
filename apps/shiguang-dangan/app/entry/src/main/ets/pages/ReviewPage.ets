import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { TimelineRail } from '../components/archive/TimelineRail'
import { DataCenterSection } from '../components/data/DataCenterSection'
import { ReviewSummary, TimelineNode } from '../models/ArchiveModels'
import { ArchiveStore } from '../services/ArchiveStore'
import { ArchiveStatsService } from '../services/ArchiveStatsService'
import { ArchiveDetailNav } from '../services/ArchiveDetailNav'
import { DateHelper } from '../services/DateHelper'
import { LifeStore } from '../services/LifeStore'

class CalendarDayCell {
  day: number = 0
  dateKey: string = ''
  hasDot: boolean = false
  isToday: boolean = false
  isCurrentMonth: boolean = true

  static make(day: number, dateKey: string, hasDot: boolean, isToday: boolean, isCurrentMonth: boolean): CalendarDayCell {
    const c = new CalendarDayCell()
    c.day = day
    c.dateKey = dateKey
    c.hasDot = hasDot
    c.isToday = isToday
    c.isCurrentMonth = isCurrentMonth
    return c
  }
}

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State segment: number = 0
  @State calendarCells: CalendarDayCell[] = []
  @State monthLabel: string = ''
  @State allNodes: TimelineNode[] = []
  @State filteredNodes: TimelineNode[] = []
  @State reviewToday: ReviewSummary = new ReviewSummary()
  @State reviewWeek: ReviewSummary = new ReviewSummary()
  @State reviewMonth: ReviewSummary = new ReviewSummary()
  @State reviewYear: ReviewSummary = new ReviewSummary()
  @State cursorMonth: Date = new Date()
  @State selectedDateKey: string = ''
  @State dayNodes: TimelineNode[] = []
  @State dayHabitNames: string[] = []
  @State dayHasActivity: boolean = false

  aboutToAppear(): void {
    this.selectedDateKey = DateHelper.todayKey()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.allNodes = await ArchiveStore.loadNodes()
    this.allNodes.sort((a, b) => DateHelper.compareKeys(a.dateKey, b.dateKey))
    this.filteredNodes = this.allNodes
    this.reviewToday = await ArchiveStatsService.buildReviewToday()
    this.reviewWeek = await ArchiveStatsService.buildReviewWeek()
    this.reviewMonth = await ArchiveStatsService.buildReviewMonth()
    this.reviewYear = await ArchiveStatsService.buildReviewYear()
    await this.buildCalendar()
    await this.loadDayDetail(this.selectedDateKey)
  }

  private async loadDayDetail(dateKey: string): Promise<void> {
    if (dateKey.length === 0) {
      this.dayNodes = []
      this.dayHabitNames = []
      this.dayHasActivity = false
      return
    }
    this.selectedDateKey = dateKey
    this.dayNodes = await ArchiveStore.nodesOnDate(dateKey)
    this.dayHabitNames = await LifeStore.habitNamesOnDate(dateKey)
    this.dayHasActivity = await ArchiveStore.hasActivityOnDate(dateKey)
  }

  private async selectDate(dateKey: string): Promise<void> {
    await this.loadDayDetail(dateKey)
  }

  private async buildCalendar(): Promise<void> {
    const y = this.cursorMonth.getFullYear()
    const m = this.cursorMonth.getMonth()
    this.monthLabel = DateHelper.displayMonthYear(this.cursorMonth)
    const first = new Date(y, m, 1)
    const startDow = first.getDay()
    const daysInMonth = new Date(y, m + 1, 0).getDate()
    const habitLogs = await LifeStore.loadHabitLogKeys()
    const activityDates = await ArchiveStore.loadActivityDateKeys()
    const nodeKeys: Set<string> = new Set()
    for (const n of this.allNodes) {
      nodeKeys.add(n.dateKey)
    }
    for (const line of habitLogs) {
      const parts = line.split('\t')
      if (parts.length >= 2) {
        nodeKeys.add(parts[1])
      }
    }
    for (const dk of activityDates) {
      nodeKeys.add(dk)
    }
    const cells: CalendarDayCell[] = []
    const todayKey = DateHelper.todayKey()
    for (let i = 0; i < startDow; i++) {
      cells.push(CalendarDayCell.make(0, '', false, false, false))
    }
    for (let d = 1; d <= daysInMonth; d++) {
      const dk = DateHelper.keyFromDate(new Date(y, m, d))
      const hasDot = nodeKeys.has(dk)
      cells.push(CalendarDayCell.make(d, dk, hasDot, dk === todayKey, true))
    }
    this.calendarCells = cells
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('回顾')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s2 }) {
          this.SegmentChip('日历', 0)
          this.SegmentChip('时间轴', 1)
          this.SegmentChip('回顾', 2)
          this.SegmentChip('数据', 3)
        }
        .width('100%')

        if (this.segment === 0) {
          this.CalendarSection()
          this.DayDetailSection()
        } else if (this.segment === 1) {
          if (this.filteredNodes.length === 0) {
            AppEmpty({
              title: '时间轴还是空的',
              description: '在档案里添加时间节点后，这里会按时间排列你的重要时刻。',
              actionLabel: '',
              onAction: (): void => {}
            })
          } else {
            TimelineRail({
              nodes: this.filteredNodes,
              onNodeTap: (id: string): void => { ArchiveDetailNav.openNodeDetail(id) }
            })
          }
        } else if (this.segment === 2) {
          this.ReviewCard(this.reviewToday)
          this.ReviewCard(this.reviewWeek)
          this.ReviewCard(this.reviewMonth)
          this.ReviewCard(this.reviewYear)
        } else {
          DataCenterSection({ refreshToken: this.refreshToken })
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

  @Builder
  SegmentChip(label: string, index: number) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.segment === index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.segment === index ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.segment = index })
  }

  @Builder
  CalendarSection() {
    Column({ space: Theme.space.s3 }) {
      Text(this.monthLabel)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
          Text(w)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }, (w: string) => w)
      }
      .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.calendarCells, (cell: CalendarDayCell, idx: number) => {
          Column({ space: 2 }) {
            Text(cell.day > 0 ? `${cell.day}` : '')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.cellTextColor(cell))
            if (cell.hasDot) {
              Column()
                .width(5)
                .height(5)
                .backgroundColor(Theme.colors().brandAccent)
                .borderRadius(Theme.radius.pill)
            }
          }
          .width('14.28%')
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.cellBackground(cell))
          .borderRadius(Theme.radius.sm)
          .onClick((): void => {
            if (cell.dateKey.length > 0) {
              void this.selectDate(cell.dateKey)
            }
          })
        }, (cell: CalendarDayCell, idx: number) => `${idx}_${cell.dateKey}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  private cellBackground(cell: CalendarDayCell): string {
    if (cell.dateKey.length > 0 && cell.dateKey === this.selectedDateKey) {
      return Theme.colors().brandPrimary
    }
    if (cell.isToday) {
      return Theme.colors().brandPrimaryContainer
    }
    return 'transparent'
  }

  private cellTextColor(cell: CalendarDayCell): string {
    if (cell.dateKey.length > 0 && cell.dateKey === this.selectedDateKey) {
      return Theme.colors().brandOnPrimary
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

      if (this.dayNodes.length === 0 && this.dayHabitNames.length === 0 && !this.dayHasActivity) {
        AppEmpty({
          title: '这一天还没有记录',
          description: '可在档案中添加节点，或在计划页完成习惯打卡，这里会自动留下足迹。',
          actionLabel: '',
          onAction: (): void => {}
        })
      } else {
        if (this.dayNodes.length > 0) {
          Text('时间节点')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          ForEach(this.dayNodes, (node: TimelineNode) => {
            Row({ space: Theme.space.s3 }) {
              Column()
                .width(8)
                .height(8)
                .backgroundColor(Theme.colors().brandAccent)
                .borderRadius(Theme.radius.pill)
              Column({ space: 4 }) {
                Text(node.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                if (node.whatHappened.length > 0) {
                  Text(node.whatHappened)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { ArchiveDetailNav.openNodeDetail(node.id) })
          }, (node: TimelineNode) => node.id)
        }

        if (this.dayHabitNames.length > 0) {
          Text('习惯打卡')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          ForEach(this.dayHabitNames, (name: string, index: number) => {
            Text(`✓ ${name}`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
          }, (name: string, index: number) => `${name}_${index}`)
        }

        if (this.dayHasActivity && this.dayNodes.length === 0 && this.dayHabitNames.length === 0) {
          Text('今日有整理记录（计划、档案等操作）')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
        }
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  ReviewCard(review: ReviewSummary) {
    Column({ space: Theme.space.s2 }) {
      Text(review.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
      Text(review.body)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
      ForEach(review.highlights, (h: string) => {
        Text(`· ${h}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textPrimary)
      }, (h: string) => h)
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Start)
  }
}
