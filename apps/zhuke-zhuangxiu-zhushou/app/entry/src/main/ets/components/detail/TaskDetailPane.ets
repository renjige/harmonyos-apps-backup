import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { RenoDates, RenoTask } from '../../models/RenoModels'

@Component
export struct TaskDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RenoTask = new RenoTask()
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onCycle: () => void = () => {}
  onDelete: () => void = () => {}

  private cta(): string {
    if (this.item.status === 'todo') {
      return '开始处理'
    }
    if (this.item.status === 'doing') {
      return '标记完成'
    }
    return '重新打开'
  }

  build() {
    DetailShell({
      title: this.item.title,
      coverKey: RenoDates.coverOf(this.item.stage),
      onBack: () => this.onClose()
    }) {
      Column({ space: Theme.space.s4 }) {
        Text(`${this.item.stage} · ${RenoDates.taskLabel(this.item.status)}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Column({ space: 8 }) {
          Text('事项摘要')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          Text(this.item.remark.length > 0 ? this.item.remark : '完成后点下方按钮更新状态，便于对照装修进度。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        Text(`日期 ${this.item.date}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        if (this.item.remindAt.length > 0) {
          Text(`提醒 ${this.item.remindAt}`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().warning)
            .width('100%')
        }
        AppButton({ label: this.cta(), onTap: () => this.onCycle() })
        AppButton({ label: '编辑事项', variant: 'secondary', onTap: () => this.onEdit() })
        AppButton({ label: '删除事项', variant: 'danger', onTap: () => this.onDelete() })
      }
      .width('100%')
    }
  }
}
