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
        Text('欢迎使用训练拾趣')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)

        Text('训练拾趣帮助您记录日常训练、查看统计与解锁趣味成就。所有训练数据默认仅保存在本机，不上传云端。使用前请阅读并同意以下协议。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(22)

        Row({ space: Theme.space.s2 }) {
          Toggle({ type: ToggleType.Checkbox, isOn: this.agreed })
            .selectedColor(Theme.colors().brandPrimary)
            .onChange((v: boolean): void => { this.agreed = v })
          Column({ space: 2 }) {
            Text('我已阅读并同意')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textPrimary)
            Row({ space: 4 }) {
              Text('《用户协议》')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { this.showAgreement = true })
              Text('和')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
              Text('《隐私政策》')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { this.showPrivacy = true })
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
          onTap: (): void => this.onRefuse()
        })
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .shadow({ radius: 24, color: 'rgba(15,23,42,0.12)', offsetY: 8 })

      if (this.showPrivacy) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacy = false } })
      }
      if (this.showAgreement) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreement = false } })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(100)
  }
}
