import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { LifePlan, PlanTask } from '../../models/LifeModels'
import { LifeStore } from '../../services/LifeStore'
import { ArchiveStore } from '../../services/ArchiveStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct PlanDetailPane {
  @Prop planId: string = ''
  @State plan: LifePlan = new LifePlan()
  @State tasks: PlanTask[] = []
  @State editTitle: string = ''
  @State showEdit: boolean = false
  @State confirmDelete: boolean = false
  onChanged: () => void = () => {}
  onDeleted: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await LifeStore.findPlan(this.planId)
    if (found !== undefined) {
      this.plan = found
      this.editTitle = found.title
    }
    this.tasks = await LifeStore.tasksForPlan(this.planId)
  }

  private async toggleTask(id: string): Promise<void> {
    const next: PlanTask[] = []
    for (const t of this.tasks) {
      const c = new PlanTask()
      c.id = t.id
      c.planId = t.planId
      c.title = t.title
      c.done = t.id === id ? !t.done : t.done
      c.sortOrder = t.sortOrder
      next.push(c)
    }
    this.tasks = next
    await LifeStore.togglePlanTaskDone(id)
    await ArchiveStore.recordActivityDate(DateHelper.todayKey())
    this.onChanged()
    await this.reload()
  }

  private async saveTitle(): Promise<void> {
    const t = this.editTitle.trim()
    if (t.length < 2) {
      return
    }
    this.plan.title = t
    await LifeStore.savePlan(this.plan)
    this.showEdit = false
    this.onChanged()
    await this.reload()
  }

  private async deletePlan(): Promise<void> {
    await LifeStore.deletePlan(this.planId)
    this.confirmDelete = false
    this.onDeleted()
  }

  private async toggleFavorite(): Promise<void> {
    await LifeStore.togglePlanFavorite(this.planId)
    this.onChanged()
    await this.reload()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Column({ space: 4 }) {
              Text(this.plan.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textPrimary)
              Text(this.plan.status === 'done' ? '已完成' : '进行中')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Text(this.plan.isFavorite ? '已收藏' : '收藏')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { void this.toggleFavorite() })
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '编辑标题', variant: 'secondary', onTap: (): void => { this.showEdit = true } })
              .layoutWeight(1)
            AppButton({ label: '删除计划', variant: 'secondary', onTap: (): void => { this.confirmDelete = true } })
              .layoutWeight(1)
          }
          .width('100%')

          Text('任务列表')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          if (this.tasks.length === 0) {
            Text('暂无任务')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
          } else {
            ForEach(this.tasks, (t: PlanTask) => {
              Row({ space: Theme.space.s3 }) {
                Text(t.done ? '☑' : '☐')
                  .fontSize(18)
                  .fontColor(t.done ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
                Text(t.title)
                  .fontSize(Theme.type.body)
                  .fontColor(t.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
                  .decoration({ type: t.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { void this.toggleTask(t.id) })
            }, (t: PlanTask) => `${t.id}_${t.done ? '1' : '0'}`)
          }
        }
        .padding(Theme.space.pageX)
      }
      .width('100%')
      .height('100%')

      if (this.showEdit) {
        this.EditDialog()
      }
      if (this.confirmDelete) {
        this.DeleteDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  EditDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.showEdit = false })
      Column({ space: Theme.space.s4 }) {
        Text('编辑计划标题')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        TextInput({ text: this.editTitle, placeholder: '计划名称' })
          .onChange((v: string): void => { this.editTitle = v })
        Row({ space: Theme.space.s3 }) {
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.showEdit = false } })
            .layoutWeight(1)
          AppButton({ label: '保存', variant: 'primary', onTap: (): void => { void this.saveTitle() } })
            .layoutWeight(1)
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
    .zIndex(20)
  }

  @Builder
  DeleteDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.confirmDelete = false })
      Column({ space: Theme.space.s4 }) {
        Text('确认删除计划？')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text('将同时删除该计划下的全部任务，不可恢复。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
        Row({ space: Theme.space.s3 }) {
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
            .layoutWeight(1)
          AppButton({ label: '删除', variant: 'primary', onTap: (): void => { void this.deletePlan() } })
            .layoutWeight(1)
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
    .zIndex(25)
  }
}
