import { Theme } from '../design-system/Theme'
import { CalCell, CalWeek } from '../../models/ShiyiModels'
import { CalendarUtil } from '../../services/CalendarUtil'

@Component
export struct MonthCalendar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop year: number = 2026
  @Prop month: number = 1
  @Prop marked: string[] = []
  onSelectDate: (date: string) => void = (date: string) => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        ForEach(CalendarUtil.weekdayLabels(), (label: string) => {
          Text(label)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
        }, (label: string) => label)
      }
      .width('100%')

      ForEach(CalendarUtil.weeksOf(this.year, this.month, this.marked), (week: CalWeek) => {
        Row() {
          ForEach(week.cells, (cell: CalCell) => {
            Column({ space: 4 }) {
              Text(cell.inMonth ? `${cell.day}` : '')
                .fontSize(Theme.type.subhead)
                .fontWeight(cell.isToday ? FontWeight.Medium : FontWeight.Normal)
                .fontColor(cell.isToday ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              if (cell.hasEntry) {
                Circle()
                  .width(5)
                  .height(5)
                  .fill(Theme.colors().brandAccent)
              } else {
                Circle()
                  .width(5)
                  .height(5)
                  .fill('transparent')
              }
            }
            .layoutWeight(1)
            .height(48)
            .justifyContent(FlexAlign.Center)
            .borderRadius(Theme.radius.sm)
            .backgroundColor(cell.isToday ? Theme.colors().brandPrimary : 'transparent')
            .onClick(() => {
              if (cell.inMonth && cell.date.length > 0) {
                this.onSelectDate(cell.date)
              }
            })
          }, (cell: CalCell) => `${week.id}_${cell.date}_${cell.day}`)
        }
        .width('100%')
      }, (week: CalWeek) => week.id)
    }
    .width('100%')
    .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
