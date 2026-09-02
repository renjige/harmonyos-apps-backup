import { Theme } from '../design-system/Theme'
import { CheckIn } from '../../models/SaituGrowthModels'
import { SaituCheckInStore } from '../../services/SaituCheckInStore'

class CalendarDay {
  day: number = 0
  key: string = ''
  inMonth: boolean = true
  checked: boolean = false
}

@Component
export struct CheckInCalendar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onDayTap: (dateKey: string) => void = () => {}
  @State year: number = 0
  @State month: number = 0
  @State days: CalendarDay[] = []
  @State checkedKeys: Set<string> = new Set<string>()

  aboutToAppear(): void {
    const d = new Date()
    this.year = d.getFullYear()
    this.month = d.getMonth() + 1
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private monthLabel(): string {
    const ms = this.month < 10 ? `0${this.month}` : `${this.month}`
    return `${this.year}-${ms}`
  }

  private async reload(): Promise<void> {
    const list = await SaituCheckInStore.loadCheckIns()
    const keys = new Set<string>()
    for (const c of list) {
      keys.add(c.dateKey)
    }
    this.checkedKeys = keys
    this.buildDays()
  }

  private buildDays(): void {
    const first = new Date(this.year, this.month - 1, 1)
    const startWeek = first.getDay()
    const daysInMonth = new Date(this.year, this.month, 0).getDate()
    const out: CalendarDay[] = []
    for (let i = 0; i < startWeek; i++) {
      const blank = new CalendarDay()
      blank.inMonth = false
      out.push(blank)
    }
    for (let d = 1; d <= daysInMonth; d++) {
      const cell = new CalendarDay()
      cell.day = d
      const ms = this.month < 10 ? `0${this.month}` : `${this.month}`
      const ds = d < 10 ? `0${d}` : `${d}`
      cell.key = `${this.year}-${ms}-${ds}`
      cell.checked = this.checkedKeys.has(cell.key)
      out.push(cell)
    }
    this.days = out
  }

  private prevMonth(): void {
    if (this.month === 1) {
      this.month = 12
      this.year--
    } else {
      this.month--
    }
    this.buildDays()
  }

  private nextMonth(): void {
    if (this.month === 12) {
      this.month = 1
      this.year++
    } else {
      this.month++
    }
    this.buildDays()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('上月')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .padding(8)
          .onClick((): void => this.prevMonth())
        Blank()
        Text(this.monthLabel())
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('下月')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .padding(8)
          .onClick((): void => this.nextMonth())
      }
      .width('100%')

      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
          Text(w)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width(`${100 / 7}%`)
            .textAlign(TextAlign.Center)
        }, (w: string) => w)
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.days, (cell: CalendarDay, idx: number) => {
          if (!cell.inMonth) {
            Column()
              .width(`${100 / 7}%`)
              .height(36)
          } else {
            Column() {
              Text(`${cell.day}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(cell.checked ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            }
            .width(`${100 / 7}%`)
            .height(36)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(cell.checked ? Theme.colors().brandPrimary : Color.Transparent)
            .borderRadius(Theme.radius.sm)
            .onClick((): void => this.onDayTap(cell.key))
          }
        }, (cell: CalendarDay, idx: number) => `${idx}_${cell.key}_${cell.day}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
