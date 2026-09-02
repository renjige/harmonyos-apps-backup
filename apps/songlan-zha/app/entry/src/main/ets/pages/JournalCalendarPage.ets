import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { ZhaDateHelper, ZhaLocalStore } from '../services/ZhaLocalStore'
import { ZhaDetailNav } from '../services/ZhaDetailNav'

class CalendarCell {
  day: number = 0
  dateKey: string = ''
  hasJournal: boolean = false
  isCurrentMonth: boolean = true
  slotId: string = ''

  static build(day: number, key: string, has: boolean, inMonth: boolean, slotId: string): CalendarCell {
    const c = new CalendarCell()
    c.day = day
    c.dateKey = key
    c.hasJournal = has
    c.isCurrentMonth = inMonth
    c.slotId = slotId
    return c
  }
}

@Component
export struct JournalCalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State monthLabel: string = ''
  @State cells: CalendarCell[] = []
  @State journalKeys: string[] = []
  @State cursorYear: number = 2026
  @State cursorMonth: number = 0
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    const now = new Date()
    this.cursorYear = now.getFullYear()
    this.cursorMonth = now.getMonth()
    void this.reload()
  }

  onRefreshChange(): void {
    if (this.refreshToken > 0) {
      void this.reload()
    }
  }

  private async reload(): Promise<void> {
    const all = await ZhaLocalStore.loadJournals()
    const keys: string[] = []
    for (const j of all) {
      keys.push(j.dateKey)
    }
    this.journalKeys = keys
    this.buildGrid()
  }

  private buildGrid(): void {
    this.monthLabel = `${this.cursorYear}年${this.cursorMonth + 1}月`
    const first = new Date(this.cursorYear, this.cursorMonth, 1)
    const startWeek = first.getDay()
    const daysInMonth = new Date(this.cursorYear, this.cursorMonth + 1, 0).getDate()
    const grid: CalendarCell[] = []
    for (let i = 0; i < startWeek; i++) {
      grid.push(CalendarCell.build(0, '', false, false, `pad_${this.cursorYear}_${this.cursorMonth}_${i}`))
    }
    for (let d = 1; d <= daysInMonth; d++) {
      const dt = new Date(this.cursorYear, this.cursorMonth, d)
      const key = ZhaDateHelper.keyFromDate(dt)
      let has = false
      for (const k of this.journalKeys) {
        if (k === key) {
          has = true
          break
        }
      }
      grid.push(CalendarCell.build(d, key, has, true, key))
    }
    this.cells = grid
  }

  private prevMonth(): void {
    if (this.cursorMonth === 0) {
      this.cursorMonth = 11
      this.cursorYear--
    } else {
      this.cursorMonth--
    }
    this.buildGrid()
  }

  private nextMonth(): void {
    if (this.cursorMonth === 11) {
      this.cursorMonth = 0
      this.cursorYear++
    } else {
      this.cursorMonth++
    }
    this.buildGrid()
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          .rotate({ angle: 180 })
          .onClick(() => ZhaDetailNav.closeJournalCalendar())
        Text('札记日历')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Column().width(24)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      Row() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          .rotate({ angle: 180 })
          .padding(8)
          .onClick(() => this.prevMonth())
        Text(this.monthLabel)
          .fontSize(Theme.type.title3)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          .padding(8)
          .onClick(() => this.nextMonth())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
          Text(w)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }, (w: string) => w)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.cells, (c: CalendarCell) => {
          Column({ space: 2 }) {
            if (c.isCurrentMonth && c.day > 0) {
              Text(`${c.day}`)
                .fontSize(Theme.type.subhead)
                .fontColor(c.hasJournal ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              if (c.hasJournal) {
                Column()
                  .width(6)
                  .height(6)
                  .borderRadius(3)
                  .backgroundColor(Theme.colors().brandAccent)
              }
            }
          }
          .width('14.28%')
          .height(52)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(c.hasJournal ? Theme.colors().brandPrimary : Color.Transparent)
          .borderRadius(Theme.radius.sm)
          .onClick(() => {
            if (c.isCurrentMonth && c.day > 0) {
              ZhaDetailNav.openJournalDetail(c.dateKey)
            }
          })
        }, (c: CalendarCell) => c.slotId)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Text(`共 ${this.journalKeys.length} 天有札记 · 点击日期查看或编辑`)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
