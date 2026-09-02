import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { PlanTask, TrainingPlan } from '../../models/SportModels'
import { PlanStore } from '../../services/PlanStore'
import { SportDetailNav } from '../../services/SportDetailNav'
import { SportModelClone } from '../../services/SportModelClone'

@Component
export struct PlanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop planId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State plan: TrainingPlan = new TrainingPlan()
  @State confirmDelete: boolean = false
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.load()
  }

  onRefreshTokenChange(): void {
    this.load()
  }

  private load(): void {
    const found = PlanStore.findById(this.planId)
    if (found !== null) {
      this.plan = found
    }
  }

  build() {
    DetailShell({
      title: '周计划详情',
      onClose: (): void => {
        SportDetailNav.close()
      },
      body: (): void => {
        this.BodyContent()
      },
      footer: (): void => {
        this.FooterActions()
      }
    })
  }

  @Builder
  BodyContent() {
    Column({ space: Theme.space.s5 }) {
      Column({ space: Theme.space.s2 }) {
        Text(this.plan.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(`${this.plan.weekStart} → ${this.plan.weekEnd}`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Row({ space: Theme.space.s3 }) {
          Text(`总进度 ${PlanStore.progress(this.plan)}%`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandPrimary)
          Text(this.plan.status === 'done' ? '· 已完成' : '· 进行中')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        Progress({
          value: PlanStore.progress(this.plan),
          total: 100,
          type: ProgressType.Linear
        })
          .width('100%')
          .color(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
      }
      .width('100%')
      .padding(Theme.space.s5)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      Text('训练任务')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')

      ForEach(this.plan.tasks, (t: PlanTask) => {
        this.TaskRow(t)
      }, (t: PlanTask) => `${t.id}_${t.doneCount}_${t.status}`)
    }
    .width('100%')
  }

  @Builder
  TaskRow(t: PlanTask) {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s3 }) {
        Column({ space: 4 }) {
          Text(t.title.length > 0 ? t.title : '未命名任务')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`${t.sportType} · 目标 ${t.targetCount} 次`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(t.doneCount >= t.targetCount ? '已完成' : `${t.doneCount}/${t.targetCount}`)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor(t.doneCount >= t.targetCount ? Theme.colors().success : Theme.colors().brandPrimary)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(t.doneCount >= t.targetCount ?
            Theme.colors().successContainer : Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Stack({ alignContent: Alignment.Start }) {
        Column()
          .width('100%')
          .height(8)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
        Column()
          .width(`${Math.max(4, Math.round((t.doneCount / Math.max(1, t.targetCount)) * 100))}%`)
          .height(8)
          .linearGradient({ angle: 90, colors: Theme.brandGradient() })
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')

      if (t.doneCount < t.targetCount) {
        Row() {
          Blank().layoutWeight(1)
          Text('+1 完成')
            .fontSize(Theme.type.footnote)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => {
              void this.tickTask(t.id)
            })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  FooterActions() {
    if (this.plan.status !== 'done') {
      AppButton({
        label: '标记计划完成',
        onTap: (): void => {
          void this.markDone()
        }
      })
    }
    AppButton({
      label: this.confirmDelete ? '确认删除计划' : '删除计划',
      variant: this.confirmDelete ? 'danger' : 'secondary',
      onTap: (): void => {
        void this.handleDelete()
      }
    })
  }

  private async tickTask(taskId: string): Promise<void> {
    const next = SportModelClone.plan(this.plan)
    for (const t of next.tasks) {
      if (t.id === taskId && t.doneCount < t.targetCount) {
        t.doneCount += 1
        if (t.doneCount >= t.targetCount) {
          t.status = 'done'
        }
        break
      }
    }
    await PlanStore.save(next)
    this.plan = SportModelClone.plan(next)
    this.onChanged()
  }

  private async markDone(): Promise<void> {
    const next = SportModelClone.plan(this.plan)
    next.status = 'done'
    await PlanStore.save(next)
    this.plan = SportModelClone.plan(next)
    this.onChanged()
  }

  private async handleDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await PlanStore.remove(this.plan.id)
    this.onChanged()
    SportDetailNav.close()
  }
}
