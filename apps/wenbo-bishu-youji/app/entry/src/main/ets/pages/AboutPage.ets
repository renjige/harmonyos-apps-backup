import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { EscapeDetailNav } from '../services/EscapeDetailNav'

@Component
export struct AboutPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false

  build() {
    Stack() {
      DetailShell({ title: '关于', onClose: () => EscapeDetailNav.close() }) {
        Column({ space: 16 }) {
          Image($r('app.media.app_icon'))
            .width(88)
            .height(88)
            .borderRadius(24)
            .objectFit(ImageFit.Cover)
          Text('避暑游记')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('版本 1.0.0')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text('按气温与地貌推荐避暑目的地，并把旅途写成可回看的游记。不含支付，也不提供生成式对话。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .textAlign(TextAlign.Center)
            .width('100%')
          AppButton({
            label: '用户协议',
            variant: 'ghost',
            onTap: (): void => {
              this.legalKind = 'agreement'
              this.showLegal = true
            }
          })
          AppButton({
            label: '隐私政策',
            variant: 'ghost',
            onTap: (): void => {
              this.legalKind = 'privacy'
              this.showLegal = true
            }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 24 })
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: (): void => { this.showLegal = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
