import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { LegalDocKind, LegalDocOverlay } from './LegalDocOverlay'
import { PrivacyService } from '../../services/PrivacyService'

/** 首次启动隐私同意弹层（单机应用无登录页时使用） */
@Component
export struct PrivacyConsentOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('privacyAccepted') privacyAccepted: boolean = false
  @State agreeChecked: boolean = false
  @State showLegal: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  onAccepted: () => void = () => {}

  private async handleAccept(): Promise<void> {
    if (!this.agreeChecked) {
      return
    }
    await PrivacyService.acceptAndPersist()
    this.privacyAccepted = true
    this.onAccepted()
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)

      Column() {
        Text('欢迎使用旅行拼图')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Text('我们重视你的隐私。本应用所有拼图与照片默认保存在本机，不上传云端。使用前请阅读并同意《用户协议》和《隐私政策》。')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(22)
          .margin({ top: Theme.space.s3 })
          .width('100%')

        Row() {
          Toggle({ type: ToggleType.Checkbox, isOn: this.agreeChecked })
            .selectedColor(Theme.colors().brandPrimary)
            .onChange((v: boolean) => {
              this.agreeChecked = v
            })
          Text('我已阅读并同意')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .margin({ left: Theme.space.s2 })
          Text('《用户协议》')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => {
              this.legalKind = 'agreement'
              this.showLegal = true
            })
          Text('和')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('《隐私政策》')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => {
              this.legalKind = 'privacy'
              this.showLegal = true
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ top: Theme.space.s5 })

        Row() {
          AppButton({
            label: '同意并进入',
            disabled: !this.agreeChecked,
            onTap: (): void => { void this.handleAccept() }
          })
        }
        .width('100%')
        .margin({ top: Theme.space.s5 })
        .onClick((): void => {
          if (this.agreeChecked) {
            void this.handleAccept()
          }
        })

        Text('不同意将无法使用本应用')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .margin({ top: Theme.space.s3 })
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .shadow({
        radius: 12,
        color: Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(45,58,74,0.08)',
        offsetX: 0,
        offsetY: 4
      })

      if (this.showLegal) {
        Column() {
          LegalDocOverlay({
            kind: this.legalKind,
            onClose: (): void => { this.showLegal = false }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
    }
    .width('100%')
    .height('100%')
  }
}
