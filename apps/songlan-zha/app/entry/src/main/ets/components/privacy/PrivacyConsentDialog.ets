import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { LegalDocKind, LegalDocOverlay } from '../legal/LegalDocOverlay'
import { LegalDocs } from '../../models/LegalDocs'

/** 首次启动隐私同意弹窗（用户须明确同意后方可进入） */
@Component
export struct PrivacyConsentDialog {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onAccepted: () => void = () => {}
  @State showDoc: boolean = false
  @State docKind: LegalDocKind = 'privacy'

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)

      Column({ space: Theme.space.s4 }) {
        Text('欢迎使用松岚札')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('我们重视您的隐私。松岚札为本地优先的笔记与待办工具，您的笔记、待办与札记默认保存在本机。')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(22)
        Row({ space: Theme.space.s3 }) {
          Text('《隐私政策》')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => {
              this.docKind = 'privacy'
              this.showDoc = true
            })
          Text('《用户协议》')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => {
              this.docKind = 'agreement'
              this.showDoc = true
            })
        }
        Text(LegalDocs.privacySummaryLine())
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textTertiary)
          .lineHeight(18)
        AppButton({
          label: '同意并继续',
          variant: 'primary',
          onTap: () => this.onAccepted()
        })
        Text('不同意则无法使用本应用')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .shadow({ radius: 24, color: 'rgba(45,90,74,0.12)', offsetY: 8 })

      if (this.showDoc) {
        Column() {
          LegalDocOverlay({
            kind: this.docKind,
            onClose: () => { this.showDoc = false }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}
