import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { LegalDocKind, LegalDocOverlay } from './LegalDocOverlay'
import { PrivacyService } from '../../services/PrivacyService'

@Component
export struct PrivacyConsentOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onAccepted: () => void = () => {}
  @State showDoc: boolean = false
  @State docKind: LegalDocKind = 'privacy'

  private async accept(): Promise<void> {
    await PrivacyService.acceptAndPersist()
    AppStorage.setOrCreate('privacyConsentPending', false)
    this.onAccepted()
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)

      Column({ space: Theme.space.s4 }) {
        Text('隐私政策提示')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('欢迎使用森野小记。我们重视您的隐私，请在开始使用前阅读并同意《用户协议》和《隐私政策》。同意前不会采集任何个人信息。')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: Theme.space.s4 }) {
          Text('《用户协议》')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => {
              this.docKind = 'agreement'
              this.showDoc = true
            })
          Text('《隐私政策》')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => {
              this.docKind = 'privacy'
              this.showDoc = true
            })
        }
        .width('100%')
        Column() {
          AppButton({
            label: '同意并继续',
            onTap: (): void => { void this.accept() }
          })
        }
        .width('100%')
        Text('不同意则无法使用本应用')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)

      if (this.showDoc) {
        LegalDocOverlay({
          kind: this.docKind,
          onClose: (): void => { this.showDoc = false }
        })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .zIndex(100)
  }
}
