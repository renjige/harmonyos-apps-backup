import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { PlanItem, PlanTask } from '../models/LifeGrowthModels'
import { LifeHubNav } from '../services/LifeHubNav'
import { LifeGrowthStore } from '../services/LifeGrowthStore'
import { LifeHubStore } from '../services/LifeHubStore'
import { AuthService } from '../services/AuthService'

@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth: () => void = () => {}
  @State items: PlanItem[] = []
  @State formTitle: string = ''
  @State formCycle: string = 'week'
  @State taskTitle: string = ''
  @State openId: string = ''
  @State confirmId: string = ''
  @State toastText: string = ''
  @State listEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.items = await LifeGrowthStore.loadPlans()
    this.listEpoch += 1
  }

  private async addPlan(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.showToast('请填写计划名称')
      return
    }
    const row = this.formCycle === 'month'
      ? LifeGrowthStore.newMonthPlan(this.formTitle.trim())
      : LifeGrowthStore.newWeekPlan(this.formTitle.trim())
    await LifeGrowthStore.upsertPlan(row)
    this.formTitle = ''
    this.openId = row.id
    this.showToast('计划已创建，再加几条任务')
    await this.reload()
  }

  private findPlan(id: string): PlanItem | undefined {
    for (const p of this.items) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  private async addTask(): Promise<void> {
    const plan = this.findPlan(this.openId)
    if (plan === undefined) {
      this.showToast('请先点开一个计划')
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
    this.showToast('任务已加入，进度会马上更新')
    await this.reload()
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
    this.showToast(plan.status === 'done' ? '这周的计划完成了' : `完成度 ${plan.progressPct()}%`)
    await this.reload()
  }

  private async confirmDelete(): Promise<void> {
    const id = this.confirmId
    await LifeGrowthStore.removePlan(id)
    this.confirmId = ''
    if (this.openId === id) {
      this.openId = ''
    }
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { LifeHubNav.backOrClose() })
          Column({ space: 2 }) {
            Text('生活计划')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('设定周期 · 拆成任务 · 看完成度')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.formTitle, placeholder: '例如：本周把书桌整理完' })
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onChange((v: string) => { this.formTitle = v })
            Row({ space: Theme.space.s2 }) {
              Text('本周')
                .fontSize(Theme.type.caption)
                .fontColor(this.formCycle === 'week' ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.formCycle === 'week' ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.formCycle = 'week' })
              Text('本月')
                .fontSize(Theme.type.caption)
                .fontColor(this.formCycle === 'month' ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.formCycle === 'month' ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.formCycle = 'month' })
            }
            .width('100%')
            AppButton({ label: '创建计划', onTap: (): void => { void this.addPlan() } })

            if (this.items.length === 0) {
              AppEmpty({
                title: '还没有计划',
                description: '把这周想做的事拆成几条任务，完成度会显示在首页。',
                actionLabel: '',
                onAction: (): void => {}
              })
            }
            ForEach(this.items, (p: PlanItem) => {
              this.PlanCard(p)
            }, (p: PlanItem) => `${p.id}_${p.progressPct()}_${p.status}_${this.listEpoch}`)

            if (this.openId.length > 0) {
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
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.confirmId.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这个计划？任务会一起去掉。')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
          AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.confirmDelete() } })
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmId = '' } })
        }
        .width('80%')
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  PlanCard(p: PlanItem) {
    Column({ space: Theme.space.s3 }) {
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
      Text(`已完成 ${p.doneCount()} / ${p.tasks.length} · ${p.progressPct()}%`)
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
      Row({ space: Theme.space.s3 }) {
        Text(this.openId === p.id ? '收起任务' : '添加任务')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.openId = this.openId === p.id ? '' : p.id })
        Text('删除')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().danger)
          .onClick((): void => { this.confirmId = p.id })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
