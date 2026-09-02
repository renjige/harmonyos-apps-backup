import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { DiaryEntry } from '../models/DiaryModels'
import { DateHelper } from '../services/DateHelper'
import { DiaryStore } from '../services/DiaryStore'

class CalendarCell {
  day: number = 0
  dateKey: string = ''
  inMonth: boolean = true
  hasDiary: boolean = false
}

@Component
export struct CalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State year: number = 2026
  @State month: number = 8
  @State cells: CalendarCell[] = []
  @State selectedDate: string = ''
  @State dayEntries: DiaryEntry[] = []

  aboutToAppear(): void {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth() + 1
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const marked = await DiaryStore.datesWithEntries(this.year, this.month)
    this.buildCells(marked)
    if (this.selectedDate.length > 0) {
      this.dayEntries = await DiaryStore.findByDate(this.selectedDate)
    }
  }

  private buildCells(marked: Set<string>): void {
    const first = new Date(this.year, this.month - 1, 1)
    const startWeek = first.getDay()
    const daysInMonth = new Date(this.year, this.month, 0).getDate()
    const list: CalendarCell[] = []
    for (let i = 0; i < startWeek; i++) {
      const c = new CalendarCell()
      c.inMonth = false
      list.push(c)
    }
    for (let d = 1; d <= daysInMonth; d++) {
      const c = new CalendarCell()
      c.day = d
      c.inMonth = true
      c.dateKey = DateHelper.keyFromDate(new Date(this.year, this.month - 1, d))
      c.hasDiary = marked.has(c.dateKey)
      list.push(c)
    }
    this.cells = list
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m < 1) {
      m = 12
      y--
    } else if (m > 12) {
      m = 1
      y++
    }
    this.year = y
    this.month = m
    void this.reload()
  }

  private async selectDay(key: string): Promise<void> {
    this.selectedDate = key
    this.dayEntries = await DiaryStore.findByDate(key)
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .rotate({ angle: 180 })
          .onClick(() => this.shiftMonth(-1))
        Text(DateHelper.monthLabel(this.year, this.month))
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .onClick(() => this.shiftMonth(1))
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
          Text(w)
            .width('14.28%')
            .textAlign(TextAlign.Center)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .margin({ bottom: Theme.space.s2 })
        }, (w: string) => w)

        ForEach(this.cells, (c: CalendarCell) => {
          Column() {
            if (c.inMonth) {
              Text(`${c.day}`)
                .fontSize(Theme.type.body)
                .fontColor(this.selectedDate === c.dateKey ?
                  Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              if (c.hasDiary) {
                Circle()
                  .width(6)
                  .height(6)
                  .fill(Theme.colors().brandAccent)
                  .margin({ top: 2 })
              }
            }
          }
          .width('14.28%')
          .height(48)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.selectedDate === c.dateKey ?
            Theme.colors().brandPrimary : 'transparent')
          .borderRadius(Theme.radius.sm)
          .onClick(() => {
            if (c.inMonth) {
              void this.selectDay(c.dateKey)
            }
          })
        }, (c: CalendarCell) => `${c.dateKey}_${c.day}`)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (this.selectedDate.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text(DateHelper.displayDate(this.selectedDate))
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          if (this.dayEntries.length === 0) {
            Text('这一天还没有日记')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .padding({ left: Theme.space.pageX })
          } else {
            List({ space: Theme.space.s2 }) {
              ForEach(this.dayEntries, (e: DiaryEntry) => {
                ListItem() {
                  Text(e.previewLine())
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .padding(Theme.space.s4)
                    .width('100%')
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.md)
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              }, (e: DiaryEntry) => e.id)
            }
            .layoutWeight(1)
          }
        }
        .layoutWeight(1)
      }

      Blank().height(this.bottomInset)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
