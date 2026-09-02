import { Theme } from '../components/design-system/Theme'
import { CheckInStore } from '../services/CheckInStore'
import { ReadingPlan } from '../models/UserKnowledgeModels'

class CalendarCell {
  day: number = 0
  dateKey: string = ''
  inMonth: boolean = false
  checked: boolean = false
}

@Component
export struct CalendarOverlayPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @State monthLabel: string = ''
  @State cells: CalendarCell[] = []
  @State streakDays: number = 0
  @State checkinCount: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const now = new Date()
    this.monthLabel = `${now.getFullYear()}年${now.getMonth() + 1}月`
    this.streakDays = await CheckInStore.getStreakDays()
    const dates = await CheckInStore.getDates()
    this.checkinCount = dates.length
    this.cells = CalendarOverlayPage.buildCells(now, dates)
  }

  private static buildCells(now: Date, dates: string[]): CalendarCell[] {
    const y = now.getFullYear()
    const m = now.getMonth()
    const first = new Date(y, m, 1)
    const lastDay = new Date(y, m + 1, 0).getDate()
    let startPad = first.getDay()
    startPad = startPad === 0 ? 6 : startPad - 1
    const out: CalendarCell[] = []
    for (let i = 0; i < startPad; i++) {
      const c = new CalendarCell()
      c.inMonth = false
      out.push(c)
    }
    for (let d = 1; d <= lastDay; d++) {
      const c = new CalendarCell()
      c.day = d
      c.inMonth = true
      const dt = new Date(y, m, d)
      c.dateKey = ReadingPlan.dateKey(dt)
      c.checked = dates.indexOf(c.dateKey) >= 0
      out.push(c)
    }
    return out
  }

  build() {
    Column() {
      Row() {
        Text('阅读日历')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('返回')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => this.onClose())
      }
      .width('100%')
      .padding(Theme.space.pageX)

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s2 }) {
            this.statCard('连续打卡', `${this.streakDays} 天`)
            this.statCard('累计打卡', `${this.checkinCount} 天`)
          }
          .width('100%')

          Text(this.monthLabel)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

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

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.cells, (c: CalendarCell, index: number) => {
              Column() {
                if (c.inMonth) {
                  Text(`${c.day}`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(c.checked ? '#FFFFFF' : Theme.colors().textPrimary)
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .padding({ top: 10, bottom: 10 })
                    .backgroundColor(c.checked ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.sm)
                } else {
                  Blank().height(36)
                }
              }
              .width('14.28%')
              .padding(2)
            }, (c: CalendarCell, index: number) => `cal-${index}-${c.dateKey}`)
          }
          .width('100%')

          Text('蓝色日期表示当日有阅读/复习打卡记录')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(22)
  }

  @Builder
  statCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }
}
