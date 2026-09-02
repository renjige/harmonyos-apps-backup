import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { RenoExpense } from '../../models/RenoModels'

@Component
export struct ExpenseDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RenoExpense = new RenoExpense()
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}

  build() {
    DetailShell({
      title: this.item.title,
      coverKey: 'stage_install',
      onBack: () => this.onClose()
    }) {
      Column({ space: Theme.space.s4 }) {
        Text(`${this.item.category} · ${this.item.date}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Column({ space: 8 }) {
          Text('金额')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          Text(`¥${this.item.amount}`)
            .fontSize(Theme.type.displayS)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        Text(this.item.remark.length > 0 ? this.item.remark : '这是业主自己记下的费用备忘，不提供在线支付。')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        AppButton({ label: '编辑费用', onTap: () => this.onEdit() })
        AppButton({ label: '删除费用', variant: 'danger', onTap: () => this.onDelete() })
      }
      .width('100%')
    }
  }
}
