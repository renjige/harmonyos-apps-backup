import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { ActivityEvent, CalendarDayMark } from '../../models/ShoppingModels'
import { GrowthService } from '../../services/GrowthService'
import { ShoppingLocalStore } from '../../services/ShoppingLocalStore'

@Component
export struct ProcurementCalendarOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State year: number = 2026
  @State month: number = 8
  @State marks: CalendarDayMark[] = []
  @State selectedKey: string = ''
  @State dayEvents: ActivityEvent[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  onClose: () => void = () => {}

  aboutToAppear(): void {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth() + 1
    this.selectedKey = ShoppingLocalStore.today()
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.marks = GrowthService.calendarMarks(this.year, this.month)
    this.dayEvents = GrowthService.eventsForDate(this.selectedKey)
  }

  private monthLabel(): string {
    return `${this.year} 年 ${this.month} 月`
  }

  private prevMonth(): void {
    this.month -= 1
    if (this.month < 1) {
      this.month = 12
      this.year -= 1
    }
    this.reload()
  }

  private nextMonth(): void {
    this.month += 1
    if (this.month > 12) {
      this.month = 1
      this.year += 1
    }
    this.reload()
  }

  private weekdayOfFirst(): number {
    const d = new Date(this.year, this.month - 1, 1)
    const w = d.getDay()
    return w === 0 ? 6 : w - 1
  }

  private padCount(): number {
    return this.weekdayOfFirst()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('采购日历')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Row() {
        Text('‹')
          .fontSize(22)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .padding(8)
          .onClick(() => this.prevMonth())
        Text(this.monthLabel())
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('›')
          .fontSize(22)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .padding(8)
          .onClick(() => this.nextMonth())
      }
      .width('100%')
      .padding({ left: 12, right: 12, bottom: 8 })

      Row() {
        ForEach(['一', '二', '三', '四', '五', '六', '日'], (w: string) => {
          Text(w)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }, (w: string) => w)
      }
      .width('100%')
      .padding({ left: 8, right: 8, bottom: 4 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(GrowthService.rangeArray(this.padCount()), (idx: number) => {
          Text('')
            .width('14.28%')
            .height(44)
        }, (idx: number) => `pad_${idx}`)

        ForEach(this.marks, (mark: CalendarDayMark) => {
          Column({ space: 2 }) {
            Text(mark.dateKey.substring(8, 10))
              .fontSize(Theme.type.subhead)
              .fontColor(this.selectedKey === mark.dateKey ?
                Theme.colors().brandOnPrimary : Theme.paint(this.themeEpoch).textPrimary)
            if (mark.checkIn) {
              Row()
                .width(6)
                .height(6)
                .backgroundColor(this.selectedKey === mark.dateKey ? '#FFFFFF' : Theme.colors().brandPrimary)
                .borderRadius(3)
            } else if (mark.checkedCount > 0) {
              Row()
                .width(6)
                .height(6)
                .backgroundColor(this.selectedKey === mark.dateKey ? '#FFFFFF' : Theme.colors().textSecondary)
                .borderRadius(3)
            }
          }
          .width('14.28%')
          .height(44)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor(this.selectedKey === mark.dateKey ?
            Theme.colors().brandPrimary : (mark.overBudget ? Theme.colors().surfaceSubtle : 'transparent'))
          .borderRadius(Theme.radius.md)
          .onClick((): void => {
            this.selectedKey = mark.dateKey
            this.dayEvents = GrowthService.eventsForDate(mark.dateKey)
          })
        }, (mark: CalendarDayMark) => mark.dateKey)
      }
      .width('100%')
      .padding({ left: 8, right: 8 })

      Text('● 打卡  ○ 勾选  浅色=当日超支参考')
        .fontSize(Theme.type.overline)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
        .padding({ left: 20, right: 20, top: 8 })

      Scroll() {
        Column({ space: 8 }) {
          Text(`${this.selectedKey} 动态`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .width('100%')
          if (this.dayEvents.length === 0) {
            AppEmpty({ title: '这一天还没有记录', description: '勾选物品或打卡后会出现在日历' })
          } else {
            ForEach(this.dayEvents, (e: ActivityEvent) => {
              Column({ space: 4 }) {
                Text(e.title)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                  .width('100%')
                Text(e.summary)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                  .width('100%')
                  .maxLines(2)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.lg)
            }, (e: ActivityEvent) => e.id)
          }
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
