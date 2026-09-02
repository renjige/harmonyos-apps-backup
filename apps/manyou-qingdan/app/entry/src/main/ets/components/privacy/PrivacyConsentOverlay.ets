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
        Text('欢迎使用漫游清单')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)

        Text('漫游清单是一款纯本地生活体验规划工具。清单、体验记录、主题空间均保存在您的设备上，不上传云端，无需注册登录，也不申请相机、定位等权限。使用前请阅读并同意以下协议。')
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
