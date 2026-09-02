import { Theme } from '../design-system/Theme'
import { LegalDocOverlay } from '../legal/LegalDocOverlay'
import { GalleryStore } from '../../services/GalleryStore'

@Component
export struct PrivacySaveDialog {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop visible: boolean = false
  onAccepted: () => void = () => {}
  onCancel: () => void = () => {}

  @State showPrivacy: boolean = false
  @State showAgreement: boolean = false

  build() {
    if (!this.visible) {
      Column()
    } else {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().overlayScrim)

        Column({ space: Theme.space.s4 }) {
          Text('保存作品')
            .fontSize(Theme.type.titleM)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('保存到本机画廊需您同意《用户协议》和《隐私政策》。作品仅保存在您的设备上。')
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Row({ space: Theme.space.s4 }) {
            Text('《用户协议》')
              .fontSize(Theme.type.bodyM)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick(() => { this.showAgreement = true })
            Text('《隐私政策》')
              .fontSize(Theme.type.bodyM)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick(() => { this.showPrivacy = true })
          }
          Row({ space: Theme.space.s3 }) {
            Button('暂不同意')
              .layoutWeight(1)
              .height(44)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .onClick(() => { this.onCancel() })
            Button('同意并保存')
              .layoutWeight(1)
              .height(44)
              .backgroundColor(Theme.colors().brandPrimary)
              .fontColor(Theme.colors().brandOnPrimary)
              .onClick((): void => {
                void GalleryStore.acceptPrivacy().then(() => {
                  this.onAccepted()
                })
              })
          }
          .width('100%')
        }
        .width('88%')
        .padding(Theme.space.s6)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)

        if (this.showPrivacy) {
          LegalDocOverlay({
            kind: 'privacy',
            onClose: () => { this.showPrivacy = false }
          })
        }
        if (this.showAgreement) {
          LegalDocOverlay({
            kind: 'agreement',
            onClose: () => { this.showAgreement = false }
          })
        }
      }
      .width('100%')
      .height('100%')
      .zIndex(60)
    }
  }
}
