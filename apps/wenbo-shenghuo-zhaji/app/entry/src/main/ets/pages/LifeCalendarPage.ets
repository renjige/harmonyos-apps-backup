import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { AuthService } from '../services/AuthService'

/** 按月查看有札记的日期，点选查看当天记录 */
@Component
export struct LifeCalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State diaries: JournalItem[] = []
  @State selectedDay: string = ''
  @State dayItems: JournalItem[] = []
  @State monthLabel: string = ''
  @State dayMarks: string[] = []
  @State monthDays: string[] = []
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    const now = new Date()
    this.monthLabel = `${now.getFullYear()}年${now.getMonth() + 1}月`
    this.monthDays = this.buildMonthDays()
    void this.reload()
  }

  private buildMonthDays(): string[] {
    const now = new Date()
    const y = now.getFullYear()
    const m = now.getMonth()
    const last = new Date(y, m + 1, 0).getDate()
    const mm = m + 1 < 10 ? `0${m + 1}` : `${m + 1}`
    const out: string[] = []
    for (let d = 1; d <= last; d++) {
      const dd = d < 10 ? `0${d}` : `${d}`
      out.push(`${y}-${mm}-${dd}`)
    }
    return out
  }

  private async reload(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.diaries = []
      this.dayMarks = []
      return
    }
    this.diaries = await JournalBizService.loadDiaries(this.currentUsername)
    const marks: string[] = []
    for (let i = 0; i < this.diaries.length; i++) {
      const d = this.diaries[i].recordDate
      if (d.length >= 10 && marks.indexOf(d) < 0) {
        marks.push(d)
      }
    }
    this.dayMarks = marks
    this.filterDay(this.selectedDay)
  }

  private hasMark(day: string): boolean {
    return this.dayMarks.indexOf(day) >= 0
  }

  private filterDay(day: string): void {
    this.selectedDay = day
    const items: JournalItem[] = []
    if (day.length === 0) {
      this.dayItems = items
      return
    }
    for (let i = 0; i < this.diaries.length; i++) {
      if (this.diaries[i].recordDate === day) {
        items.push(this.diaries[i])
      }
    }
    this.dayItems = items
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text('生活日历')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Text(this.monthLabel)
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.monthDays, (day: string) => {
              Column() {
                Text(day.substring(8))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.selectedDay === day ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              }
              .width(40)
              .height(40)
              .justifyContent(FlexAlign.Center)
              .margin({ right: 6, bottom: 6 })
              .borderRadius(Theme.radius.sm)
              .backgroundColor(this.selectedDay === day ?
                Theme.colors().brandPrimary :
                (this.hasMark(day) ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle))
              .onClick((): void => { this.filterDay(day) })
            }, (day: string) => day)
          }
          .width('100%')

          if (this.selectedDay.length === 0) {
            AppEmpty({
              title: '点选日期回顾',
              description: '有记录的日期会用浅色底标出'
            })
          } else if (this.dayItems.length === 0) {
            AppEmpty({
              title: `${this.selectedDay} 暂无札记`,
              description: '这一天还没有生活记录'
            })
          } else {
            ForEach(this.dayItems, (item: JournalItem) => {
              JournalListCard({
                item: item,
                compact: true,
                onTap: (): void => { JournalDetailNav.openDiary(item.id) }
              })
            }, (item: JournalItem) => item.id)
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
