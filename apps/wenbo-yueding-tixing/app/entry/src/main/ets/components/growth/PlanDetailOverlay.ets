import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { CommitmentPlan } from '../../models/GrowthModels'

@Component
export struct PlanDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop plan: CommitmentPlan = new CommitmentPlan()
  @State confirmDelete: boolean = false
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onDelete: (id: string) => Promise<boolean> = async () => false
  onCreateLinked: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('编辑')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onEdit() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: 14 }) {
          Text(this.plan.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.plan.description.length > 0) {
            Text(this.plan.description)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          Column({ space: 8 }) {
            Text(`${this.plan.doneCount} / ${this.plan.targetCount}`)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
            Progress({
              value: this.plan.doneCount,
              total: this.plan.targetCount > 0 ? this.plan.targetCount : 1,
              type: ProgressType.Linear
            })
              .color(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .width('100%')
            Text(`${this.plan.progressPercent()}% · ${this.plan.statusLabel()}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)

          Text(`周期：${this.plan.startDate}${this.plan.endDate.length > 0 ? ` 至 ${this.plan.endDate}` : ''}`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text(`已关联 ${this.plan.linkedAppointmentIds.length} 条约定`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          AppButton({ label: '创建关联约定', onTap: (): void => { this.onCreateLinked() } })
          if (this.confirmDelete) {
            AppButton({
              label: '确认删除计划',
              variant: 'danger',
              onTap: (): void => { void this.handleDelete() }
            })
          } else {
            AppButton({
              label: '删除计划',
              variant: 'secondary',
              onTap: (): void => { this.confirmDelete = true }
            })
          }
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  private async handleDelete(): Promise<void> {
    const ok = await this.onDelete(this.plan.id)
    if (ok) {
      this.onClose()
    }
  }
}
