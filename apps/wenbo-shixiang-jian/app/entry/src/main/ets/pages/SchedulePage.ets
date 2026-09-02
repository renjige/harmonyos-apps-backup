import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { TaskListCard } from '../components/task/TaskListCard'
import { TaskItem } from '../models/TaskModels'
import { TaskBizService } from '../services/TaskBizService'
import { TaskDetailNav } from '../services/TaskDetailNav'
import { AuthService } from '../services/AuthService'

class DayCell {
  day: number = 0
  dateStr: string = ''
  isCurrentMonth: boolean = true
  isToday: boolean = false
  taskCount: number = 0
}

@Component
export struct SchedulePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State viewYear: number = 2026
  @State viewMonth: number = 1
  @State selectedDate: string = ''
  @State dayTasks: TaskItem[] = []
  @State monthTasks: TaskItem[] = []
  @State cells: DayCell[] = []
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    const now = new Date()
    this.viewYear = now.getFullYear()
    this.viewMonth = now.getMonth() + 1
    this.selectedDate = TaskBizService.todayLocal()
    this.buildCells()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private monthLabel(): string {
    return `${this.viewYear}年${this.viewMonth}月`
  }

  private buildCells(): void {
    const first = new Date(this.viewYear, this.viewMonth - 1, 1)
    const startWeekday = first.getDay()
    const daysInMonth = new Date(this.viewYear, this.viewMonth, 0).getDate()
    const today = TaskBizService.todayLocal()
    const counts = new Map<string, number>()
    for (const t of this.monthTasks) {
      if (t.dueDate.length > 0) {
        const c = counts.get(t.dueDate) ?? 0
        counts.set(t.dueDate, c + 1)
      }
    }
    const out: DayCell[] = []
    for (let i = 0; i < startWeekday; i++) {
      const blank = new DayCell()
      blank.day = 0
      blank.isCurrentMonth = false
      out.push(blank)
    }
    for (let d = 1; d <= daysInMonth; d++) {
      const cell = new DayCell()
      cell.day = d
      cell.isCurrentMonth = true
      const m = this.viewMonth < 10 ? `0${this.viewMonth}` : `${this.viewMonth}`
      const dd = d < 10 ? `0${d}` : `${d}`
      cell.dateStr = `${this.viewYear}-${m}-${dd}`
      cell.isToday = cell.dateStr === today
      cell.taskCount = counts.get(cell.dateStr) ?? 0
      out.push(cell)
    }
    this.cells = out
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.monthTasks = await TaskBizService.loadTasks(this.currentUsername)
      this.dayTasks = await TaskBizService.loadTasks(this.currentUsername, '', '', this.selectedDate)
    } else {
      this.monthTasks = []
      this.dayTasks = []
    }
    this.buildCells()
    this.loading = false
  }

  private async selectDate(dateStr: string): Promise<void> {
    this.selectedDate = dateStr
    if (AuthService.isLoggedIn()) {
      this.dayTasks = await TaskBizService.loadTasks(this.currentUsername, '', '', dateStr)
    } else {
      this.dayTasks = []
    }
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
    void this.reload()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        AppHeader({ title: '日程', subtitle: '月历视图 · 按日查看安排' })
        Row({ space: Theme.space.s4 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.shiftMonth(-1) })
          Text(this.monthLabel())
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.shiftMonth(1) })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

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
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.cells.length > 0) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.cells, (cell: DayCell, idx: number) => {
              Column({ space: 2 }) {
                if (cell.day > 0) {
                  Text(`${cell.day}`)
                    .fontSize(Theme.type.subhead)
                    .fontColor(cell.dateStr === this.selectedDate ?
                      Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  if (cell.taskCount > 0) {
                    Column()
                      .width(6)
                      .height(6)
                      .borderRadius(3)
                      .backgroundColor(cell.dateStr === this.selectedDate ?
                        Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  }
                } else {
                  Text(' ')
                    .fontSize(Theme.type.caption)
                    .opacity(0)
                }
              }
              .width('14.28%')
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(cell.dateStr === this.selectedDate ?
                Theme.colors().brandPrimary :
                (cell.isToday ? Theme.colors().brandPrimaryContainer : 'transparent'))
              .borderRadius(Theme.radius.sm)
              .onClick((): void => {
                if (cell.day > 0) {
                  void this.selectDate(cell.dateStr)
                }
              })
            }, (cell: DayCell, idx: number) => `cell-${idx}-${cell.dateStr}`)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column({ space: Theme.space.s3 }) {
          Text(`${this.selectedDate} 安排`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.loading) {
            AppLoading({ variant: 'skeleton' })
          } else if (this.dayTasks.length === 0) {
            AppEmpty({
              title: '当日暂无事项',
              description: AuthService.isLoggedIn() ? '可在首页或清单添加事项' : '登录后可查看个人日程'
            })
          } else {
            ForEach(this.dayTasks, (item: TaskItem) => {
              TaskListCard({
                item: item,
                onTap: (): void => { TaskDetailNav.openTask(item.id, item) }
              })
            }, (item: TaskItem) => item.id)
          }
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
