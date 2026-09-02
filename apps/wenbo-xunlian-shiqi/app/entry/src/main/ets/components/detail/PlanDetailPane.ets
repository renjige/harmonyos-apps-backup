import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { SolidButton } from '../design-system/SolidButton'
import { DetailShell } from './DetailShell'
import { PlanTask, TrainPlan } from '../../models/TrainingModels'
import { PracticeHubStore } from '../../services/PracticeHubStore'
import { PlanService } from '../../services/PlanService'
import { DataRefresh } from '../../services/DataRefresh'

@Component
export struct PlanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop planId: string = ''
  @State plan: TrainPlan = new TrainPlan()
  @State tasks: PlanTask[] = []
  @State confirmDelete: boolean = false
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.load()
  }

  private load(): void {
    const found = PracticeHubStore.findPlan(this.planId)
    if (found !== null) {
      this.plan = found
      this.tasks = PlanService.unpack(found.tasksPacked)
    }
  }

  private async toggleAt(index: number): Promise<void> {
    const next = PlanService.toggle(this.plan, index)
    await PracticeHubStore.savePlan(next)
    DataRefresh.bump()
    this.onChanged()
    this.load()
  }

  private async deletePlan(): Promise<void> {
    await PracticeHubStore.deletePlan(this.planId)
    DataRefresh.bump()
    this.onChanged()
    this.onClose()
  }

  build() {
    DetailShell({
      title: '训练计划',
      onClose: (): void => { this.onClose() },
      body: (): void => { this.BodyContent() },
      footer: (): void => { this.FooterActions() }
    })
  }

  @Builder
  BodyContent() {
    Column({ space: 8 }) {
      Text(this.plan.title)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(this.plan.summary.length > 0 ? this.plan.summary : '勾选任务即可推进进度，全部完成后计划会标记为已完成。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
      Text(`进度 ${PlanService.doneCount(this.plan)} / ${PlanService.totalCount(this.plan)} · ${this.plan.status === 'done' ? '已完成' : '进行中'}`)
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.colors().brandPrimary)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)

    AppCard({ title: '任务清单' }) {
      Column({ space: Theme.space.s3 }) {
        ForEach(this.tasks, (t: PlanTask) => {
          Row({ space: Theme.space.s3 }) {
            Column() {
              Text(t.done ? '已完成' : '待完成')
                .fontSize(Theme.type.caption)
                .fontColor(t.done ? Theme.colors().success : Theme.colors().textSecondary)
            }
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(t.done ? Theme.colors().successContainer : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
            Text(t.title)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { void this.toggleAt(t.seq) })
        }, (t: PlanTask) => `${t.seq}_${t.title}`)
      }
    }
  }

  @Builder
  FooterActions() {
    if (this.confirmDelete) {
      Text('确定删除该计划？已勾选进度会一并清除。')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().danger)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Column() {
          SolidButton({
            label: '取消',
            tone: 'secondary',
            onTap: (): void => { this.confirmDelete = false }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { this.confirmDelete = false })
        Column() {
          SolidButton({
            label: '确认删除',
            tone: 'danger',
            onTap: (): void => { void this.deletePlan() }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { void this.deletePlan() })
      }
      .width('100%')
    } else {
      Column() {
        SolidButton({
          label: '删除计划',
          tone: 'secondary',
          onTap: (): void => { this.confirmDelete = true }
        })
      }
      .width('100%')
      .onClick((): void => { this.confirmDelete = true })
    }
  }
}
