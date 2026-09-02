import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { TaskRow } from '../components/family/TaskRow'
import { DayCell, FamilyTaskItem, TaskDates } from '../models/FamilyTaskModels'
import { TaskService } from '../services/TaskService'

@Component
export struct CalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State cursor: string = TaskDates.today()
  @State selected: string = TaskDates.today()
  @State cells: DayCell[] = []
  @State dayItems: FamilyTaskItem[] = []
  @State all: FamilyTaskItem[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  onOpen: (item: FamilyTaskItem) => void = (_i: FamilyTaskItem) => {}
  onToggle: (item: FamilyTaskItem) => void = (_i: FamilyTaskItem) => {}
  onAdd: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.all = await TaskService.all()
    this.rebuild()
    this.dayItems = await TaskService.byDate(this.selected)
  }

  private monthTitle(): string {
    const d = TaskDates.parse(this.cursor)
    return `${d.getFullYear()}年${d.getMonth() + 1}月`
  }

  private shiftMonth(delta: number): void {
    this.cursor = TaskDates.addMonths(this.cursor, delta)
    this.rebuild()
  }

  private rebuild(): void {
    const d = TaskDates.parse(this.cursor)
    const year = d.getFullYear()
    const month = d.getMonth()
    const first = new Date(year, month, 1)
    const startOffset = first.getDay() === 0 ? 6 : first.getDay() - 1
    const cells: DayCell[] = []
    const today = TaskDates.today()
    for (let i = 0; i < 42; i++) {
      const dayDate = new Date(year, month, 1 - startOffset + i)
      const ymd = TaskDates.ymd(dayDate)
      const cell = new DayCell()
      cell.key = ymd
      cell.day = dayDate.getDate()
      cell.date = ymd
      cell.inMonth = dayDate.getMonth() === month
      cell.isToday = ymd === today
      cell.hasTask = this.hasTask(ymd)
      cells.push(cell)
    }
    this.cells = cells
  }

  private hasTask(ymd: string): boolean {
    for (const row of this.all) {
      if (row.date === ymd) {
        return true
      }
    }
    return false
  }

  private async pick(cell: DayCell): Promise<void> {
    this.selected = cell.date
    this.dayItems = await TaskService.byDate(cell.date)
  }

  private handleToggle(row: FamilyTaskItem): void {
    const nextCompleted = !row.completed
    this.dayItems = TaskService.mapToggleList(this.dayItems, row.id, nextCompleted)
    this.all = TaskService.mapToggleList(this.all, row.id, nextCompleted)
    this.onToggle(row)
  }

  build() {
    Column() {
      Row() {
        AppIcon({ name: 'chevron', iconSize: 18, color: Theme.colors().textSecondary })
          .rotate({ angle: 180 })
          .onClick(() => this.shiftMonth(-1))
        Text(this.monthTitle())
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        AppIcon({ name: 'chevron', iconSize: 18, color: Theme.colors().textSecondary })
          .onClick(() => this.shiftMonth(1))
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: Theme.space.s5, bottom: 8 })

      Row() {
        ForEach(['一', '二', '三', '四', '五', '六', '日'], (w: string) => {
          Text(w)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
        }, (w: string) => w)
      }
      .width('100%')
      .padding({ left: 12, right: 12, bottom: 6 })

      Grid() {
        ForEach(this.cells, (cell: DayCell) => {
          GridItem() {
            Column({ space: 4 }) {
              Text(`${cell.day}`)
                .fontSize(Theme.type.bodyS)
                .fontWeight(cell.isToday || cell.date === this.selected ? FontWeight.Bold : FontWeight.Regular)
                .fontColor(this.cellColor(cell))
              Circle()
                .width(4)
                .height(4)
                .fill(cell.hasTask ? Theme.colors().brandPrimary : '#00000000')
            }
            .width('100%')
            .height(44)
            .justifyContent(FlexAlign.Center)
            .borderRadius(12)
            .backgroundColor(cell.date === this.selected ? Theme.colors().brandPrimaryContainer : '#00000000')
            .onClick(() => { void this.pick(cell) })
          }
        }, (cell: DayCell) => cell.key)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(4)
      .columnsGap(0)
      .width('100%')
      .padding({ left: 8, right: 8 })

      Text(TaskDates.displayDate(this.selected))
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      if (this.dayItems.length === 0) {
        Column({ space: 8 }) {
          Text('这一天还很清闲')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('给这一天留一点空白，也好。')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding(20)
        .margin({ left: 16, right: 16 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onClick(() => this.onAdd())
      } else {
        List() {
          ForEach(this.dayItems, (it: FamilyTaskItem) => {
            ListItem() {
              Column({ space: 4 }) {
                if (it.time.length > 0) {
                  Text(it.time)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width('100%')
                }
                TaskRow({
                  item: it,
                  onToggle: (row: FamilyTaskItem) => this.handleToggle(row),
                  onOpen: (row: FamilyTaskItem) => this.onOpen(row)
                })
              }
            }
            .padding({ bottom: 10 })
          }, (it: FamilyTaskItem) => `${it.id}_${it.completed ? '1' : '0'}`)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private cellColor(cell: DayCell): string {
    if (cell.date === this.selected) {
      return Theme.colors().brandPrimary
    }
    if (cell.isToday) {
      return Theme.colors().brandPrimary
    }
    if (!cell.inMonth) {
      return Theme.colors().textTertiary
    }
    return Theme.colors().textPrimary
  }
}
