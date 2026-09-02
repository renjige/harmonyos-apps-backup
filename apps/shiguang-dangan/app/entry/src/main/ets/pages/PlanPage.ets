import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { GoalItem, HabitItem, LifePlan, PlanTask } from '../models/LifeModels'
import { LifeStore } from '../services/LifeStore'
import { DateHelper } from '../services/DateHelper'
import { ArchiveStore } from '../services/ArchiveStore'

@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State plans: LifePlan[] = []
  @State tasks: PlanTask[] = []
  @State goals: GoalItem[] = []
  @State habits: HabitItem[] = []
  @State habitStreaks: number[] = []
  @State habitLoggedToday: boolean[] = []
  @State showPlanDialog: boolean = false
  @State showHabitDialog: boolean = false
  @State showGoalDialog: boolean = false
  @State showTaskDialog: boolean = false
  @State expandedPlanId: string = ''
  @State taskTargetPlanId: string = ''
  @State newPlanTitle: string = ''
  @State newHabitName: string = ''
  @State newGoalTitle: string = ''
  @State newTaskTitle: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private bumpDataEpoch(): void {
    const cur = AppStorage.get<number>('dataEpoch')
    AppStorage.setOrCreate('dataEpoch', (cur !== undefined ? cur : 0) + 1)
  }

  private clonePlan(p: LifePlan): LifePlan {
    const c = new LifePlan()
    c.id = p.id
    c.title = p.title
    c.planType = p.planType
    c.startDate = p.startDate
    c.endDate = p.endDate
    c.status = p.status
    c.createdAt = p.createdAt
    c.isFavorite = p.isFavorite
    return c
  }

  private cloneTask(t: PlanTask): PlanTask {
    const c = new PlanTask()
    c.id = t.id
    c.planId = t.planId
    c.title = t.title
    c.done = t.done
    c.sortOrder = t.sortOrder
    return c
  }

  private cloneGoal(g: GoalItem): GoalItem {
    const c = new GoalItem()
    c.id = g.id
    c.title = g.title
    c.targetLabel = g.targetLabel
    c.currentNum = g.currentNum
    c.targetNum = g.targetNum
    c.unit = g.unit
    c.startDate = g.startDate
    c.endDate = g.endDate
    c.status = g.status
    c.createdAt = g.createdAt
    return c
  }

  private async reload(): Promise<void> {
    const loadedPlans = await LifeStore.loadPlans()
    const planCopies: LifePlan[] = []
    for (const p of loadedPlans) {
      planCopies.push(this.clonePlan(p))
    }
    this.plans = planCopies

    const loadedTasks = await LifeStore.loadPlanTasks()
    const taskCopies: PlanTask[] = []
    for (const t of loadedTasks) {
      taskCopies.push(this.cloneTask(t))
    }
    this.tasks = taskCopies

    const loadedGoals = await LifeStore.loadGoals()
    const goalCopies: GoalItem[] = []
    for (const g of loadedGoals) {
      goalCopies.push(this.cloneGoal(g))
    }
    this.goals = goalCopies

    this.habits = await LifeStore.loadHabits()
    const streaks: number[] = []
    const logged: boolean[] = []
    const today = DateHelper.todayKey()
    for (const h of this.habits) {
      streaks.push(await LifeStore.getHabitStreak(h.id))
      logged.push(await LifeStore.isHabitLogged(h.id, today))
    }
    this.habitStreaks = streaks
    this.habitLoggedToday = logged
  }

  private todayTasks(): PlanTask[] {
    const activePlanIds: string[] = []
    for (const p of this.plans) {
      if (p.status === 'active') {
        activePlanIds.push(p.id)
      }
    }
    const out: PlanTask[] = []
    for (const t of this.tasks) {
      let inPlan = false
      for (const pid of activePlanIds) {
        if (t.planId === pid) {
          inPlan = true
        }
      }
      if (inPlan) {
        out.push(t)
      }
    }
    return out
  }

  private tasksForPlan(planId: string): PlanTask[] {
    const out: PlanTask[] = []
    for (const t of this.tasks) {
      if (t.planId === planId) {
        out.push(t)
      }
    }
    return out
  }

  private planTaskSummary(planId: string): string {
    const list = this.tasksForPlan(planId)
    if (list.length === 0) {
      return '暂无任务 · 展开后添加'
    }
    let done = 0
    for (const t of list) {
      if (t.done) {
        done++
      }
    }
    return `${done}/${list.length} 任务已完成`
  }

  private planStatusLabel(status: string): string {
    if (status === 'done') {
      return '已完成'
    }
    return '进行中'
  }

  private goalStatusLabel(g: GoalItem): string {
    if (g.status === 'done') {
      return '已完成'
    }
    return `${g.currentNum}/${g.targetNum}${g.unit.length > 0 ? g.unit : '次'}`
  }

  private async toggleTask(id: string): Promise<void> {
    const next: PlanTask[] = []
    for (const t of this.tasks) {
      const c = this.cloneTask(t)
      if (c.id === id) {
        c.done = !c.done
      }
      next.push(c)
    }
    this.tasks = next
    await LifeStore.togglePlanTaskDone(id)
    await ArchiveStore.recordActivityDate(DateHelper.todayKey())
    await this.reload()
    this.bumpDataEpoch()
  }

  private async toggleHabit(idx: number): Promise<void> {
    const logged: boolean[] = []
    for (let i = 0; i < this.habitLoggedToday.length; i++) {
      logged.push(i === idx ? !this.habitLoggedToday[i] : this.habitLoggedToday[i])
    }
    this.habitLoggedToday = logged
    const h = this.habits[idx]
    await LifeStore.toggleHabitLog(h.id, DateHelper.todayKey())
    await ArchiveStore.recordActivityDate(DateHelper.todayKey())
    await this.reload()
    this.bumpDataEpoch()
  }

  private async createPlan(): Promise<void> {
    const title = this.newPlanTitle.trim()
    if (title.length < 2) {
      this.showToast('计划名称至少 2 字')
      return
    }
    const plan = LifePlan.createNew(title)
    plan.startDate = DateHelper.todayKey()
    await LifeStore.savePlan(plan)
    this.newPlanTitle = ''
    this.showPlanDialog = false
    await this.reload()
    this.showToast('计划已创建')
  }

  private async createHabit(): Promise<void> {
    const name = this.newHabitName.trim()
    if (name.length < 1) {
      this.showToast('请输入习惯名称')
      return
    }
    await LifeStore.saveHabit(HabitItem.createNew(name))
    this.newHabitName = ''
    this.showHabitDialog = false
    await this.reload()
    this.showToast('习惯已添加')
  }

  private async createGoal(): Promise<void> {
    const title = this.newGoalTitle.trim()
    if (title.length < 2) {
      this.showToast('目标名称至少 2 字')
      return
    }
    const g = GoalItem.createNew(title)
    g.targetNum = 10
    g.unit = '次'
    await LifeStore.saveGoal(g)
    this.newGoalTitle = ''
    this.showGoalDialog = false
    await this.reload()
    this.showToast('目标已创建')
  }

  private async addTaskToPlan(): Promise<void> {
    const title = this.newTaskTitle.trim()
    if (title.length === 0) {
      this.showToast('请输入任务名称')
      return
    }
    if (this.taskTargetPlanId.length === 0) {
      return
    }
    await LifeStore.savePlanTask(PlanTask.createNew(this.taskTargetPlanId, title))
    this.newTaskTitle = ''
    this.showTaskDialog = false
    await this.reload()
    this.showToast('任务已添加')
  }

  private openTaskDialog(planId: string): void {
    this.taskTargetPlanId = planId
    this.newTaskTitle = ''
    this.showTaskDialog = true
  }

  private togglePlanExpand(planId: string): void {
    this.expandedPlanId = this.expandedPlanId === planId ? '' : planId
  }

  private async completePlan(planId: string): Promise<void> {
    const next: LifePlan[] = []
    for (const p of this.plans) {
      const c = this.clonePlan(p)
      if (c.id === planId) {
        c.status = 'done'
      }
      next.push(c)
    }
    this.plans = next
    await LifeStore.completePlan(planId)
    await ArchiveStore.recordActivityDate(DateHelper.todayKey())
    await this.reload()
    this.bumpDataEpoch()
    this.showToast('计划已完成')
  }

  private async incrementGoal(goalId: string): Promise<void> {
    const next: GoalItem[] = []
    for (const g of this.goals) {
      const c = this.cloneGoal(g)
      if (c.id === goalId && c.status !== 'done') {
        c.currentNum = c.currentNum + 1
        if (c.currentNum >= c.targetNum) {
          c.status = 'done'
        }
      }
      next.push(c)
    }
    this.goals = next
    await LifeStore.incrementGoal(goalId, 1)
    await ArchiveStore.recordActivityDate(DateHelper.todayKey())
    await this.reload()
    this.bumpDataEpoch()
  }

  private async completeGoal(goalId: string): Promise<void> {
    const next: GoalItem[] = []
    for (const g of this.goals) {
      const c = this.cloneGoal(g)
      if (c.id === goalId) {
        c.status = 'done'
        c.currentNum = c.targetNum
      }
      next.push(c)
    }
    this.goals = next
    await LifeStore.completeGoal(goalId)
    await ArchiveStore.recordActivityDate(DateHelper.todayKey())
    await this.reload()
    this.bumpDataEpoch()
    this.showToast('目标已完成')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('生活计划')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Text('今日计划任务')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.todayTasks().length === 0) {
            AppEmpty({
              title: '暂无今日任务',
              description: '创建生活计划并添加任务',
              actionLabel: '新建计划',
              onAction: (): void => { this.showPlanDialog = true }
            })
          } else {
            ForEach(this.todayTasks(), (t: PlanTask) => {
              Row({ space: Theme.space.s3 }) {
                Text(t.done ? '☑' : '☐')
                  .fontSize(18)
                  .fontColor(t.done ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                Text(t.title)
                  .fontSize(Theme.type.body)
                  .fontColor(t.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
                  .decoration({ type: t.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { void this.toggleTask(t.id) })
            }, (t: PlanTask) => `${t.id}_${t.done ? '1' : '0'}`)
          }

          Row() {
            Text('生活计划')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('+ 新建')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.showPlanDialog = true })
          }
          .width('100%')
          ForEach(this.plans, (p: LifePlan) => {
            Column({ space: Theme.space.s2 }) {
              Row() {
                Column({ space: 4 }) {
                  Text(p.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`${p.startDate.length > 0 ? p.startDate : '今天起'} · ${this.planStatusLabel(p.status)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                  Text(this.planTaskSummary(p.id))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .onClick((): void => { this.togglePlanExpand(p.id) })
                if (p.status === 'active') {
                  Text('完成')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                    .onClick((): void => { void this.completePlan(p.id) })
                }
                Text('详情')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                  .onClick((): void => {
                    AppStorage.setOrCreate('planDetailId', p.id)
                    AppStorage.setOrCreate('tabBarHidden', true)
                  })
              }
              .width('100%')

              if (this.expandedPlanId === p.id) {
                Column({ space: Theme.space.s2 }) {
                  ForEach(this.tasksForPlan(p.id), (t: PlanTask) => {
                    Row({ space: Theme.space.s3 }) {
                      Text(t.done ? '☑' : '☐')
                        .fontSize(18)
                        .fontColor(t.done ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                      Text(t.title)
                        .fontSize(Theme.type.body)
                        .fontColor(t.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
                        .decoration({ type: t.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .padding({ left: Theme.space.s2, right: Theme.space.s2, top: 8, bottom: 8 })
                    .onClick((): void => { void this.toggleTask(t.id) })
                  }, (t: PlanTask) => `${t.id}_${t.done ? '1' : '0'}`)

                  Text('+ 添加任务')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick((): void => { this.openTaskDialog(p.id) })
                }
                .width('100%')
                .padding({ top: Theme.space.s1 })
              }
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (p: LifePlan) => `${p.id}_${p.status}`)

          Row() {
            Text('目标')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('+ 新建')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.showGoalDialog = true })
          }
          .width('100%')
          ForEach(this.goals, (g: GoalItem) => {
            Column({ space: Theme.space.s2 }) {
              Row() {
                Text(g.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(`${g.progressPercent()}%`)
                  .fontSize(Theme.type.caption)
                  .fontColor(g.status === 'done' ? Theme.colors().textSecondary : Theme.colors().brandPrimary)
              }
              .width('100%')
              Text(this.goalStatusLabel(g))
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Row() {
                Column()
                  .layoutWeight(g.progressPercent())
                  .height(6)
                  .backgroundColor(Theme.colors().brandAccent)
                  .borderRadius(Theme.radius.pill)
                Column()
                  .layoutWeight(100 - g.progressPercent() > 0 ? 100 - g.progressPercent() : 1)
                  .height(6)
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
              }
              .width('100%')
              if (g.status !== 'done') {
                Row({ space: Theme.space.s3 }) {
                  Text('+ 记一次')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandOnPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { void this.incrementGoal(g.id) })
                  Text('标记完成')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { void this.completeGoal(g.id) })
                }
                .width('100%')
              } else {
                Text('已完成')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (g: GoalItem) => `${g.id}_${g.status}_${g.currentNum}`)

          Row() {
            Text('习惯打卡')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('+ 新建')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.showHabitDialog = true })
          }
          .width('100%')
          ForEach(this.habits, (h: HabitItem, idx: number) => {
            Row({ space: Theme.space.s3 }) {
              Text(this.habitLoggedToday[idx] ? '✓' : '○')
                .fontSize(20)
                .fontColor(this.habitLoggedToday[idx] ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
              Column({ space: 2 }) {
                Text(h.name)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                Text(`连续 ${this.habitStreaks[idx]} 天`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { void this.toggleHabit(idx) })
          }, (h: HabitItem, idx: number) => `${h.id}_${this.habitLoggedToday[idx] ? '1' : '0'}`)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: this.bottomInset + Theme.space.s6
        })
      }
      .width('100%')
      .height('100%')

      if (this.showPlanDialog) {
        this.SimpleDialog('新建计划', this.newPlanTitle, '计划名称', (): void => { void this.createPlan() },
          (): void => { this.showPlanDialog = false },
          (v: string): void => { this.newPlanTitle = v })
      }
      if (this.showHabitDialog) {
        this.SimpleDialog('新建习惯', this.newHabitName, '习惯名称', (): void => { void this.createHabit() },
          (): void => { this.showHabitDialog = false },
          (v: string): void => { this.newHabitName = v })
      }
      if (this.showGoalDialog) {
        this.SimpleDialog('新建目标', this.newGoalTitle, '目标名称', (): void => { void this.createGoal() },
          (): void => { this.showGoalDialog = false },
          (v: string): void => { this.newGoalTitle = v })
      }
      if (this.showTaskDialog) {
        this.SimpleDialog('添加任务', this.newTaskTitle, '任务名称', (): void => { void this.addTaskToPlan() },
          (): void => { this.showTaskDialog = false },
          (v: string): void => { this.newTaskTitle = v })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s2 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  SimpleDialog(title: string, value: string, placeholder: string,
    onConfirm: () => void, onCancel: () => void, onChange: (v: string) => void) {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { onCancel() })
      Column({ space: Theme.space.s4 }) {
        Text(title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        TextInput({ text: value, placeholder: placeholder })
          .height(48)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.lg)
          .padding({ left: 14, right: 14 })
          .onChange((v: string): void => { onChange(v) })
        Row({ space: Theme.space.s3 }) {
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { onCancel() } }).layoutWeight(1)
          AppButton({ label: '确定', variant: 'primary', onTap: (): void => { onConfirm() } }).layoutWeight(1)
        }
        .width('100%')
      }
      .width('84%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(40)
  }
}
