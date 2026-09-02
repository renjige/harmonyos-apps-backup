import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { PlanItem, PlanTask } from '../models/LifeGrowthModels'
import { GoalItem, HabitItem, LifeDates, TodoItem } from '../models/LifeHubModels'
import { LifeGrowthStore } from '../services/LifeGrowthStore'
import { LifeHubNav } from '../services/LifeHubNav'
import { LifeHubStore } from '../services/LifeHubStore'
import { AuthService } from '../services/AuthService'
/** 独立 Tab：周期计划 · 待办 · 打卡 · 目标（3.5 审核可见的一级能力） */
@Component
export struct PlanTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('accessToken') @Watch('onAuthChange') accessToken: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('lifeHubVersion') @Watch('onHubVersionChange') lifeHubVersion: number = 0
  onRequireAuth: () => void = () => {}
  @State plans: PlanItem[] = []
  @State todos: TodoItem[] = []
  @State habits: HabitItem[] = []
  @State goals: GoalItem[] = []
  @State kpiActivePlans: string = '0'
  @State kpiTodos: string = '0/0'
  @State kpiHabits: string = '0/0'
  @State kpiGoals: string = '0'
  @State planTitle: string = ''
  @State planCycle: string = 'week'
  @State openPlanId: string = ''
  @State taskTitle: string = ''
  @State todoTitle: string = ''
  @State habitTitle: string = ''
  @State goalTitle: string = ''
  @State listEpoch: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reloadAll()
  }

  onRefreshTokenChange(): void {
    void this.reloadAll()
  }

  onHubVersionChange(): void {
    void this.reloadAll()
  }

  onAuthChange(): void {
    void this.reloadAll()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async reloadAll(): Promise<void> {
    this.plans = await LifeGrowthStore.loadPlans()
    this.todos = await LifeHubStore.loadTodos()
    this.habits = await LifeHubStore.loadHabits()
    this.goals = await LifeHubStore.loadGoals()
    this.refreshKpis()
    this.listEpoch += 1
  }

  /** 扁平 @State 驱动 KPI 行，避免 @Builder 参数在 HarmonyOS 6 不随数据刷新 */
  private refreshKpis(): void {
    this.kpiActivePlans = `${this.activePlanCount()}`
    this.kpiTodos = `${this.doneTodoCount()}/${this.todayTodos().length}`
    this.kpiHabits = `${this.habitsCheckedToday()}/${this.habits.length}`
    this.kpiGoals = `${this.goals.length}`
  }

  private todayTodos(): TodoItem[] {
    const today = LifeDates.todayIso()
    const out: TodoItem[] = []
    for (const row of this.todos) {
      if (row.date === today) {
        out.push(row)
      }
    }
    return out
  }

  private doneTodoCount(): number {
    let n = 0
    for (const row of this.todayTodos()) {
      if (row.done) {
        n += 1
      }
    }
    return n
  }

  private habitsCheckedToday(): number {
    const today = LifeDates.todayIso()
    let n = 0
    for (const h of this.habits) {
      for (const d of h.checkins) {
        if (d === today) {
          n += 1
        }
      }
    }
    return n
  }

  private activePlanCount(): number {
    let n = 0
    for (const p of this.plans) {
      if (p.status === 'active') {
        n += 1
      }
    }
    return n
  }

  private findPlan(id: string): PlanItem | undefined {
    for (const p of this.plans) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  private async addPlan(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    if (this.planTitle.trim().length === 0) {
      this.showToast('请填写计划名称')
      return
    }
    const row = this.planCycle === 'month'
      ? LifeGrowthStore.newMonthPlan(this.planTitle.trim())
      : LifeGrowthStore.newWeekPlan(this.planTitle.trim())
    await LifeGrowthStore.upsertPlan(row)
    this.planTitle = ''
    this.openPlanId = row.id
    LifeHubStore.notifyChanged()
    this.showToast('计划已创建')
    await this.reloadAll()
  }

  private async addTask(): Promise<void> {
    const plan = this.findPlan(this.openPlanId)
    if (plan === undefined) {
      this.showToast('请先选择一个计划')
      return
    }
    if (this.taskTitle.trim().length === 0) {
      this.showToast('请填写任务')
      return
    }
    const nextTasks: PlanTask[] = []
    for (const t of plan.tasks) {
      nextTasks.push(t)
    }
    nextTasks.push(PlanTask.of(LifeHubStore.newId('pt'), this.taskTitle.trim(), false))
    plan.tasks = nextTasks
    plan.status = 'active'
    await LifeGrowthStore.upsertPlan(plan)
    this.taskTitle = ''
    LifeHubStore.notifyChanged()
    this.showToast('任务已加入')
    await this.reloadAll()
  }

  private async toggleTask(planId: string, taskId: string): Promise<void> {
    const plan = this.findPlan(planId)
    if (plan === undefined) {
      return
    }
    const nextTasks: PlanTask[] = []
    for (const t of plan.tasks) {
      if (t.id === taskId) {
        nextTasks.push(PlanTask.of(t.id, t.title, !t.done))
      } else {
        nextTasks.push(t)
      }
    }
    plan.tasks = nextTasks
    plan.status = plan.doneCount() >= plan.tasks.length && plan.tasks.length > 0 ? 'done' : 'active'
    await LifeGrowthStore.upsertPlan(plan)
    LifeHubStore.notifyChanged()
    await this.reloadAll()
  }

  private async addTodo(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    if (this.todoTitle.trim().length === 0) {
      this.showToast('请填写待办')
      return
    }
    const item = new TodoItem()
    item.id = LifeHubStore.newId('todo')
    item.title = this.todoTitle.trim()
    item.category = 'life'
    item.done = false
    item.date = LifeDates.todayIso()
    await LifeHubStore.upsertTodo(item)
    this.todoTitle = ''
    LifeHubStore.notifyChanged()
    await this.reloadAll()
  }

  private async toggleTodo(row: TodoItem): Promise<void> {
    row.done = !row.done
    await LifeHubStore.upsertTodo(row)
    LifeHubStore.notifyChanged()
    await this.reloadAll()
  }

  private async checkHabit(id: string): Promise<void> {
    const today = LifeDates.todayIso()
    const next: HabitItem[] = []
    let saved: HabitItem | undefined = undefined
    let nowChecked = false
    for (const row of this.habits) {
      const dates: string[] = []
      for (const d of row.checkins) {
        dates.push(d)
      }
      if (row.id === id) {
        const kept: string[] = []
        let hadToday = false
        for (const d of dates) {
          if (d === today) {
            hadToday = true
          } else {
            kept.push(d)
          }
        }
        if (!hadToday) {
          kept.push(today)
          nowChecked = true
        }
        saved = new HabitItem()
        saved.id = row.id
        saved.title = row.title
        saved.checkins = kept
        next.push(saved)
      } else {
        const copy = new HabitItem()
        copy.id = row.id
        copy.title = row.title
        copy.checkins = dates
        next.push(copy)
      }
    }
    this.habits = next
    this.refreshKpis()
    this.listEpoch += 1
    if (saved !== undefined) {
      await LifeHubStore.upsertHabit(saved)
      LifeHubStore.notifyChanged()
      this.showToast(nowChecked ? '今日已打卡' : '已取消今日打卡')
    }
  }

  private async addHabit(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    if (this.habitTitle.trim().length === 0) {
      this.showToast('请填写习惯名称')
      return
    }
    const item = new HabitItem()
    item.id = LifeHubStore.newId('habit')
    item.title = this.habitTitle.trim()
    item.checkins = []
    await LifeHubStore.upsertHabit(item)
    this.habitTitle = ''
    LifeHubStore.notifyChanged()
    await this.reloadAll()
  }

  private async addGoal(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    if (this.goalTitle.trim().length === 0) {
      this.showToast('请填写目标')
      return
    }
    const item = new GoalItem()
    item.id = LifeHubStore.newId('goal')
    item.title = this.goalTitle.trim()
    item.progress = 0
    item.status = 'active'
    await LifeHubStore.upsertGoal(item)
    this.goalTitle = ''
    LifeHubStore.notifyChanged()
    await this.reloadAll()
  }

  private async bumpGoal(id: string, delta: number): Promise<void> {
    const next: GoalItem[] = []
    let saved: GoalItem | undefined = undefined
    for (const row of this.goals) {
      if (row.id === id) {
        const copy = new GoalItem()
        copy.id = row.id
        copy.title = row.title
        let p = row.progress + delta
        if (p < 0) {
          p = 0
        }
        if (p > 100) {
          p = 100
        }
        copy.progress = p
        copy.status = p >= 100 ? 'done' : 'active'
        saved = copy
        next.push(copy)
      } else {
        next.push(row)
      }
    }
    this.goals = next
    this.refreshKpis()
    this.listEpoch += 1
    if (saved !== undefined) {
      await LifeHubStore.upsertGoal(saved)
      LifeHubStore.notifyChanged()
    }
  }

  build() {
    Stack() {
      Column() {
        Column({ space: 4 }) {
          Text('计划笺台')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('周期计划 · 今日待办 · 习惯打卡 · 生活目标')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row({ space: Theme.space.s2 }) {
              Column({ space: 2 }) {
                Text(this.kpiActivePlans)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandPrimary)
                Text('进行中计划')
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.colors().textTertiary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .alignItems(HorizontalAlign.Center)

              Column({ space: 2 }) {
                Text(this.kpiTodos)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandPrimary)
                Text('今日待办')
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.colors().textTertiary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .alignItems(HorizontalAlign.Center)

              Column({ space: 2 }) {
                Text(this.kpiHabits)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandPrimary)
                Text('今日打卡')
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.colors().textTertiary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .alignItems(HorizontalAlign.Center)

              Column({ space: 2 }) {
                Text(this.kpiGoals)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandPrimary)
                Text('生活目标')
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.colors().textTertiary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')

            this.SectionTitle('周期计划', '拆任务 · 勾完成 · 同步首页进度')
            TextInput({ text: this.planTitle, placeholder: '例如：本周整理书房' })
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onChange((v: string) => { this.planTitle = v })
            Row({ space: Theme.space.s2 }) {
              this.CycleChip('week', '本周')
              this.CycleChip('month', '本月')
            }
            .width('100%')
            AppButton({ label: '创建计划', onTap: (): void => { void this.addPlan() } })
            if (this.plans.length === 0) {
              AppEmpty({ title: '还没有计划', description: '创建本周或本月计划，把想做的事拆成可勾选的任务' })
            }
            ForEach(this.plans, (p: PlanItem) => {
              this.PlanCard(p)
            }, (p: PlanItem) => `${p.id}_${p.progressPct()}_${this.listEpoch}`)
            if (this.openPlanId.length > 0) {
              TextInput({ text: this.taskTitle, placeholder: '给当前计划加一条任务' })
                .width('100%')
                .height(44)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onChange((v: string) => { this.taskTitle = v })
              AppButton({
                label: '加入任务',
                variant: 'secondary',
                onTap: (): void => { void this.addTask() }
              })
            }

            this.SectionTitle('今日待办', '当天任务 · 勾选即完成')
            TextInput({ text: this.todoTitle, placeholder: '添加一条今日待办' })
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onChange((v: string) => { this.todoTitle = v })
            AppButton({ label: '加入待办', variant: 'secondary', onTap: (): void => { void this.addTodo() } })
            if (this.todayTodos().length === 0) {
              AppEmpty({ title: '今日待办为空', description: '添加任务后可在首页今日任务区同步显示' })
            }
            ForEach(this.todayTodos(), (row: TodoItem) => {
              Row({ space: Theme.space.s2 }) {
                AppIcon({
                  name: row.done ? 'check' : 'empty',
                  iconSize: Theme.icon.sm,
                  color: row.done ? Theme.colors().brandPrimary : Theme.colors().textTertiary
                })
                Text(row.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .decoration({ type: row.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { void this.toggleTodo(row) })
            }, (row: TodoItem) => `${row.id}_${row.done}_${this.listEpoch}`)

            this.SectionTitle('每日打卡', '习惯追踪 · 连续记录')
            TextInput({ text: this.habitTitle, placeholder: '例如：早起喝水' })
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onChange((v: string) => { this.habitTitle = v })
            AppButton({ label: '添加习惯', variant: 'secondary', onTap: (): void => { void this.addHabit() } })
            if (this.habits.length === 0) {
              AppEmpty({ title: '还没有习惯', description: '创建习惯后点「今日打卡」记录坚持' })
            }
            ForEach(this.habits, (h: HabitItem) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text(h.title)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`累计 ${h.checkins.length} 天`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text(h.checkedOn(LifeDates.todayIso()) ? '今日已打卡' : '今日打卡')
                  .fontSize(Theme.type.caption)
                  .fontColor(h.checkedOn(LifeDates.todayIso())
                    ? Theme.colors().brandPrimary
                    : Theme.colors().brandOnPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(h.checkedOn(LifeDates.todayIso())
                    ? Theme.colors().brandPrimaryContainer
                    : Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.checkHabit(h.id) })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
            }, (h: HabitItem) => `${h.id}_${h.checkedOn(LifeDates.todayIso())}_${h.checkins.length}_${this.listEpoch}`)

            this.SectionTitle('生活目标', '短期目标 · 进度条推进')
            TextInput({ text: this.goalTitle, placeholder: '例如：本月读完一本书' })
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onChange((v: string) => { this.goalTitle = v })
            AppButton({ label: '添加目标', variant: 'secondary', onTap: (): void => { void this.addGoal() } })
            ForEach(this.goals, (g: GoalItem) => {
              Column({ space: Theme.space.s2 }) {
                Text(g.title)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(`${g.progress}% · ${g.status === 'done' ? '已完成' : '进行中'}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Row({ space: Theme.space.s3 }) {
                  Column() {
                    Text('−10')
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                  }
                  .layoutWeight(1)
                  .height(36)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => { void this.bumpGoal(g.id, -10) })
                  Column() {
                    Text('+10')
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandOnPrimary)
                  }
                  .layoutWeight(1)
                  .height(36)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => { void this.bumpGoal(g.id, 10) })
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
            }, (g: GoalItem) => `${g.id}_${g.progress}_${this.listEpoch}`)

            Row({ space: Theme.space.s3 }) {
              Text('提醒')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { LifeHubNav.open('reminders', false) })
              Text('笺历')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { LifeHubNav.open('calendar', false) })
              Text('全文搜索')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { LifeHubNav.open('search', false) })
            }
            .width('100%')
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
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
        .zIndex(50)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SectionTitle(title: string, sub: string) {
    Column({ space: 2 }) {
      Text(title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(sub)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .margin({ top: Theme.space.s2 })
  }

  @Builder
  CycleChip(id: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.planCycle === id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.planCycle === id ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.planCycle = id })
  }

  @Builder
  PlanCard(p: PlanItem) {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text(p.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text(p.cycle === 'month' ? '本月' : '本周')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')
      Text(`${p.doneCount()}/${p.tasks.length} · ${p.progressPct()}%`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      ForEach(p.tasks, (t: PlanTask) => {
        Row({ space: Theme.space.s2 }) {
          AppIcon({
            name: t.done ? 'check' : 'empty',
            iconSize: Theme.icon.sm,
            color: t.done ? Theme.colors().brandPrimary : Theme.colors().textTertiary
          })
          Text(t.title)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .decoration({ type: t.done ? TextDecorationType.LineThrough : TextDecorationType.None })
        }
        .width('100%')
        .onClick((): void => { void this.toggleTask(p.id, t.id) })
      }, (t: PlanTask) => `${t.id}_${t.done}_${this.listEpoch}`)
      Text(this.openPlanId === p.id ? '正在添加任务…' : '点这里添加任务')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandPrimary)
        .width('100%')
        .onClick((): void => { this.openPlanId = p.id })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
