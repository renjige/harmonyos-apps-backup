import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { NoteListCard } from '../components/note/NoteListCard'
import { NoteItem } from '../models/NoteModels'
import { MoodCatalog } from '../services/MoodCatalog'
import { NoteDateUtil } from '../services/NoteDateUtil'
import { NoteNav } from '../services/NoteNav'
import { NoteStore } from '../services/NoteStore'

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
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State cells: CalendarCell[] = []
  @State viewYear: number = 2026
  @State viewMonth: number = 8
  @State selectedIso: string = ''
  @State dayNotes: NoteItem[] = []
  onOpenWrite: (iso: string) => void = () => {}

  aboutToAppear(): void {
    const now = new Date()
    this.viewYear = now.getFullYear()
    this.viewMonth = now.getMonth() + 1
    this.buildCells()
  }

  onRefresh(): void {
    this.buildCells()
    if (this.selectedIso.length > 0) {
      this.dayNotes = NoteStore.byDate(this.selectedIso)
    }
  }

  private moodForDate(iso: string): string {
    const items = NoteStore.byDate(iso)
    if (items.length > 0) {
      return items[0].mood
    }
    return ''
  }

  private buildCells(): void {
    const first = new Date(this.viewYear, this.viewMonth - 1, 1)
    const startWeek = first.getDay()
    const daysInMonth = NoteDateUtil.daysInMonth(this.viewYear, this.viewMonth)
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
      cell.hasRecord = NoteStore.byDate(cell.iso).length > 0
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
    this.dayNotes = []
    this.buildCells()
  }

  private selectDay(cell: CalendarCell): void {
    if (!cell.inMonth) {
      return
    }
    this.selectedIso = cell.iso
    this.dayNotes = NoteStore.byDate(cell.iso)
  }

  build() {
    Column() {
      Column({ space: 4 }) {
        Text('森野日历')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('一眼看见哪些日子写过记录')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      .alignItems(HorizontalAlign.Start)

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
                if (cell.inMonth && cell.hasRecord) {
                  Column()
                    .width(8)
                    .height(8)
                    .borderRadius(Theme.radius.pill)
                    .backgroundColor(cell.moodId.length > 0 ?
                      MoodCatalog.colorOf(cell.moodId) : Theme.colors().brandAccent)
                }
              }
              .width('14.28%')
              .height(52)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(cell.iso === this.selectedIso ?
                Theme.colors().brandPrimaryContainer : 'transparent')
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { this.selectDay(cell) })
            }, (cell: CalendarCell, index: number) => `${index}_${cell.iso}_${cell.day}`)
          }
          .width('100%')

          if (this.selectedIso.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Row() {
                Text(NoteDateUtil.displayDate(this.selectedIso))
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text('补记')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .onClick((): void => { this.onOpenWrite(this.selectedIso) })
              }
              .width('100%')

              if (this.dayNotes.length === 0) {
                AppEmpty({
                  title: '这一天还没有记录',
                  description: '点「补记」写下当日内容',
                  actionLabel: '补记',
                  onAction: (): void => { this.onOpenWrite(this.selectedIso) }
                })
              } else {
                ForEach(this.dayNotes, (item: NoteItem) => {
                  NoteListCard({
                    item: item,
                    onTap: (): void => { NoteNav.openDetail(item.id) }
                  })
                }, (item: NoteItem) => item.id)
              }
            }
            .width('100%')
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
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
