import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { TaskRow } from '../reno/TaskRow'
import { RenoDates, RenoStage, RenoTask } from '../../models/RenoModels'
import { RenoCatalog } from '../../services/RenoCatalog'
import { RenoService } from '../../services/RenoService'

@Component
export struct StageDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop stageTitle: string = '水电'
  @StorageLink('renoRev') @Watch('onRev') renoRev: number = 0
  @State stage: RenoStage = new RenoStage()
  @State tasks: RenoTask[] = []
  @State taskN: number = 0
  @State matN: number = 0
  @State noteN: number = 0
  onClose: () => void = () => {}
  onOpenTask: (item: RenoTask) => void = (_i: RenoTask) => {}
  onToggleTask: (item: RenoTask) => void = (_i: RenoTask) => {}
  onAddTask: () => void = () => {}
  onSmart: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await RenoCatalog.stages()
    for (const row of all) {
      if (row.title === this.stageTitle) {
        this.stage = row
      }
    }
    if (this.stage.title.length === 0) {
      this.stage.title = this.stageTitle
      this.stage.coverKey = RenoDates.coverOf(this.stageTitle)
      this.stage.body = '进入该阶段后，可记录待办、材料与现场情况。'
    }
    const current = RenoService.currentProject()
    const pid = current !== null ? current.id : ''
    const tasks = await RenoService.tasks(pid)
    const filtered: RenoTask[] = []
    for (const row of tasks) {
      if (row.stage === this.stageTitle) {
        filtered.push(row)
      }
    }
    this.tasks = filtered
    this.taskN = filtered.length
    const mats = await RenoService.materials(pid)
    this.matN = mats.length
    const notes = await RenoService.notes(pid)
    this.noteN = notes.length
  }

  build() {
    DetailShell({
      title: this.stage.title,
      coverKey: this.stage.coverKey.length > 0 ? this.stage.coverKey : RenoDates.coverOf(this.stageTitle),
      onBack: () => this.onClose()
    }) {
      Column({ space: Theme.space.s4 }) {
        Text(this.stage.summary)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Column({ space: 8 }) {
          Text('阶段说明')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          Text(this.stage.body)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        Text(`待办 ${this.taskN} · 材料 ${this.matN} · 记录 ${this.noteN}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({ label: '查看智能装修清单', onTap: () => this.onSmart() })
        AppButton({ label: '添加本阶段事项', variant: 'secondary', onTap: () => this.onAddTask() })
        Text('本阶段事项')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        if (this.tasks.length === 0) {
          AppEmpty({
            title: '暂无待办',
            description: '当前阶段暂时没有待处理事项',
            actionLabel: '添加事项',
            onAction: () => this.onAddTask()
          })
        } else {
          ForEach(this.tasks, (it: RenoTask) => {
            TaskRow({
              item: it,
              onOpen: (row: RenoTask) => this.onOpenTask(row),
              onToggle: (row: RenoTask) => this.onToggleTask(row)
            })
          }, (it: RenoTask) => it.id)
        }
      }
      .width('100%')
    }
  }
}
