import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { TaskItem } from '../../models/TaskModels'
import { TaskBizService } from '../../services/TaskBizService'
import { AuthService } from '../../services/AuthService'

export type HabitOverviewMode = 'all' | 'today'

@Component
export struct HabitOverviewOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: HabitOverviewMode = 'all'
  onClose: () => void = () => {}
  @State habits: TaskItem[] = []
  @State checkedIds: string[] = []
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private titleText(): string {
    return this.mode === 'today' ? '今日打卡' : '我的习惯'
  }

  private subtitleText(): string {
    if (this.mode === 'today') {
      return `已打卡 ${this.checkedIds.length} / ${this.habits.length} 个习惯`
    }
    return `共 ${this.habits.length} 个习惯 · 点击查看连续天数`
  }

  private isChecked(habitId: string): boolean {
    return this.checkedIds.indexOf(habitId) >= 0
  }

  private pendingHabits(): TaskItem[] {
    const out: TaskItem[] = []
    for (const h of this.habits) {
      if (!this.isChecked(h.id)) {
        out.push(h)
      }
    }
    return out
  }

  private doneHabits(): TaskItem[] {
    const out: TaskItem[] = []
    for (const h of this.habits) {
      if (this.isChecked(h.id)) {
        out.push(h)
      }
    }
    return out
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.habits = await TaskBizService.loadHabits(this.currentUsername)
      const today = TaskBizService.todayLocal()
      const logs = await TaskBizService.loadHabitLogs(this.currentUsername, today)
      const ids: string[] = []
      for (const log of logs) {
        if (log.habitId.length > 0 && ids.indexOf(log.habitId) < 0) {
          ids.push(log.habitId)
        }
      }
      this.checkedIds = ids
    } else {
      this.habits = []
      this.checkedIds = []
    }
    this.loading = false
  }

  @Builder
  HabitRow(h: TaskItem, checked: boolean) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(h.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(`连续 ${h.streakDays} 天 · 目标 ${h.targetDays} 天`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text(checked ? '已打卡' : '未打卡')
        .fontSize(Theme.type.caption)
        .fontColor(checked ? Theme.colors().success : Theme.colors().textTertiary)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(checked ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  SectionTitle(label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontWeight(FontWeight.Medium)
      .fontColor(Theme.colors().textTertiary)
      .width('100%')
      .padding({ top: Theme.space.s2, bottom: Theme.space.s1 })
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => this.onClose())
        Column({ space: 2 }) {
          Text(this.titleText())
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(this.subtitleText())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.loading) {
            AppLoading({ variant: 'skeleton' })
          } else if (this.habits.length === 0) {
            AppEmpty({
              title: '还没有习惯',
              description: '前往「习惯」Tab 创建第一个习惯'
            })
          } else if (this.mode === 'all') {
            ForEach(this.habits, (h: TaskItem) => {
              this.HabitRow(h, this.isChecked(h.id))
            }, (h: TaskItem) => h.id)
          } else {
            if (this.doneHabits().length > 0) {
              this.SectionTitle(`已打卡（${this.doneHabits().length}）`)
              ForEach(this.doneHabits(), (h: TaskItem) => {
                this.HabitRow(h, true)
              }, (h: TaskItem) => `done-${h.id}`)
            }
            if (this.pendingHabits().length > 0) {
              this.SectionTitle(`待打卡（${this.pendingHabits().length}）`)
              ForEach(this.pendingHabits(), (h: TaskItem) => {
                this.HabitRow(h, false)
              }, (h: TaskItem) => `pending-${h.id}`)
            }
            if (this.checkedIds.length === this.habits.length && this.habits.length > 0) {
              Text('今日全部习惯已打卡，继续保持！')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().success)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(Theme.space.s4)
            }
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
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
