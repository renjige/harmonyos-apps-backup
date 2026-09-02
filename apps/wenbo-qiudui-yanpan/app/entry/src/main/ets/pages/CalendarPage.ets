import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { MatchListCard } from '../components/sports/MatchListCard'
import { CalendarDay, MatchItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { DetailNav } from '../services/DetailNav'

@Component
export struct CalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('themeColorMode') themeColorMode: string = 'system'
  onClose: () => void = () => {}
  @State year: number = 2026
  @State month: number = 8
  @State days: CalendarDay[] = []
  @State allMatches: MatchItem[] = []
  @State selectedDate: string = ''
  @State dayMatches: MatchItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    const d = new Date()
    this.year = d.getFullYear()
    this.month = d.getMonth() + 1
    this.selectedDate = SportsBizService.todayIso()
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private monthLabel(): string {
    const ms: string = this.month < 10 ? `0${this.month}` : `${this.month}`
    return `${this.year}-${ms}`
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.days = await SportsBizService.loadCalendar(this.monthLabel())
    this.allMatches = await SportsBizService.loadMatches('', false, '')
    this.refreshDayMatches()
    this.loading = false
  }

  private refreshDayMatches(): void {
    const out: MatchItem[] = []
    for (const row of this.allMatches) {
      if (row.dateIso() === this.selectedDate) {
        out.push(row)
      }
    }
    this.dayMatches = out
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m > 12) {
      m = 1
      y += 1
    }
    if (m < 1) {
      m = 12
      y -= 1
    }
    this.month = m
    this.year = y
    void this.reload()
  }

  private dayCount(date: string): number {
    for (const row of this.days) {
      if (row.date === date) {
        return row.count
      }
    }
    return 0
  }

  private dateIsoForDay(dayNum: number): string {
    const ms: string = this.month < 10 ? `0${this.month}` : `${this.month}`
    const ds: string = dayNum < 10 ? `0${dayNum}` : `${dayNum}`
    return `${this.year}-${ms}-${ds}`
  }

  @Builder
  DayCell(dayNum: number) {
    Column({ space: 2 }) {
      Text(`${dayNum}`)
        .fontSize(Theme.type.subhead)
        .fontWeight(this.selectedDate === this.dateIsoForDay(dayNum) ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.selectedDate === this.dateIsoForDay(dayNum) ?
          Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      if (this.dayCount(this.dateIsoForDay(dayNum)) > 0) {
        Text(`${this.dayCount(this.dateIsoForDay(dayNum))}场`)
          .fontSize(10)
          .fontColor(this.selectedDate === this.dateIsoForDay(dayNum) ?
            Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
      }
    }
    .width('13%')
    .height(52)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.selectedDate === this.dateIsoForDay(dayNum) ?
      Theme.colors().brandPrimary : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => {
      this.selectedDate = this.dateIsoForDay(dayNum)
      this.refreshDayMatches()
    })
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })
        Column() {
          Text('赛事日历')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Text('按月浏览公开赛程')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      if (this.loading) {
        AppLoading({ label: '加载日历…' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row() {
              Column() {
                AppIcon({ name: 'chevron', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .rotate({ angle: 180 })
              .onClick((): void => { this.shiftMonth(-1) })
              Text(this.monthLabel())
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              Column() {
                AppIcon({ name: 'chevron', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { this.shiftMonth(1) })
            }
            .width('100%')

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.buildMonthDays(), (day: number) => {
                this.DayCell(day)
              }, (day: number) => `cal-day-${day}`)
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Text(`${this.selectedDate} · 赛程`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              if (this.dayMatches.length === 0) {
                AppEmpty({
                  title: '当天暂无比赛',
                  description: '可切换日期或查看其他月份'
                })
              } else {
                ForEach(this.dayMatches, (row: MatchItem) => {
                  MatchListCard({
                    item: row,
                    onTap: (): void => { DetailNav.openMatch(row.id) }
                  })
                }, (row: MatchItem) => `cal-match-${row.id}`)
              }
            }
            .width('100%')
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  private buildMonthDays(): number[] {
    const last = new Date(this.year, this.month, 0).getDate()
    const out: number[] = []
    let d = 1
    while (d <= last) {
      out.push(d)
      d += 1
    }
    return out
  }
}
