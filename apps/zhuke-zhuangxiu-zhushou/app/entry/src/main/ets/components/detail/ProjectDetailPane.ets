import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { RenoDates, RenoProject } from '../../models/RenoModels'
import { RenoService } from '../../services/RenoService'

@Component
export struct ProjectDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RenoProject = new RenoProject()
  @State toast: string = ''
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}
  onOpenStage: (stage: string) => void = (_s: string) => {}
  onAddTask: () => void = () => {}
  onOpenExpense: () => void = () => {}
  onOpenTimeline: () => void = () => {}
  onExport: () => void = () => {}
  onSetCurrent: () => void = () => {}

  private async useThis(): Promise<void> {
    await RenoService.setCurrent(this.item.id)
    this.toast = '已设为当前项目'
    setTimeout(() => { this.toast = '' }, 1800)
    this.onSetCurrent()
  }

  build() {
    Stack() {
      DetailShell({
        title: this.item.title,
        coverKey: RenoDates.coverOf(this.item.stage),
        onBack: () => this.onClose()
      }) {
        Column({ space: Theme.space.s4 }) {
          Text(`${this.item.houseType} · ${this.item.stage} · ${this.item.status === 'done' ? '已完成' : '施工中'}`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Column({ space: 8 }) {
            Text('进度摘要')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Text(`${this.item.progress}%`)
              .fontSize(Theme.type.displayS)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Progress({ value: this.item.progress, total: 100, type: ProgressType.Linear })
              .width('100%').height(8).color(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceSubtle)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          Text(this.item.remark.length > 0 ? this.item.remark : '记录开工日期、当前阶段和完成进度。进入阶段可查看待办、材料与现场记录。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(`开始日期 ${this.item.startDate}${this.item.budget.length > 0 ? ` · 预算 ¥${this.item.budget}` : ''}`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({ label: '设为当前项目', onTap: () => { void this.useThis() } })
          AppButton({ label: `查看「${this.item.stage}」阶段`, variant: 'secondary', onTap: () => this.onOpenStage(this.item.stage) })
          AppButton({ label: '添加事项', variant: 'secondary', onTap: () => this.onAddTask() })
          AppButton({ label: '记一笔费用', variant: 'secondary', onTap: () => this.onOpenExpense() })
          AppButton({ label: '施工时间线', variant: 'secondary', onTap: () => this.onOpenTimeline() })
          AppButton({ label: '导出项目纪要', variant: 'secondary', onTap: () => this.onExport() })
          AppButton({ label: '编辑项目', variant: 'ghost', onTap: () => this.onEdit() })
          AppButton({ label: '删除项目', variant: 'danger', onTap: () => this.onDelete() })
        }
        .width('100%')
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
