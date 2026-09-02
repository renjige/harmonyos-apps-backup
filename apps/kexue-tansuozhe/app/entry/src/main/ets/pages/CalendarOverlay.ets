import { Theme } from '../components/design-system/Theme'
import { DetailShell } from '../components/detail/DetailShell'
import { TimelineEvent } from '../models/ExplorationModels'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'

class DayCell {
  key: string = ''
  label: string = ''
  count: number = 0
}

@Component
export struct CalendarOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') @Watch('onRev') progressRev: number = 0
  @State days: DayCell[] = []
  @State selectedKey: string = ''
  @State dayEvents: TimelineEvent[] = []

  aboutToAppear(): void {
    this.buildMonth()
  }

  onRev(): void {
    this.buildMonth()
  }

  private buildMonth(): void {
    const today = ExplorationStore.todayKey()
    const parts = today.split('-')
    const y = parseInt(parts[0], 10)
    const m = parseInt(parts[1], 10)
    const cells: DayCell[] = []
    const dim = new Date(y, m, 0).getDate()
    for (let d = 1; d <= dim; d++) {
      const dd = d < 10 ? `0${d}` : `${d}`
      const mm = m < 10 ? `0${m}` : `${m}`
      const key = `${y}-${mm}-${dd}`
      const cell = new DayCell()
      cell.key = key
      cell.label = `${d}`
      cell.count = ExplorationStore.eventsOnDate(key).length +
        ExplorationStore.discoveriesOnDate(key).length
      cells.push(cell)
    }
    this.days = cells
    this.selectedKey = today
    this.dayEvents = ExplorationStore.eventsOnDate(today)
  }

  private selectDay(key: string): void {
    this.selectedKey = key
    this.dayEvents = ExplorationStore.eventsOnDate(key)
  }

  build() {
    DetailShell({
      title: '探索日历',
      onClose: (): void => { ExploreNav.closeCalendar() }
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('点击日期查看当天的探索与任务动态（本地数据）。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.days, (cell: DayCell) => {
              Column({ space: 2 }) {
                Text(cell.label)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.selectedKey === cell.key ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                if (cell.count > 0) {
                  Text(`${cell.count}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.selectedKey === cell.key ?
                      Theme.colors().brandOnPrimary : Theme.colors().brandAccent)
                }
              }
              .width('13%')
              .padding(8)
              .margin({ bottom: 6 })
              .backgroundColor(this.selectedKey === cell.key ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { this.selectDay(cell.key) })
            }, (cell: DayCell) => cell.key)
          }
          .width('100%')

          Text(`${this.selectedKey} 的动态`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          if (this.dayEvents.length === 0) {
            Text('这一天还没有探索动态，去记录一个小发现吧。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.dayEvents, (ev: TimelineEvent) => {
              Column({ space: 4 }) {
                Text(ev.title)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(ev.detail)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (ev: TimelineEvent) => ev.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
    }
  }
}
