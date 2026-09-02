import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

export class CalendarDayInfo {
  day: number = 1
  dateStr: string = ''
  isCurrentMonth: boolean = true
  isToday: boolean = false
  hasLog: boolean = false
  isSelected: boolean = false

  constructor(
    day: number,
    dateStr: string,
    isCurrentMonth: boolean,
    isToday: boolean,
    hasLog: boolean,
    isSelected: boolean
  ) {
    this.day = day
    this.dateStr = dateStr
    this.isCurrentMonth = isCurrentMonth
    this.isToday = isToday
    this.hasLog = hasLog
    this.isSelected = isSelected
  }
}

@Component
export struct MonthCalendarView {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop year: number = 2026
  @Prop month: number = 8 // 1-indexed
  @Prop selectedDate: string = ''
  @Prop logDates: string[] = []
  onSelectDate: (dateStr: string) => void = () => {}
  onChangeMonth: (delta: number) => void = () => {}

  private daysOfWeek: string[] = ['日', '一', '二', '三', '四', '五', '六']

  private buildCalendarDays(): CalendarDayInfo[] {
    const days: CalendarDayInfo[] = []
    const firstDay = new Date(this.year, this.month - 1, 1).getDay()
    const totalDays = new Date(this.year, this.month, 0).getDate()

    const today = new Date()
    const todayStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`

    // Prev month padding
    const prevMonthTotalDays = new Date(this.year, this.month - 1, 0).getDate()
    for (let i = firstDay - 1; i >= 0; i--) {
      const d = prevMonthTotalDays - i
      const prevM = this.month === 1 ? 12 : this.month - 1
      const prevY = this.month === 1 ? this.year - 1 : this.year
      const dStr = `${prevY}-${String(prevM).padStart(2, '0')}-${String(d).padStart(2, '0')}`
      days.push(new CalendarDayInfo(d, dStr, false, false, false, false))
    }

    // Current month days
    for (let d = 1; d <= totalDays; d++) {
      const dStr = `${this.year}-${String(this.month).padStart(2, '0')}-${String(d).padStart(2, '0')}`
      const isToday = dStr === todayStr
      const hasLog = this.logDates.includes(dStr)
      const isSelected = dStr === this.selectedDate
      days.push(new CalendarDayInfo(d, dStr, true, isToday, hasLog, isSelected))
    }

    // Next month padding to fill full rows (multiple of 7)
    const remaining = 7 - (days.length % 7)
    if (remaining < 7) {
      for (let d = 1; d <= remaining; d++) {
        const nextM = this.month === 12 ? 1 : this.month + 1
        const nextY = this.month === 12 ? this.year + 1 : this.year
        const dStr = `${nextY}-${String(nextM).padStart(2, '0')}-${String(d).padStart(2, '0')}`
        days.push(new CalendarDayInfo(d, dStr, false, false, false, false))
      }
    }

    return days
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      // Month Header with Nav Arrows
      Row() {
        Text(`${this.year} 年 ${this.month} 月`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

        Blank()

        Row({ space: 12 }) {
          Row() {
            AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textSecondary })
          }
          .rotate({ angle: 180 })
          .padding(6)
          .backgroundColor(Theme.isDark() ? '#22302D' : '#F2F6F4')
          .borderRadius(Theme.radius.pill)
          .onClick(() => this.onChangeMonth(-1))

          Row() {
            AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textSecondary })
          }
          .padding(6)
          .backgroundColor(Theme.isDark() ? '#22302D' : '#F2F6F4')
          .borderRadius(Theme.radius.pill)
          .onClick(() => this.onChangeMonth(1))
        }
      }
      .width('100%')

      // Days of week header
      Row() {
        ForEach(this.daysOfWeek, (dw: string) => {
          Text(dw)
            .fontSize(Theme.type.caption1)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textTertiary)
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
        }, (dw: string) => dw)
      }
      .width('100%')
      .padding({ top: 4, bottom: 4 })

      // Days grid
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.buildCalendarDays(), (dayInfo: CalendarDayInfo) => {
          Column() {
            Stack({ alignContent: Alignment.Bottom }) {
              Column() {
                Text(`${dayInfo.day}`)
                  .fontSize(Theme.type.subheadline)
                  .fontWeight(dayInfo.isSelected || dayInfo.isToday ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(
                    !dayInfo.isCurrentMonth
                      ? Theme.colors().textTertiary
                      : dayInfo.isSelected
                      ? '#FFFFFF'
                      : dayInfo.isToday
                      ? Theme.colors().brandPrimary
                      : Theme.colors().textPrimary
                  )
              }
              .width(36)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(
                dayInfo.isSelected
                  ? Theme.colors().brandPrimary
                  : dayInfo.isToday
                  ? (Theme.isDark() ? '#1D3B32' : '#DDF2EB')
                  : 'transparent'
              )
              .borderRadius(Theme.radius.pill)

              // Indicator dot if has log
              if (dayInfo.hasLog) {
                Circle({ width: 5, height: 5 })
                  .fill(dayInfo.isSelected ? '#FFFFFF' : Theme.colors().brandSecondary)
                  .margin({ bottom: 3 })
              }
            }
            .width('100%')
            .height(42)
          }
          .width('14.28%')
          .onClick(() => {
            if (dayInfo.isCurrentMonth) {
              this.onSelectDate(dayInfo.dateStr)
            }
          })
        }, (dayInfo: CalendarDayInfo) => dayInfo.dateStr)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .shadow({
      radius: 12,
      color: Theme.isDark() ? 'rgba(0,0,0,0.3)' : 'rgba(10,37,64,0.05)',
      offsetY: 2
    })
  }
}
