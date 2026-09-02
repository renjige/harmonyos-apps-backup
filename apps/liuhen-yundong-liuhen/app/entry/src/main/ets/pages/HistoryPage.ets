import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { WorkoutListCard } from '../components/workout/WorkoutListCard'
import { TrendBar, WorkoutRecord } from '../models/WorkoutModels'
import { DateHelper } from '../services/DateHelper'
import { WorkoutStore } from '../services/WorkoutStore'
import { StatsService } from '../services/StatsService'

@Component
export struct HistoryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 88
  onOpenDetail: (record: WorkoutRecord) => void = () => {}
  @State viewYear: number = 0
  @State viewMonth: number = 0
  @State activeDates: string[] = []
  @State selectedKey: string = ''
  @State dayRecords: WorkoutRecord[] = []
  @State trendBars: TrendBar[] = []

  aboutToAppear(): void {
    const d = new Date()
    this.viewYear = d.getFullYear()
    this.viewMonth = d.getMonth() + 1
    this.selectedKey = DateHelper.todayKey()
    void this.reload()
  }

  onPageShow(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataEpochChange(): void {
    void this.reload()
  }

  private monthLabel(): string {
    return `${this.viewYear}年${this.viewMonth}月`
  }

  private shiftMonth(delta: number): void {
    let m = this.viewMonth + delta
    let y = this.viewYear
    if (m < 1) {
      m = 12
      y--
    } else if (m > 12) {
      m = 1
      y++
    }
    this.viewMonth = m
    this.viewYear = y
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.activeDates = await StatsService.monthActiveDates(this.viewYear, this.viewMonth)
    this.dayRecords = await WorkoutStore.workoutsForDate(this.selectedKey)
    this.trendBars = await StatsService.weeklyTrendBars(4)
  }

  private calendarCells(): number[] {
    const first = new Date(this.viewYear, this.viewMonth - 1, 1)
    const startPad = first.getDay() === 0 ? 6 : first.getDay() - 1
    const daysInMonth = DateHelper.monthKeys(this.viewYear, this.viewMonth).length
    const cells: number[] = []
    for (let i = 0; i < startPad; i++) {
      cells.push(0)
    }
    for (let d = 1; d <= daysInMonth; d++) {
      cells.push(d)
    }
    return cells
  }

  private dateKeyForDay(day: number): string {
    const m = this.viewMonth < 10 ? `0${this.viewMonth}` : `${this.viewMonth}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${this.viewYear}-${m}-${ds}`
  }

  private hasWorkout(day: number): boolean {
    const key = this.dateKeyForDay(day)
    for (const d of this.activeDates) {
      if (d === key) {
        return true
      }
    }
    return false
  }

  private maxTrend(): number {
    let m = 1
    for (const b of this.trendBars) {
      if (b.count > m) {
        m = b.count
      }
    }
    return m
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('历史回顾')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Row() {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .width(44)
          .height(44)
          .rotate({ angle: 180 })
          .onClick((): void => { this.shiftMonth(-1) })
          Blank()
          Text(this.monthLabel())
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .width(44)
          .height(44)
          .onClick((): void => { this.shiftMonth(1) })
        }
        .width('100%')

        Column({ space: Theme.space.s2 }) {
          Row() {
            ForEach(['一', '二', '三', '四', '五', '六', '日'], (w: string) => {
              Text(w)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
            }, (w: string) => w)
          }
          .width('100%')

          Grid() {
            ForEach(this.calendarCells(), (day: number) => {
              GridItem() {
                if (day === 0) {
                  Column().height(40)
                } else {
                  Column({ space: 4 }) {
                    Text(`${day}`)
                      .fontSize(Theme.type.bodyS)
                      .fontColor(this.selectedKey === this.dateKeyForDay(day) ?
                        Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    if (this.hasWorkout(day)) {
                      Column()
                        .width(6)
                        .height(6)
                        .backgroundColor(Theme.colors().brandPrimary)
                        .borderRadius(3)
                    }
                  }
                  .width('100%')
                  .height(40)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.selectedKey === this.dateKeyForDay(day) ?
                    Theme.colors().brandPrimary : Color.Transparent)
                  .borderRadius(Theme.radius.md)
                  .onClick((): void => {
                    this.selectedKey = this.dateKeyForDay(day)
                    void WorkoutStore.workoutsForDate(this.selectedKey).then((list: WorkoutRecord[]): void => {
                      this.dayRecords = list
                    })
                  })
                }
              }
            }, (day: number, index: number) => `${index}_${day}`)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
          .rowsGap(4)
          .columnsGap(4)
          .width('100%')
        }
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Text('近 4 周频率')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s2 }) {
          ForEach(this.trendBars, (bar: TrendBar) => {
            Column({ space: 4 }) {
              Column()
                .width('100%')
                .height(Math.max(8, (bar.count / this.maxTrend()) * 72))
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.sm)
              Text(bar.label)
                .fontSize(10)
                .fontColor(Theme.colors().textSecondary)
              Text(`${bar.count}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textPrimary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.End)
            .height(100)
          }, (bar: TrendBar) => bar.label)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Text(DateHelper.displayDate(this.selectedKey))
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        if (this.dayRecords.length === 0) {
          AppEmpty({
            title: '这一天没有记录',
            description: '选择有橙色圆点的日期查看详情'
          })
        } else {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.dayRecords, (rec: WorkoutRecord) => {
              WorkoutListCard({
                record: rec,
                onTap: (): void => { this.onOpenDetail(rec) }
              })
            }, (rec: WorkoutRecord) => rec.id)
          }
          .width('100%')
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: this.bottomInset
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
