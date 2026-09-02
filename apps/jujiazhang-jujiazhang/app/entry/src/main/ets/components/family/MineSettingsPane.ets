import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct MineSettingsPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onBack: () => void = () => {}
  onOpenAgreement: () => void = () => {}
  onOpenPrivacy: () => void = () => {}
  onRevoke: () => void = () => {}
  onDeleteAccount: () => void = () => {}

  build() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        AppIcon({ name: 'chevron', iconSize: 18, color: Theme.colors().textSecondary })
          .rotate({ angle: 180 })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 18, bottom: 8 })
      .onClick(() => this.onBack())

      Column({ space: 10 }) {
        AppButton({ label: '查看《用户协议》', variant: 'ghost', onTap: () => this.onOpenAgreement() })
        AppButton({ label: '查看《隐私政策》', variant: 'ghost', onTap: () => this.onOpenPrivacy() })
        Row() {
          AppButton({
            label: '撤回隐私同意',
            variant: 'secondary',
            onTap: (): void => { this.onRevoke() }
          })
        }
        .width('100%')
        .onClick((): void => { this.onRevoke() })
        AppButton({
          label: '注销账号',
          variant: 'danger',
          onTap: (): void => { this.onDeleteAccount() }
        })
      }
      .padding(16)
    }
    .width('100%')
  }
}
