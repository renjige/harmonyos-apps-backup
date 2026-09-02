import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppointmentItem } from '../models/AppointmentModels'
import { AppointmentService } from '../services/AppointmentService'

class CalendarCell {
  day: number = 0
  iso: string = ''
  count: number = 0
  inMonth: boolean = true
}

@Component
export struct CalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: AppointmentItem[] = []
  @State cells: CalendarCell[] = []
  @State loading: boolean = true
  @State viewYear: number = 2026
  @State viewMonth: number = 8
  @State selectedIso: string = ''
  @State selectedItems: AppointmentItem[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  @Prop overlayMode: boolean = false
  onOpenItem: (id: string) => void = () => {}
  onCreateForDate: (iso: string) => void = () => {}
  onClose: () => void = () => {}

  aboutToAppear(): void {
    const now = new Date()
    this.viewYear = now.getFullYear()
    this.viewMonth = now.getMonth() + 1
    this.selectedIso = ''
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    try {
      this.items = await AppointmentService.listAll()
      this.buildCells()
      if (this.selectedIso.length > 0) {
        this.selectedItems = await AppointmentService.listByDate(this.selectedIso)
      }
    } catch {
      this.items = []
      this.buildCells()
    }
    this.loading = false
  }

  private countForDate(iso: string): number {
    let count = 0
    for (const row of this.items) {
      if (row.dueDate === iso) {
        count += 1
      }
    }
    return count
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
      cell.count = this.countForDate(cell.iso)
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
    this.selectedIso = ''
    this.selectedItems = []
    this.buildCells()
  }

  private async selectDay(cell: CalendarCell): Promise<void> {
    if (!cell.inMonth) {
      return
    }
    this.selectedIso = cell.iso
    this.selectedItems = await AppointmentService.listByDate(cell.iso)
  }

  build() {
    Column() {
      if (this.overlayMode) {
        Row() {
          Text('关闭')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.onClose() })
          Blank()
          Text('月历')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
          Blank()
          Text('')
            .width(40)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12, bottom: 4 })
      }
      AppHeader({ title: '日历', subtitle: '按月浏览 · 颜色越深当天约定越多' })
      if (this.loading) {
        AppLoading({ label: '加载日历…' }).layoutWeight(1)
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
                  .fontColor(Theme.colors().textTertiary)
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
                    .fontColor(cell.inMonth ? Theme.colors().textPrimary : Theme.colors().textTertiary)
                  if (cell.inMonth && cell.count > 0) {
                    Text(`${cell.count}`)
                      .fontSize(Theme.type.overline)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  }
                }
                .width('14.28%')
                .height(52)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.selectedIso === cell.iso ?
                  Theme.colors().brandPrimaryContainer :
                  (cell.inMonth && cell.count > 2 ? Theme.colors().brandPrimaryContainer :
                    (cell.inMonth && cell.count > 0 ? Theme.colors().surfaceSubtle : 'transparent')))
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { void this.selectDay(cell) })
              }, (cell: CalendarCell, index: number) => `${index}_${cell.iso}_${cell.day}`)
            }
            .width('100%')

            if (this.selectedIso.length > 0) {
              Column({ space: 10 }) {
                Text(`${this.selectedIso} 的约定`)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                if (this.selectedItems.length === 0) {
                  AppEmpty({
                    title: '这一天没有约定',
                    description: '直接在这一天新建，避免漏记',
                    actionLabel: '这一天新建',
                    onAction: (): void => { this.onCreateForDate(this.selectedIso) }
                  })
                } else {
                  ForEach(this.selectedItems, (row: AppointmentItem) => {
                    Row({ space: 8 }) {
                      Column()
                        .width(4)
                        .height(32)
                        .backgroundColor(row.isDone() ? Theme.colors().success : Theme.colors().brandPrimary)
                        .borderRadius(Theme.radius.pill)
                      Column({ space: 2 }) {
                        Text(row.title)
                          .fontSize(Theme.type.subhead)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                          .width('100%')
                        Text(row.dueTime.length > 0 ? `${row.dueTime} · ${row.sceneLabel()}` : '全天')
                          .fontSize(Theme.type.caption)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                          .width('100%')
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .padding(12)
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.lg)
                    .onClick((): void => { this.onOpenItem(row.id) })
                  }, (row: AppointmentItem) => row.id)
                  Text('这一天新建')
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width('100%')
                    .textAlign(TextAlign.Center)
                    .padding(10)
                    .onClick((): void => { this.onCreateForDate(this.selectedIso) })
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
