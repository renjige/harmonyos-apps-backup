import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { XuAgendaItem, XuCalCell, XuDateHelper } from '../models/XuModels'
import { XuLocalStore } from '../services/XuLocalStore'
import { XuDetailNav } from '../services/XuDetailNav'
import { XuAgendaRow } from '../components/xu/XuAgendaRow'

@Component
export struct SchedulePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State year: number = 2026
  @State month: number = 1
  @State selected: string = ''
  @State cells: XuCalCell[] = []
  @State items: XuAgendaItem[] = []
  onDataChanged: () => void = () => {}
  private weekLabels: string[] = ['日', '一', '二', '三', '四', '五', '六']

  aboutToAppear(): void {
    const n = new Date()
    this.year = n.getFullYear()
    this.month = n.getMonth() + 1
    this.selected = XuDateHelper.todayKey()
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private applyFocusDate(): void {
    const focus = AppStorage.get<string>('xuAgendaFocusDate')
    if (focus === undefined || focus.length === 0) {
      return
    }
    this.selected = focus
    const parts = focus.split('-')
    if (parts.length === 3) {
      const y = Number.parseInt(parts[0], 10)
      const m = Number.parseInt(parts[1], 10)
      if (!Number.isNaN(y) && !Number.isNaN(m) && m >= 1 && m <= 12) {
        this.year = y
        this.month = m
      }
    }
    AppStorage.setOrCreate('xuAgendaFocusDate', '')
  }

  private async reload(): Promise<void> {
    await XuLocalStore.ensureReady()
    this.applyFocusDate()
    if (this.selected.length === 0) {
      this.selected = XuDateHelper.todayKey()
    }
    const agenda = await XuLocalStore.loadAgenda()
    this.cells = this.buildCells(agenda)
    const dayItems = await XuLocalStore.agendaOnDate(this.selected)
    this.items = []
    this.items = dayItems
  }

  private buildCells(agenda: XuAgendaItem[]): XuCalCell[] {
    const out: XuCalCell[] = []
    const first = XuDateHelper.firstWeekday(this.year, this.month)
    const dim = XuDateHelper.daysInMonth(this.year, this.month)
    const today = XuDateHelper.todayKey()
    for (let i = 0; i < 42; i++) {
      const day = i - first + 1
      const c = new XuCalCell()
      c.inMonth = day >= 1 && day <= dim
      if (c.inMonth) {
        c.dayNum = day
        c.dateKey = XuDateHelper.keyFromDate(new Date(this.year, this.month - 1, day))
        c.isToday = c.dateKey === today
        c.selected = c.dateKey === this.selected
        for (const a of agenda) {
          if (a.dateKey === c.dateKey) {
            c.hasItems = true
            break
          }
        }
      }
      out.push(c)
    }
    return out
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m < 1) {
      m = 12
      y = y - 1
    }
    if (m > 12) {
      m = 1
      y = y + 1
    }
    this.month = m
    this.year = y
    void this.reload()
  }

  private pick(cell: XuCalCell): void {
    if (!cell.inMonth) {
      return
    }
    this.selected = cell.dateKey
    void this.reload()
  }

  private openCreate(): void {
    XuDetailNav.openAgendaEditor('', this.selected)
  }

  private async toggleItem(it: XuAgendaItem): Promise<void> {
    it.done = !it.done
    it.updatedAt = Date.now()
    await XuLocalStore.saveAgenda(it)
    this.onDataChanged()
    void this.reload()
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s2 }) {
          Row() {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick(() => this.shiftMonth(-1))
            Text(XuDateHelper.monthTitle(this.year, this.month))
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick(() => this.shiftMonth(1))
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

          // 紧凑月历：固定高度，避免挤掉列表
          Column({ space: 4 }) {
            Row() {
              ForEach(this.weekLabels, (w: string) => {
                Text(w)
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.colors().textSecondary)
                  .width('14.28%')
                  .textAlign(TextAlign.Center)
              }, (w: string) => `w-${w}`)
            }
            .width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.cells, (c: XuCalCell) => {
                Column({ space: 1 }) {
                  Text(c.inMonth ? `${c.dayNum}` : '')
                    .fontSize(12)
                    .fontWeight(c.selected ? FontWeight.Medium : FontWeight.Normal)
                    .fontColor(c.selected ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  Circle()
                    .width(3)
                    .height(3)
                    .fill(c.hasItems ?
                      (c.selected ? Theme.colors().brandOnPrimary : Theme.colors().chart2) :
                      'transparent')
                }
                .width('14.28%')
                .height(36)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .backgroundColor(c.selected ? Theme.colors().brandPrimary :
                  (c.isToday ? Theme.colors().brandPrimaryContainer : 'transparent'))
                .borderRadius(Theme.radius.pill)
                .onClick(() => this.pick(c))
              }, (c: XuCalCell, idx: number) => `d-${idx}-${c.dateKey}-${c.hasItems ? '1' : '0'}-${c.selected ? 's' : ''}`)
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Row() {
            Text(this.selected.length > 0 ? `${this.selected} · ${this.items.length} 项` : '选择日期')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('添加')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick(() => this.openCreate())
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

          if (this.items.length === 0) {
            AppEmpty({
              title: '这一天还很清净',
              description: '点右下角或上方「添加」新建日程',
              actionLabel: '添加日程',
              onAction: (): void => { this.openCreate() }
            })
          } else {
            ForEach(this.items, (it: XuAgendaItem) => {
              XuAgendaRow({
                title: it.title,
                timeText: it.timeText,
                kindLabel: it.kindLabel(),
                priorityLabel: it.priorityLabel(),
                priority: it.priority,
                done: it.done,
                onOpen: () => XuDetailNav.openAgenda(it.id),
                onToggle: () => { void this.toggleItem(it) }
              })
                .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
            }, (it: XuAgendaItem) => `${it.id}_${it.done ? '1' : '0'}_${it.updatedAt}`)
          }

          // 为底栏 Tab + FAB 留白，避免最后一项被挡住
          Column().width('100%').height(Theme.nav.tabHeight + 72)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .margin({ right: Theme.space.pageX, bottom: Theme.nav.tabHeight + 20 })
      .shadow({ radius: 12, color: 'rgba(26,42,58,0.18)', offsetY: 4 })
      .onClick(() => this.openCreate())
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
