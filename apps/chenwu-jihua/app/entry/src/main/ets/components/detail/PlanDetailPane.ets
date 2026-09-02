import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppIcon } from '../design-system/AppIcon'
import { CwDateUtil, CwPhase, CwPlan, CwPlanTask } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'
import { ChenwuMedia } from '../../services/ChenwuMedia'
import { CwHorizonLabels } from '../chenwu/PlanListCard'
import { CwConfirmDialog } from '../chenwu/CwConfirmDialog'

@Component
export struct PlanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('cwDataRev') @Watch('onDataRev') dataRev: number = 0
  @Prop planId: string = ''
  onChanged: () => void = () => {}
  @State plan: CwPlan = new CwPlan()
  @State phases: CwPhase[] = []
  @State tasks: CwPlanTask[] = []
  @State goalTitle: string = ''
  @State completionPct: number = 0
  @State confirmDel: boolean = false
  @State paneEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await ChenwuStore.reconcilePlanProgress(this.planId)
    const found = await ChenwuStore.findPlan(this.planId)
    if (found !== undefined) {
      this.plan = found
    }
    const g = await ChenwuStore.findGoal(this.plan.goalId)
    this.goalTitle = g !== undefined ? g.title : ''
    this.phases = await ChenwuStore.phasesForPlan(this.planId)
    this.tasks = await ChenwuStore.loadTasks()
    this.completionPct = await ChenwuStore.planCompletionPct(this.planId)
    this.paneEpoch = this.paneEpoch + 1
  }

  private phaseTasks(phaseId: string): CwPlanTask[] {
    const out: CwPlanTask[] = []
    for (const t of this.tasks) {
      if (t.phaseId === phaseId) {
        out.push(t)
      }
    }
    return out
  }

  private async toggleTask(taskId: string): Promise<void> {
    const found = await ChenwuStore.findTask(taskId)
    if (found === undefined) {
      return
    }
    found.done = !found.done
    await ChenwuStore.saveTask(found)
    this.onChanged()
    await this.reload()
  }

  private async remove(): Promise<void> {
    await ChenwuStore.deletePlan(this.planId)
    this.confirmDel = false
    this.onChanged()
    ChenwuDetailNav.closePlan()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(ChenwuMedia.bannerPlanPath())
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(100)
              .linearGradient({ angle: 180, colors: [['rgba(61,90,108,0)', 0], ['rgba(61,90,108,0.82)', 1]] })
            Text(this.plan.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F7F5F0')
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .clip(true)
          .borderRadius(Theme.radius.md)

          Text(`${CwHorizonLabels.label(this.plan.horizonType)} · ${CwHorizonLabels.statusLabel(this.plan.status)} · 完成 ${this.completionPct}%`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .key(`plan_meta_${this.paneEpoch}_${this.plan.status}_${this.completionPct}`)
          Progress({ value: this.completionPct, total: 100, type: ProgressType.Linear })
            .width('100%')
            .height(6)
            .color(Theme.colors().brandAccent)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .key(`plan_prog_${this.paneEpoch}_${this.completionPct}`)
          if (this.goalTitle.length > 0) {
            Text(`关联目标：${this.goalTitle}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
          }
          if (this.plan.startDate.length > 0) {
            Text(`${CwDateUtil.displayDate(this.plan.startDate)} — ${this.plan.endDate.length > 0 ? CwDateUtil.displayDate(this.plan.endDate) : '进行中'}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
          }

          AppCard({ title: '计划摘要' }) {
            Text(this.plan.summary.length > 0 ? this.plan.summary : '暂无摘要')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }

          Text('阶段与任务')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.phases, (ph: CwPhase) => {
            Column({ space: Theme.space.s2 }) {
              Row() {
                Text(ph.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(ph.status === 'active' ? '进行中' : ph.status === 'done' ? '已完成' : '待开始')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
              ForEach(this.phaseTasks(ph.id), (t: CwPlanTask) => {
                Row({ space: 8 }) {
                  AppIcon({
                    name: t.done ? 'check' : 'empty',
                    iconSize: Theme.icon.sm,
                    color: t.done ? Theme.colors().success : Theme.colors().textTertiary
                  })
                  Text(t.title)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().textPrimary)
                    .layoutWeight(1)
                }
                .width('100%')
                .onClick((): void => { void this.toggleTask(t.id) })
              }, (t: CwPlanTask) => `${t.id}_${t.done ? '1' : '0'}_${this.paneEpoch}`)
              if (ph.status === 'done') {
                AppButton({
                  label: '阶段复盘',
                  variant: 'secondary',
                  onTap: (): void => { ChenwuDetailNav.openReview(ph.id) }
                })
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (ph: CwPhase) => `${ph.id}_${ph.status}_${this.paneEpoch}`)

          AppButton({ label: '编辑计划', onTap: (): void => { ChenwuDetailNav.openPlanEditor(this.plan.id) } })
          AppButton({ label: '删除计划', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)

      if (this.confirmDel) {
        CwConfirmDialog({
          title: '删除这个计划？',
          message: '删除后无法恢复。',
          confirmLabel: '删除',
          onConfirm: (): void => { void this.remove() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
