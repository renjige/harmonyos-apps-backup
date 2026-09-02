import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { LegalDocOverlay } from '../legal/LegalDocOverlay'

@Component
export struct PrivacyConsentOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State agreed: boolean = false
  @State showPrivacy: boolean = false
  @State showAgreement: boolean = false
  onAccept: () => void = () => {}
  onRefuse: () => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)

      Column({ space: Theme.space.s4 }) {
        Text('欢迎使用积累日记')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

        Text('日记正文与配图默认仅保存在本机，不会上传云端。使用前请阅读并同意以下协议。')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(22)

        Row({ space: Theme.space.s2 }) {
          Toggle({ type: ToggleType.Checkbox, isOn: this.agreed })
            .selectedColor(Theme.colors().brandPrimary)
            .onChange((v: boolean) => { this.agreed = v })
          Column({ space: 2 }) {
            Text('我已阅读并同意')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Row({ space: 4 }) {
              Text('《用户协议》')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick(() => { this.showAgreement = true })
              Text('和')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Text('《隐私政策》')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick(() => { this.showPrivacy = true })
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        AppButton({
          label: '同意并继续',
          variant: 'primary',
          disabled: !this.agreed,
          onTap: (): void => { if (this.agreed) { this.onAccept() } }
        })

        AppButton({
          label: '暂不同意',
          variant: 'secondary',
          onTap: (): void => { this.onRefuse() }
        })
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .shadow({ radius: 24, color: 'rgba(45,45,45,0.12)', offsetY: 8 })

      if (this.showPrivacy) {
        LegalDocOverlay({
          kind: 'privacy',
          onClose: (): void => { this.showPrivacy = false }
        })
      }
      if (this.showAgreement) {
        LegalDocOverlay({
          kind: 'agreement',
          onClose: (): void => { this.showAgreement = false }
        })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(100)
  }
}
