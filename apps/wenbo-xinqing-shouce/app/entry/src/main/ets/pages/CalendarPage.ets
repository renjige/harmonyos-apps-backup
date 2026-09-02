import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { MoodCatalog, MoodOption } from '../services/MoodCatalog'
import { AuthService } from '../services/AuthService'

class CalendarCell {
  day: number = 0
  iso: string = ''
  moodId: string = ''
  hasRecord: boolean = false
  inMonth: boolean = true
}

@Component
export struct CalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State diaries: JournalItem[] = []
  @State cells: CalendarCell[] = []
  @State loading: boolean = true
  @State viewYear: number = 2026
  @State viewMonth: number = 8
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    const now = new Date()
    this.viewYear = now.getFullYear()
    this.viewMonth = now.getMonth() + 1
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.diaries = await JournalBizService.loadDiaries(this.currentUsername)
    } else {
      this.diaries = []
    }
    this.buildCells()
    this.loading = false
  }

  private moodForDate(iso: string): string {
    for (const d of this.diaries) {
      if (d.recordDate === iso) {
        return d.kind
      }
    }
    return ''
  }

  private buildCells(): void {
    const first = new Date(this.viewYear, this.viewMonth - 1, 1)
    const startWeek = first.getDay()
    const daysInMonth = new Date(this.viewYear, this.viewMonth, 0).getDate()
    const prevMonthDays = new Date(this.viewYear, this.viewMonth - 1, 0).getDate()
    const out: CalendarCell[] = []
    for (let i = 0; i < startWeek; i++) {
      const cell = new CalendarCell()
      cell.inMonth = false
      cell.day = prevMonthDays - startWeek + i + 1
      out.push(cell)
    }
    for (let d = 1; d <= daysInMonth; d++) {
      const cell = new CalendarCell()
      cell.day = d
      cell.inMonth = true
      const mm = this.viewMonth < 10 ? `0${this.viewMonth}` : `${this.viewMonth}`
      const dd = d < 10 ? `0${d}` : `${d}`
      cell.iso = `${this.viewYear}-${mm}-${dd}`
      cell.moodId = this.moodForDate(cell.iso)
      cell.hasRecord = cell.moodId.length > 0 || this.diaries.some((x) => x.recordDate === cell.iso)
      out.push(cell)
    }
    while (out.length % 7 !== 0) {
      const cell = new CalendarCell()
      cell.inMonth = false
      cell.day = out.length - daysInMonth - startWeek + 1
      out.push(cell)
    }
    this.cells = out
  }

  private shiftMonth(delta: number): void {
    let m = this.viewMonth + delta
    let y = this.viewYear
    if (m < 1) {
      m = 12
      y -= 1
    } else if (m > 12) {
      m = 1
      y += 1
    }
    this.viewMonth = m
    this.viewYear = y
    this.buildCells()
  }

  private openDay(cell: CalendarCell): void {
    if (!cell.inMonth || !cell.hasRecord) {
      return
    }
    for (const d of this.diaries) {
      if (d.recordDate === cell.iso) {
        JournalDetailNav.openDiary(d.id)
        return
      }
    }
    void this.reload()
  }

  build() {
    Column() {
      AppHeader({ title: '心情日历', subtitle: '按月浏览每日心情轨迹' })
      if (this.loading) {
        AppLoading({ label: '加载日历…' }).layoutWeight(1)
      } else if (!AuthService.isLoggedIn()) {
        Column() {
          AppEmpty({
            title: '登录后查看日历',
            description: '游客可浏览首页回忆；登录后可同步个人心情日历',
            actionLabel: '去登录',
            onAction: (): void => { this.onRequireAuth() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row() {
              Column() {
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .rotate({ angle: 180 })
              .onClick((): void => { this.shiftMonth(-1) })
              Text(`${this.viewYear}年${this.viewMonth}月`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              Column() {
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { this.shiftMonth(1) })
            }
            .width('100%')

            Row() {
              ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
                Text(w)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
              }, (w: string) => w)
            }
            .width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.cells, (cell: CalendarCell, index: number) => {
                Column({ space: 4 }) {
                  Text(`${cell.day}`)
                    .fontSize(Theme.type.subhead)
                    .fontColor(cell.inMonth ? Theme.colors().textPrimary : Theme.colors().textSecondary)
                  if (cell.inMonth && cell.moodId.length > 0) {
                    Column()
                      .width(8)
                      .height(8)
                      .borderRadius(Theme.radius.pill)
                      .backgroundColor(MoodCatalog.colorOf(cell.moodId))
                  } else if (cell.inMonth && cell.hasRecord) {
                    Column()
                      .width(6)
                      .height(6)
                      .borderRadius(Theme.radius.pill)
                      .backgroundColor(Theme.colors().brandPrimary)
                  }
                }
                .width('14.28%')
                .height(52)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(cell.inMonth && cell.hasRecord ?
                  Theme.colors().brandPrimaryContainer : 'transparent')
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { this.openDay(cell) })
              }, (cell: CalendarCell, index: number) => `${index}_${cell.iso}_${cell.day}`)
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('图例')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(MoodCatalog.all(), (m: MoodOption) => {
                  Row({ space: 6 }) {
                    Column()
                      .width(8)
                      .height(8)
                      .borderRadius(Theme.radius.pill)
                      .backgroundColor(m.color)
                    Text(m.label)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  .margin({ right: 12, bottom: 8 })
                }, (m: MoodOption) => m.id)
              }
              .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .border({ width: 1, color: Theme.colors().strokeHairline })
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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
