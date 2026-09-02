import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { RenoDates, RenoInspect } from '../../models/RenoModels'

@Component
export struct InspectDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RenoInspect = new RenoInspect()
  onClose: () => void = () => {}
  onPass: () => void = () => {}
  onPending: () => void = () => {}
  onNa: () => void = () => {}

  build() {
    DetailShell({
      title: this.item.title,
      coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'stage_accept',
      onBack: () => this.onClose()
    }) {
      Column({ space: Theme.space.s4 }) {
        Text(`${this.item.category} · ${RenoDates.inspectLabel(this.item.result)}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Column({ space: 8 }) {
          Text('核对说明')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          Text(this.item.body.length > 0 ? this.item.body : '按现场情况标记通过、待处理或不适用。结果仅供个人记录参考，不构成专业鉴定。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        Text('本清单用于个人对照，不能替代有资质单位的检测或验收文件。')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        AppButton({ label: '通过', onTap: () => this.onPass() })
        AppButton({ label: '待处理', variant: 'secondary', onTap: () => this.onPending() })
        AppButton({ label: '不适用', variant: 'ghost', onTap: () => this.onNa() })
      }
      .width('100%')
    }
  }
}
