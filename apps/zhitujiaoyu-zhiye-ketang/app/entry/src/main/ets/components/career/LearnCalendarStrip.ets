import { Theme } from '../design-system/Theme'
import { WeekDayCell } from '../../models/CareerModels'
import { StudyStatsService } from '../../services/StudyStatsService'

/** 本周学习日历条 — 展示每日学习分钟与打卡状态 */
@Component
export struct LearnCalendarStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressTick') progressTick: number = 0

  private weekDays(): WeekDayCell[] {
    return StudyStatsService.weekCalendar()
  }

  private todayMinutes(): number {
    return StudyStatsService.getTodayMinutes()
  }

  private weekDaysStudied(): number {
    return StudyStatsService.studiedDaysThisWeek()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column({ space: 2 }) {
          Text('本周学习')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(`今日 ${this.todayMinutes()} 分钟 · 已学 ${this.weekDaysStudied()} 天`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Text(`${StudyStatsService.getTotalMinutes()} 分钟`)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
      .width('100%')

      Row({ space: Theme.space.s2 }) {
        ForEach(this.weekDays(), (cell: WeekDayCell) => {
          Column({ space: 4 }) {
            Text(cell.label)
              .fontSize(Theme.type.overline)
              .fontColor(cell.isToday ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
            Column() {
              if (cell.studied) {
                Text(`${cell.minutes}`)
                  .fontSize(10)
                  .fontColor(Theme.colors().brandOnPrimary)
              }
            }
            .width(36)
            .height(36)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(cell.studied ?
              Theme.colors().brandPrimary :
              (cell.isToday ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard))
            .borderRadius(Theme.radius.pill)
            .border({
              width: cell.isToday ? 2 : 1,
              color: cell.isToday ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
            })
          }
          .layoutWeight(1)
        }, (cell: WeekDayCell) => cell.dateKey)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
