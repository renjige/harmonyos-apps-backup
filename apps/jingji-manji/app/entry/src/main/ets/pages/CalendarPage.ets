import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { SportListCard } from '../components/sport/SportListCard'
import { SportRecord } from '../models/SportModels'
import { SportStore } from '../services/SportStore'
import { SportDetailNav } from '../services/SportDetailNav'
import { SportRecordService } from '../services/SportRecordService'

class CalendarCell {
  day: number = 0
  dateKey: string = ''
  inMonth: boolean = false
  sessionCount: number = 0
  totalMin: number = 0
  heatLevel: number = 0
}

@Component
export struct CalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State year: number = 2026
  @State month: number = 8
  @State cells: CalendarCell[] = []
  @State selectedKey: string = ''
  @State dayRecords: SportRecord[] = []
  @State monthSessions: number = 0
  @State monthDurationMin: number = 0
  @Prop refreshToken: number = 0
  onAddRecord: (dateKey: string) => void = () => {}

  aboutToAppear(): void {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth() + 1
    this.selectedKey = SportRecordService.todayKey()
    this.buildGrid()
    this.loadDay()
  }

  private buildGrid(): void {
    this.cells = buildCalendarCells(this.year, this.month, SportStore.list())
    this.monthSessions = countMonthSessions(this.year, this.month)
    this.monthDurationMin = countMonthDuration(this.year, this.month)
  }

  private loadDay(): void {
    this.dayRecords = this.selectedKey.length > 0 ? SportStore.byDate(this.selectedKey) : []
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m < 1) {
      m = 12
      y -= 1
    }
    if (m > 12) {
      m = 1
      y += 1
    }
    this.month = m
    this.year = y
    this.buildGrid()
  }

  private heatBg(level: number, selected: boolean): string {
    if (selected) {
      return Theme.colors().brandPrimary
    }
    if (level <= 0) {
      return 'transparent'
    }
    if (level === 1) {
      return Theme.isDark() ? '#1E3A5F' : '#DBEAFE'
    }
    if (level === 2) {
      return Theme.isDark() ? '#1D4ED8' : '#BFDBFE'
    }
    return Theme.isDark() ? '#2563EB' : '#93C5FD'
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        this.MonthHeader()
        this.CalendarGrid()
        this.HeatLegend()
        this.DayDetailSection()
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s6,
        bottom: Theme.space.s10 + 80
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
    .onAppear(() => {
      this.buildGrid()
      this.loadDay()
    })
  }

  @Builder
  MonthHeader() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => {
          this.shiftMonth(-1)
        })
        Text(`${this.year} 年 ${this.month} 月`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.shiftMonth(1)
        })
      }
      .width('100%')

      Text(`本月 ${this.monthSessions} 次 · ${this.monthDurationMin} 分钟 · 颜色越深负荷越高`)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  HeatLegend() {
    Row({ space: Theme.space.s3 }) {
      Text('负荷')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
      Row({ space: 6 }) {
        ForEach([0, 1, 2, 3], (lv: number) => {
          Column()
            .width(18)
            .height(10)
            .borderRadius(4)
            .backgroundColor(this.heatBg(lv, false))
        }, (lv: number) => `lg-${lv}`)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
  }

  @Builder
  CalendarGrid() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
          Text(w)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }, (w: string) => w)
      }
      .width('100%')

      Grid() {
        ForEach(this.cells, (cell: CalendarCell) => {
          GridItem() {
            Column({ space: 2 }) {
              Text(cell.inMonth ? `${cell.day}` : '')
                .fontSize(Theme.type.subhead)
                .fontColor(this.selectedKey === cell.dateKey ? Theme.colors().brandOnPrimary :
                  Theme.colors().textPrimary)
              if (cell.sessionCount > 0) {
                Text(`${cell.totalMin}分`)
                  .fontSize(Theme.type.overline)
                  .fontColor(this.selectedKey === cell.dateKey ? Theme.colors().brandOnPrimary :
                    Theme.colors().textSecondary)
              }
            }
            .width('100%')
            .height(52)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.heatBg(cell.heatLevel, this.selectedKey === cell.dateKey))
            .borderRadius(Theme.radius.md)
            .opacity(cell.inMonth ? 1 : 0.28)
            .onClick(() => {
              if (cell.inMonth && cell.dateKey.length > 0) {
                this.selectedKey = cell.dateKey
                this.loadDay()
              }
            })
          }
        }, (cell: CalendarCell) => cell.dateKey + cell.day + cell.heatLevel)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(4)
      .columnsGap(4)
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  DayDetailSection() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text(this.selectedKey.length > 0 ? `${this.selectedKey} 的训练` : '选择日期')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        if (this.selectedKey.length > 0) {
          AppButton({
            label: '补记',
            variant: 'secondary',
            onTap: (): void => {
              this.onAddRecord(this.selectedKey)
            }
          })
        }
      }
      .width('100%')

      if (this.dayRecords.length === 0) {
        Text('这一天还没有运动记录，可点「补记」快速录入。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.dayRecords, (item: SportRecord) => {
          SportListCard({
            record: item,
            onTap: (): void => {
              SportDetailNav.open(item.id)
            }
          })
        }, (item: SportRecord) => item.id)
      }
    }
    .width('100%')
  }
}

function buildCalendarCells(year: number, month: number, records: SportRecord[]): CalendarCell[] {
  const out: CalendarCell[] = []
  const first = new Date(year, month - 1, 1)
  const startWeek = first.getDay()
  const daysInMonth = new Date(year, month, 0).getDate()
  const prevDays = new Date(year, month - 1, 0).getDate()

  for (let i = 0; i < startWeek; i++) {
    const c = new CalendarCell()
    c.day = prevDays - startWeek + i + 1
    c.inMonth = false
    c.dateKey = ''
    out.push(c)
  }

  for (let d = 1; d <= daysInMonth; d++) {
    const c = new CalendarCell()
    c.day = d
    c.inMonth = true
    const m = String(month).padStart(2, '0')
    const day = String(d).padStart(2, '0')
    c.dateKey = `${year}-${m}-${day}`
    const dayList = filterRecordsByDate(records, c.dateKey)
    c.sessionCount = dayList.length
    c.totalMin = sumDuration(dayList)
    c.heatLevel = heatLevel(c.sessionCount, c.totalMin)
    out.push(c)
  }

  while (out.length % 7 !== 0) {
    const c = new CalendarCell()
    c.inMonth = false
    out.push(c)
  }
  return out
}

function filterRecordsByDate(records: SportRecord[], dateKey: string): SportRecord[] {
  const out: SportRecord[] = []
  for (const r of records) {
    if (r.recordDate === dateKey) {
      out.push(r)
    }
  }
  return out
}

function sumDuration(records: SportRecord[]): number {
  let total = 0
  for (const r of records) {
    total += r.durationMin
  }
  return total
}

function heatLevel(sessions: number, totalMin: number): number {
  if (sessions <= 0) {
    return 0
  }
  if (totalMin >= 90 || sessions >= 2) {
    return 3
  }
  if (totalMin >= 45) {
    return 2
  }
  return 1
}

function countMonthSessions(year: number, month: number): number {
  const prefix = `${year}-${String(month).padStart(2, '0')}`
  let n = 0
  for (const r of SportStore.list()) {
    if (r.recordDate.startsWith(prefix)) {
      n += 1
    }
  }
  return n
}

function countMonthDuration(year: number, month: number): number {
  const prefix = `${year}-${String(month).padStart(2, '0')}`
  let total = 0
  for (const r of SportStore.list()) {
    if (r.recordDate.startsWith(prefix)) {
      total += r.durationMin
    }
  }
  return total
}
