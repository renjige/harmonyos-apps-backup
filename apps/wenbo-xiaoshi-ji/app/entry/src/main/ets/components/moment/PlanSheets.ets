import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { LifePlan, PlanTask } from '../../models/MomentModels'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'

@Component
export struct PlanEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop planId: string = ''
  onSaved: () => void = () => {}
  onCancel: () => void = () => {}
  @State title: string = ''
  @State desc: string = ''
  @State tasksText: string = ''
  @State saving: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.planId.length === 0) {
      return
    }
    const plan = await MomentStore.findPlan(this.planId)
    if (plan === undefined) {
      return
    }
    this.title = plan.title
    this.desc = plan.description
    const lines: string[] = []
    for (let i = 0; i < plan.tasks.length; i++) {
      lines.push(plan.tasks[i].text)
    }
    this.tasksText = lines.join('\n')
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    this.saving = true
    let plan: LifePlan
    if (this.planId.length > 0) {
      const found = await MomentStore.findPlan(this.planId)
      plan = found !== undefined ? found : LifePlan.createNew()
    } else {
      plan = LifePlan.createNew()
    }
    plan.title = this.title
    plan.description = this.desc
    plan.tasks = []
    const rows = this.tasksText.split('\n')
    for (let i = 0; i < rows.length; i++) {
      const text = rows[i].trim()
      if (text.length > 0) {
        plan.tasks.push(PlanTask.create(text))
      }
    }
    const ok = await MomentStore.savePlan(plan)
    this.saving = false
    if (ok) {
      this.onSaved()
    }
  }

  build() {
    DetailShell({
      title: this.planId.length > 0 ? '编辑计划' : '新建计划',
      onClose: (): void => this.onCancel()
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.title, placeholder: '计划名称，如整理房间 / 旅行准备' })
            .width('100%')
            .onChange((v: string): void => { this.title = v })
          TextArea({ text: this.desc, placeholder: '补充说明（可选）' })
            .width('100%')
            .height(72)
            .onChange((v: string): void => { this.desc = v })
          TextArea({ text: this.tasksText, placeholder: '每行一个步骤\n例如：\n清理桌面\n整理衣柜' })
            .width('100%')
            .height(120)
            .onChange((v: string): void => { this.tasksText = v })
          AppButton({
            label: this.saving ? '保存中…' : '保存计划',
            disabled: this.saving,
            onTap: (): void => { void this.save() }
          })
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => this.onCancel() })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
  }
}

@Component
export struct PlanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @Prop planId: string = ''
  onChanged: () => void = () => {}
  @State plan: LifePlan | undefined = undefined

  aboutToAppear(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.plan = await MomentStore.findPlan(this.planId)
  }

  build() {
    DetailShell({
      title: '生活计划',
      onClose: (): void => MomentNav.close()
    }) {
      if (this.plan === undefined) {
        AppEmpty({ title: '计划不存在', description: '可能已被删除' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(this.plan.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(`${this.plan.doneCount()}/${this.plan.tasks.length} · ${this.plan.progress()}%`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            if (this.plan.description.length > 0) {
              Text(this.plan.description)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
            }
            ForEach(this.plan.tasks, (task: PlanTask) => {
              Row({ space: Theme.space.s2 }) {
                Text(task.done ? '已完成' : '待做')
                  .fontSize(Theme.type.caption)
                  .fontColor(task.done ? Theme.colors().success : Theme.colors().textSecondary)
                  .width(44)
                Text(task.text)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .decoration({ type: task.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
              .onClick((): void => {
                void MomentStore.togglePlanTask(this.planId, task.id).then(() => {
                  void this.reload()
                  this.onChanged()
                })
              })
            }, (task: PlanTask) => `${task.id}_${task.done}`)
            AppButton({
              label: '编辑计划',
              variant: 'secondary',
              onTap: (): void => MomentNav.openPlanEditor(this.planId)
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
      }
    }
  }
}
