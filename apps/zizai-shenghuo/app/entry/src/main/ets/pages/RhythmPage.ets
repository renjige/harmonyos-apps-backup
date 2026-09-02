import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { ProgressRing } from '../components/zizai/ProgressRing'
import { HabitDef, TodoItem } from '../models/ZizaiModels'
import { DateHelper } from '../services/DateHelper'
import { ZizaiStore } from '../services/ZizaiStore'

@Component
export struct RhythmPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State progress: number = 0
  @State todos: TodoItem[] = []
  @State habits: HabitDef[] = []
  @State checkedHabits: string[] = []
  @State toastText: string = ''
  @State streakLabels: string[] = []

  aboutToAppear(): void {
    this.habits = ZizaiStore.defaultHabits()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async reload(): Promise<void> {
    this.todos = await ZizaiStore.loadTodos()
    this.progress = await ZizaiStore.todayProgress()
    const rec = await ZizaiStore.loadHabitRecord(DateHelper.todayKey())
    this.checkedHabits = rec.habitIds
    const labels: string[] = []
    for (const h of this.habits) {
      const s = await ZizaiStore.habitStreak(h.id)
      labels.push(`${s}`)
    }
    this.streakLabels = labels
  }

  private isHabitChecked(id: string): boolean {
    for (const cid of this.checkedHabits) {
      if (cid === id) {
        return true
      }
    }
    return false
  }

  private streakAt(index: number): number {
    if (index >= 0 && index < this.streakLabels.length) {
      return parseInt(this.streakLabels[index], 10)
    }
    return 0
  }

  private async handleTodo(id: string): Promise<void> {
    await ZizaiStore.toggleTodo(id)
    this.showToast('已更新待办')
    await this.reload()
  }

  private async handleHabit(id: string): Promise<void> {
    await ZizaiStore.toggleHabit(id)
    this.showToast('打卡成功 ✓')
    await this.reload()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Text('生活节奏')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('今日完成率')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            ProgressRing({ percent: this.progress, ringSize: 128 })
            Text(`${this.progress}% 的待办已完成`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .alignItems(HorizontalAlign.Center)

          Column({ space: Theme.space.s3 }) {
            Text('今日待办')
              .fontSize(Theme.type.title3)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.todos, (t: TodoItem) => {
              Row({ space: Theme.space.s3 }) {
                Toggle({ type: ToggleType.Checkbox, isOn: t.isCompleted })
                  .selectedColor(Theme.colors().brandPrimary)
                  .onChange((): void => { void this.handleTodo(t.id) })
                Column({ space: 2 }) {
                  Text(t.title)
                    .fontSize(Theme.type.body)
                    .fontColor(t.isCompleted ?
                      Theme.colors().textTertiary : Theme.colors().textPrimary)
                    .decoration({ type: t.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                  Text(t.category)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
            }, (t: TodoItem) => t.id)
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('习惯打卡')
              .fontSize(Theme.type.title3)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Grid() {
              ForEach(this.habits, (h: HabitDef, idx: number) => {
                GridItem() {
                  Column({ space: 6 }) {
                    AppIcon({
                      name: h.iconName as AppIconName,
                      iconSize: Theme.icon.lg,
                      color: this.isHabitChecked(h.id) ?
                        Theme.colors().brandPrimary : Theme.colors().textSecondary
                    })
                    Text(h.title)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    Text(this.isHabitChecked(h.id) ? '已打卡' : `近7天 ${this.streakAt(idx)} 天`)
                      .fontSize(Theme.type.overline)
                      .fontColor(Theme.colors().textTertiary)
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(this.isHabitChecked(h.id) ?
                    Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.md)
                  .onClick((): void => { void this.handleHabit(h.id) })
                }
              }, (h: HabitDef) => h.id)
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsGap(Theme.space.s3)
            .columnsGap(Theme.space.s3)
            .width('100%')
          }
          .width('100%')
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: this.bottomInset + Theme.space.s6
        })
      }
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
