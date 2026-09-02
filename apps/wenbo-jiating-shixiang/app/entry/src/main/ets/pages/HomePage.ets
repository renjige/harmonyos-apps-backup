import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { StatusCard } from '../components/family/StatusCard'
import { TaskRow } from '../components/family/TaskRow'
import { FamilyTaskItem, TaskDates } from '../models/FamilyTaskModels'
import { TaskService } from '../services/TaskService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: FamilyTaskItem[] = []
  @State pending: number = 0
  @State done: number = 0
  @State rate: number = 0
  @StorageLink('windowIsWide') isWide: boolean = false
  @Prop @Watch('onTick') refreshToken: number = 0
  onAdd: () => void = () => {}
  onOpen: (item: FamilyTaskItem) => void = (_i: FamilyTaskItem) => {}
  onToggle: (item: FamilyTaskItem) => void = (_i: FamilyTaskItem) => {}
  onNotify: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const rows = await TaskService.today()
    this.items = rows
    this.pending = TaskService.pendingCount(rows)
    this.done = TaskService.doneCount(rows)
    this.rate = TaskService.progress(rows)
  }

  private handleToggle(row: FamilyTaskItem): void {
    const nextCompleted = !row.completed
    this.items = TaskService.mapToggleList(this.items, row.id, nextCompleted)
    this.pending = TaskService.pendingCount(this.items)
    this.done = TaskService.doneCount(this.items)
    this.rate = TaskService.progress(this.items)
    this.onToggle(row)
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          this.TopBar()
          Image($r('app.media.home_hero'))
            .width('100%')
            .height(this.isWide ? 160 : 88)
            .borderRadius(Theme.radius.xl)
            .objectFit(ImageFit.Cover)
          StatusCard({ pending: this.pending, done: this.done, rate: this.rate })
          this.TodayList()
        }
        .padding({
          left: this.isWide ? 32 : Theme.space.pageX,
          right: this.isWide ? 32 : Theme.space.pageX,
          top: Theme.space.s5,
          bottom: 96
        })
        .constraintSize({ maxWidth: 720 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column() {
        Row({ space: 6 }) {
          AppIcon({ name: 'add', iconSize: 18, color: Theme.colors().brandOnPrimary })
          Text('添加事项')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandOnPrimary)
        }
      }
      .height(48)
      .padding({ left: 18, right: 20 })
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.button)
      .margin({ right: 20, bottom: 12 })
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onAdd())
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TopBar() {
    Row() {
      Column({ space: 4 }) {
        Text(TaskDates.greeting())
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('今天也把家里的小事安排得妥妥当当。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(TaskDates.displayDate(TaskDates.today()))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Column() {
        AppIcon({ name: 'bell', iconSize: 22, color: Theme.colors().textSecondary })
      }
      .width(44)
      .height(44)
      .borderRadius(22)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onNotify())
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  TodayList() {
    if (this.items.length === 0) {
      Column({ space: 12 }) {
        Image($r('app.media.empty_idle'))
          .width('100%')
          .height(140)
          .borderRadius(Theme.radius.xl)
          .objectFit(ImageFit.Cover)
        Text('今天还没有家庭事项')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('今天的时间，留一点给自己。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text('添加第一件事')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.button)
          .onClick(() => this.onAdd())
      }
      .width('100%')
      .padding(20)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    } else {
      Column({ space: 10 }) {
        if (this.pending === 0) {
          Text('今天的家庭事项都完成啦')
            .fontSize(Theme.type.subtitleS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text('给忙碌的一天画上一个小小的句号。')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
        }
        if (TaskService.morning(this.items).length > 0) {
          Text('上午')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          ForEach(TaskService.morning(this.items), (it: FamilyTaskItem) => {
            TaskRow({
              item: it,
              onToggle: (row: FamilyTaskItem) => this.handleToggle(row),
              onOpen: (row: FamilyTaskItem) => this.onOpen(row)
            })
          }, (it: FamilyTaskItem) => `m_${it.id}_${it.completed ? '1' : '0'}`)
        }
        if (TaskService.afternoon(this.items).length > 0) {
          Text('下午')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .margin({ top: 6 })
          ForEach(TaskService.afternoon(this.items), (it: FamilyTaskItem) => {
            TaskRow({
              item: it,
              onToggle: (row: FamilyTaskItem) => this.handleToggle(row),
              onOpen: (row: FamilyTaskItem) => this.onOpen(row)
            })
          }, (it: FamilyTaskItem) => `p_${it.id}_${it.completed ? '1' : '0'}`)
        }
        if (TaskService.completedOf(this.items).length > 0) {
          Text('已完成')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .margin({ top: 6 })
          ForEach(TaskService.completedOf(this.items), (it: FamilyTaskItem) => {
            TaskRow({
              item: it,
              onToggle: (row: FamilyTaskItem) => this.handleToggle(row),
              onOpen: (row: FamilyTaskItem) => this.onOpen(row)
            })
          }, (it: FamilyTaskItem) => `d_${it.id}_${it.completed ? '1' : '0'}`)
        }
      }
      .width('100%')
    }
  }
}
