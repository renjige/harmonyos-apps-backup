import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { LifeTodoItem } from '../models/LifeModels'
import { LifeLocalStore } from '../services/LifeLocalStore'
import { LifeDetailNav } from '../services/LifeDetailNav'
import { ReminderService } from '../services/ReminderService'
import { AppContextService } from '../services/AppContextService'
import { LifeHabitBlock } from '../components/life/LifeHabitBlock'
import { LifeListTemplateBar } from '../components/life/LifeListTemplateBar'

@Component
export struct ReminderPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State activeTodos: LifeTodoItem[] = []
  @State doneTodos: LifeTodoItem[] = []
  @State showDone: boolean = false
  @State filterKind: string = 'all'

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await LifeLocalStore.loadTodos()
    const active: LifeTodoItem[] = []
    const done: LifeTodoItem[] = []
    for (const t of all) {
      if (t.done) {
        done.push(t)
      } else {
        active.push(t)
      }
    }
    this.activeTodos = active
    this.doneTodos = done
  }

  private filteredActive(): LifeTodoItem[] {
    if (this.filterKind === 'all') {
      return this.activeTodos
    }
    const out: LifeTodoItem[] = []
    for (const t of this.activeTodos) {
      if (t.listKind === this.filterKind) {
        out.push(t)
      }
    }
    return out
  }

  private kindChipLabel(kind: string): string {
    if (kind === 'remind') {
      return '提醒'
    }
    if (kind === 'shopping') {
      return '购物'
    }
    if (kind === 'chore') {
      return '家务'
    }
    if (kind === 'trip') {
      return '出行'
    }
    if (kind === 'study') {
      return '学习'
    }
    return '全部'
  }

  private setFilter(kind: string): void {
    this.filterKind = kind
  }

  private async toggleDone(id: string): Promise<void> {
    await LifeLocalStore.toggleTodoDone(id)
    const todo = await LifeLocalStore.findTodo(id)
    const ctx = AppContextService.getContext()
    if (todo !== undefined && ctx !== null) {
      await ReminderService.scheduleTodo(todo, ctx)
    }
    void this.reload()
  }

  private formatDue(todo: LifeTodoItem): string {
    const parts: string[] = []
    if (todo.dueDate.length > 0) {
      parts.push(todo.dueDate)
    }
    if (todo.dueTime.length > 0) {
      parts.push(todo.dueTime)
    }
    if (parts.length === 0) {
      return '无截止时间'
    }
    return `${parts.join(' ')} · ${todo.repeatLabel()}`
  }

  @Builder
  TodoRow(todo: LifeTodoItem) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({
          name: todo.done ? 'check' : 'empty',
          iconSize: Theme.icon.md,
          color: todo.done ? Theme.colors().success : Theme.colors().brandPrimary
        })
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .onClick((): void => { void this.toggleDone(todo.id) })

      Column({ space: 4 }) {
        Text(todo.content)
          .fontSize(Theme.type.body)
          .fontColor(todo.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
          .decoration({ type: todo.done ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(2)
        Text(this.formatDue(todo))
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(todo.kindLabel())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick((): void => { LifeDetailNav.openTodoEdit(todo.id) })

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('日常')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

          Text('打卡习惯、生活清单与到点提醒，同一页完成每日安排')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(20)

          LifeHabitBlock({
            refreshToken: this.refreshToken,
            onChanged: (): void => { void this.reload() }
          })

          Text('生活清单')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandDeep)

          LifeListTemplateBar({
            onApplied: (): void => { void this.reload() }
          })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(['all', 'remind', 'shopping', 'chore', 'trip', 'study'], (k: string) => {
              Text(this.kindChipLabel(k))
                .fontSize(Theme.type.caption)
                .fontColor(this.filterKind === k ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
                .backgroundColor(this.filterKind === k ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.setFilter(k) })
            }, (k: string) => k)
          }
          .width('100%')

          Text(`待完成 · ${this.filteredActive().length}`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandDeep)

          if (this.filteredActive().length === 0) {
            AppEmpty({
              title: '暂无清单项',
              description: '可建购物、家务、出行、学习清单，并设置到点提醒',
              actionLabel: '新建清单',
              onAction: (): void => { LifeDetailNav.openTodoEdit('new') }
            })
          } else {
            ForEach(this.filteredActive(), (todo: LifeTodoItem) => {
              this.TodoRow(todo)
            }, (todo: LifeTodoItem) => todo.id)
          }

          Row() {
            Text(`已完成 · ${this.doneTodos.length}`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .layoutWeight(1)
            Text(this.showDone ? '收起' : '展开')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick((): void => { this.showDone = !this.showDone })
          }
          .width('100%')

          if (this.showDone) {
            ForEach(this.doneTodos, (todo: LifeTodoItem) => {
              this.TodoRow(todo)
            }, (todo: LifeTodoItem) => todo.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s8 })
      .onClick((): void => { LifeDetailNav.openTodoEdit('new') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
