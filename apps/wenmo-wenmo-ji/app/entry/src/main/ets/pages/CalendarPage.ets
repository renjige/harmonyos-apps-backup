import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadListCard } from '../components/wisdom/ReadListCard'
import { WisdomItem } from '../models/WisdomHallModels'
import { CheckinService } from '../services/CheckinService'
import { WisdomHallBizService } from '../services/WisdomHallBizService'
import { WisdomHallNav } from '../services/WisdomHallNav'
import { LunarHintUtil } from '../utils/LunarHintUtil'

class DayCell {
  day: number = 0
  inMonth: boolean = true
  dateKey: string = ''
  checked: boolean = false
  isToday: boolean = false
}

@Component
export struct CalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State year: number = 0
  @State month: number = 0
  @State cells: DayCell[] = []
  @State checkedToday: boolean = false
  @State streak: number = 0
  @State totalCheckins: number = 0
  @State topics: WisdomItem[] = []
  @State selectedTopic: WisdomItem = new WisdomItem()
  @State toastText: string = ''
  @State loading: boolean = true

  aboutToAppear(): void {
    const d = new Date()
    this.year = d.getFullYear()
    this.month = d.getMonth() + 1
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.checkedToday = await CheckinService.isChecked()
    this.streak = await CheckinService.streakDays()
    this.totalCheckins = await CheckinService.totalDays()
    this.topics = await WisdomHallBizService.loadTopics()
    if (this.topics.length > 0) {
      this.selectedTopic = this.topics[0]
    }
    this.cells = await CalendarPage.buildMonth(this.year, this.month)
    this.loading = false
  }

  private static async buildMonth(year: number, month: number): Promise<DayCell[]> {
    const first = new Date(year, month - 1, 1)
    const startWeek = first.getDay()
    const daysInMonth = new Date(year, month, 0).getDate()
    const cells: DayCell[] = []
    const todayKey = CheckinService.dateKey()
    for (let i = 0; i < startWeek; i++) {
      const c = new DayCell()
      c.inMonth = false
      cells.push(c)
    }
    for (let day = 1; day <= daysInMonth; day++) {
      const c = new DayCell()
      c.day = day
      c.inMonth = true
      const d = new Date(year, month - 1, day)
      c.dateKey = CheckinService.dateKey(d)
      c.isToday = c.dateKey === todayKey
      c.checked = await CheckinService.isChecked(c.dateKey)
      cells.push(c)
    }
    return cells
  }

  private async handleCheckin(): Promise<void> {
    const nowChecked = await CheckinService.toggleToday()
    this.checkedToday = nowChecked
    this.streak = await CheckinService.streakDays()
    this.totalCheckins = await CheckinService.totalDays()
    this.cells = await CalendarPage.buildMonth(this.year, this.month)
    if (nowChecked) {
      this.showToast('今日打卡成功，坚持文化传承')
    } else {
      this.showToast('已取消今日打卡')
    }
  }

  private shiftMonth(delta: number): void {
    let y = this.year
    let m = this.month + delta
    if (m < 1) {
      m = 12
      y -= 1
    } else if (m > 12) {
      m = 1
      y += 1
    }
    this.year = y
    this.month = m
    void CalendarPage.buildMonth(y, m).then((cells) => { this.cells = cells })
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              Text('文墨日历')
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(`${LunarHintUtil.todayLabel()} · ${LunarHintUtil.weekdayLabel()}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Text(LunarHintUtil.lunarHint())
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              Text(`${this.streak}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text('连续打卡')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            Column({ space: 4 }) {
              Text(`${this.totalCheckins}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandAccent)
              Text('累计打卡')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Row() {
              Column() {
                AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
              }
              .width(40)
              .height(40)
              .rotate({ angle: 180 })
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { this.shiftMonth(-1) })
              Text(`${this.year}年${this.month}月`)
                .fontSize(Theme.type.subtitleL)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              Column() {
                AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
              }
              .width(40)
              .height(40)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { this.shiftMonth(1) })
            }
            .width('100%')

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

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.cells, (cell: DayCell) => {
                Column() {
                  if (cell.inMonth) {
                    Text(`${cell.day}`)
                      .fontSize(Theme.type.subhead)
                      .fontColor(cell.isToday ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    if (cell.checked) {
                      Column()
                        .width(6)
                        .height(6)
                        .backgroundColor(cell.isToday ? Theme.colors().brandOnPrimary : Theme.colors().brandAccent)
                        .borderRadius(3)
                        .margin({ top: 2 })
                    }
                  }
                }
                .width('14.28%')
                .height(44)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(cell.isToday ? Theme.colors().brandPrimary : Color.Transparent)
                .borderRadius(8)
              }, (cell: DayCell, idx: number) => `${idx}-${cell.dateKey}`)
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          AppButton({
            label: this.checkedToday ? '今日已打卡 ✓' : '今日学习打卡',
            variant: this.checkedToday ? 'secondary' : 'primary',
            onTap: (): void => { void this.handleCheckin() }
          })

          Text('节气与文化')
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.loading) {
            Text('加载中…')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else if (this.topics.length === 0) {
            AppEmpty({ title: '暂无节气内容', description: '下拉刷新重试' })
          } else {
            ForEach(this.topics.slice(0, 4), (item: WisdomItem) => {
              ReadListCard({
                title: item.title,
                summary: (item.summary ?? '').length > 0 ? item.summary : (item.description ?? ''),
                category: (item.category ?? '').length > 0 ? item.category : '传统节气',
                readMinutes: item.readMinutes > 0 ? item.readMinutes : 3,
                coverKey: (item.coverKey ?? '').length > 0 ? item.coverKey : 'cover_topic_daily',
                onOpen: (): void => { WisdomHallNav.openDetail('topic', item.id) }
              })
            }, (item: WisdomItem) => item.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s10
        })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
