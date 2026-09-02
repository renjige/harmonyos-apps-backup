import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { TaskItem } from '../models/TaskModels'
import { TaskBizService } from '../services/TaskBizService'
import { AuthService } from '../services/AuthService'

@Component
export struct HabitPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onOpenCreate: () => void = () => {}
  @State habits: TaskItem[] = []
  @State checkedIds: string[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
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
      const today = TaskBizService.todayLocal()
      this.habits = await TaskBizService.loadHabits(this.currentUsername)
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

  private async handleCheckIn(habitId: string): Promise<void> {
    if (!AuthService.requireAuth('habit_checkin')) {
      this.onRequireAuth()
      return
    }
    const ok = await TaskBizService.checkInHabit(habitId)
    if (ok) {
      this.showToast('打卡成功，连续天数已更新')
      void this.reload()
    } else {
      this.showToast(TaskBizService.lastError.length > 0 ?
        TaskBizService.lastError : '今日已打卡或操作失败')
    }
  }

  private async handleDelete(habitId: string): Promise<void> {
    if (!AuthService.requireAuth('create_habit')) {
      this.onRequireAuth()
      return
    }
    const ok = await TaskBizService.deleteHabit(habitId)
    if (ok) {
      this.showToast('习惯已删除')
      void this.reload()
    } else {
      this.showToast(TaskBizService.lastError.length > 0 ?
        TaskBizService.lastError : '删除失败')
    }
  }

  @Builder
  SectionTitle(label: string, count: number) {
    Row() {
      Text(label)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
      Text(`${count}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
    }
    .width('100%')
    .padding({ top: Theme.space.s2, bottom: Theme.space.s1 })
  }

  @Builder
  HabitCard(h: TaskItem, checked: boolean) {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s3 }) {
        Column({ space: 4 }) {
          Text(h.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (h.description.length > 0) {
            Text(h.description)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .maxLines(2)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        if (checked) {
          Row({ space: 4 }) {
            AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().success })
            Text('已打卡')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().success)
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
        } else {
          Row({ space: 6 }) {
            AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().brandOnPrimary })
            Text('打卡')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandOnPrimary)
          }
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { void this.handleCheckIn(h.id) })
        }
      }
      .width('100%')

      Row({ space: Theme.space.s4 }) {
        Column({ space: 2 }) {
          Text(`${h.streakDays}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().success)
          Text('连续天')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        Column({ space: 2 }) {
          Text(`${h.targetDays}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text('目标天')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        .layoutWeight(1)
        Column({ space: 6 }) {
          Progress({
            value: h.streakDays,
            total: h.targetDays > 0 ? h.targetDays : 1,
            type: ProgressType.Linear
          })
            .width('100%')
            .color(Theme.colors().brandPrimary)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .style({ strokeWidth: 6 })
        }
        .layoutWeight(2)
      }
      .width('100%')

      Row() {
        Text('删除习惯')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().danger)
          .onClick((): void => { void this.handleDelete(h.id) })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '习惯', subtitle: '每日打卡 · 连续天数自动累计' })
        Column() {
          AppButton({
            label: '创建习惯',
            onTap: (): void => {
              if (!AuthService.requireAuth('create_habit')) {
                this.onRequireAuth()
                return
              }
              this.onOpenCreate()
            }
          })
        }
        .width('100%')
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.loading) {
              AppLoading({ variant: 'skeleton' })
            } else if (this.habits.length === 0) {
              AppEmpty({
                title: '还没有习惯',
                description: AuthService.isLoggedIn() ? '创建第一个习惯，打卡后连续天数从 1 开始' : '登录后可创建并追踪习惯',
                actionLabel: '创建习惯',
                onAction: (): void => {
                  if (!AuthService.requireAuth('create_habit')) {
                    this.onRequireAuth()
                    return
                  }
                  this.onOpenCreate()
                }
              })
            } else {
              if (this.pendingHabits().length > 0) {
                this.SectionTitle('待打卡', this.pendingHabits().length)
                ForEach(this.pendingHabits(), (h: TaskItem) => {
                  this.HabitCard(h, false)
                }, (h: TaskItem) => `p-${h.id}`)
              }
              if (this.doneHabits().length > 0) {
                this.SectionTitle('今日已打卡', this.doneHabits().length)
                ForEach(this.doneHabits(), (h: TaskItem) => {
                  this.HabitCard(h, true)
                }, (h: TaskItem) => `d-${h.id}`)
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
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
