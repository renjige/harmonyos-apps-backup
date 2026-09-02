import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppIcon } from '../design-system/AppIcon'
import { ActionLog, PlanTask, StudyHabit, StudyPlan } from '../../models/ZhixingModels'
import { ZhixingMedia } from '../../services/ZhixingMedia'
import { ZhixingStore } from '../../services/ZhixingStore'
import { DetailShell } from './DetailShell'

@Component
export struct ActionDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop kind: string = 'plan'
  @State plan: StudyPlan = new StudyPlan()
  @State habit: StudyHabit = new StudyHabit()
  @State log: ActionLog = new ActionLog()
  @State confirmDelete: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onChanged: () => void = () => {}
  onOpenKnowledge: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  private titleText(): string {
    if (this.kind === 'habit') {
      return this.habit.title
    }
    if (this.kind === 'log') {
      return this.log.title
    }
    return this.plan.title
  }

  private coverKey(): string {
    if (this.kind === 'habit') {
      return 'cover_habit'
    }
    if (this.kind === 'log') {
      return 'cover_log'
    }
    return 'cover_plan'
  }

  private async load(): Promise<void> {
    if (this.kind === 'habit') {
      const f = await ZhixingStore.findHabit(this.itemId)
      if (f !== undefined) {
        this.habit = f
      }
      return
    }
    if (this.kind === 'log') {
      const f = await ZhixingStore.findLog(this.itemId)
      if (f !== undefined) {
        this.log = f
      }
      return
    }
    const f = await ZhixingStore.findPlan(this.itemId)
    if (f !== undefined) {
      this.plan = f
    }
  }

  private async checkIn(): Promise<void> {
    const ok = await ZhixingStore.checkHabit(this.itemId)
    await this.load()
    this.toastText = ok ? '今日已打卡' : '今天已经打过卡了'
    setTimeout((): void => { this.toastText = '' }, 2000)
    this.onChanged()
  }

  private async toggleTask(taskId: string): Promise<void> {
    await ZhixingStore.togglePlanTask(this.itemId, taskId)
    await this.load()
    this.onChanged()
  }

  private async markDone(): Promise<void> {
    const wasDone = this.plan.status === 'done'
    if (wasDone) {
      this.plan.status = 'active'
      this.plan.progress = 0
      for (const t of this.plan.tasks) {
        t.done = false
      }
    } else {
      this.plan.status = 'done'
      this.plan.progress = 100
    }
    await ZhixingStore.savePlan(this.plan)
    const saved = await ZhixingStore.findPlan(this.itemId)
    if (saved !== undefined) {
      this.plan = saved.clone()
    }
    this.toastText = wasDone ? '计划已重新打开，进度已重置为 0%' : '已标记完成'
    setTimeout((): void => { this.toastText = '' }, 2400)
    this.onChanged()
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.toastText = '再点一次确认删除'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    if (this.kind === 'habit') {
      await ZhixingStore.deleteHabit(this.itemId)
    } else if (this.kind === 'log') {
      await ZhixingStore.deleteLog(this.itemId)
    } else {
      await ZhixingStore.deletePlan(this.itemId)
    }
    this.onChanged()
    this.onClose()
  }

  build() {
    Stack() {
      DetailShell({ title: this.titleText(), onClose: (): void => { this.onClose() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(ZhixingMedia.image(this.coverKey()))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(80)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,42,108,0)', 0], ['rgba(26,42,108,0.8)', 1]]
                })
              Text(this.titleText())
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .padding({ left: 16, bottom: 12 })
            }
            .width('100%')
            .height(180)
            .clip(true)
            .borderRadius(Theme.radius.md)

            if (this.kind === 'plan') {
              AppCard({ title: '目标' }) {
                Text(this.plan.goal.length > 0 ? this.plan.goal : '未填写目标')
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              Text(`进度 ${this.plan.progress}% · ${this.plan.statusLabel()}${this.plan.deadline.length > 0 ? ` · 截止 ${this.plan.deadline}` : ''}`)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              if (this.plan.knowledgeId.length > 0) {
                Text('查看来源知识卡片')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .width('100%')
                  .onClick((): void => { this.onOpenKnowledge(this.plan.knowledgeId) })
              }
              if (this.plan.tasks.length > 0) {
                AppCard({ title: `子任务 ${this.plan.taskDoneCount()}/${this.plan.tasks.length}` }) {
                  ForEach(this.plan.tasks, (t: PlanTask) => {
                    Row({ space: 8 }) {
                      AppIcon({
                        name: t.done ? 'check' : 'empty',
                        iconSize: 18,
                        color: t.done ? Theme.colors().success : Theme.colors().textTertiary
                      })
                      Text(t.title)
                        .fontSize(Theme.type.body)
                        .fontColor(Theme.colors().textPrimary)
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .padding({ top: 6, bottom: 6 })
                    .onClick((): void => { void this.toggleTask(t.id) })
                  }, (t: PlanTask) => t.id)
                }
              }
              AppButton({
                label: this.plan.status === 'done' ? '重新打开' : '标记完成',
                onTap: (): void => { void this.markDone() }
              })
            }
            if (this.kind === 'habit') {
              AppCard({ title: '打卡统计' }) {
                Text(`连续 ${this.habit.streak} 天 · 累计 ${this.habit.totalChecks} 次 · 本周 ${this.habit.weekCheckCount()} 天`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(this.habit.lastCheckDate.length > 0 ? `上次：${this.habit.lastCheckDate}` : '还没有打过卡')
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              AppButton({ label: '今日打卡', onTap: (): void => { void this.checkIn() } })
            }
            if (this.kind === 'log') {
              AppCard({ title: '反思' }) {
                Text(this.log.body.length > 0 ? this.log.body : '未填写')
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }
              Text(this.log.dateKey)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            AppButton({ label: '编辑', variant: 'secondary', onTap: (): void => { this.onEdit() } })
            AppButton({
              label: this.confirmDelete ? '再点一次确认删除' : '删除',
              variant: 'danger',
              onTap: (): void => { void this.remove() }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .align(Alignment.Top)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
