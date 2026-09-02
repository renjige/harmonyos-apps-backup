import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { GearDetailNav } from '../services/GearDetailNav'

@Component
export struct AboutPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false

  build() {
    Stack() {
      DetailShell({ title: '关于', onClose: () => GearDetailNav.close() }) {
        Column({ space: 16 }) {
          Image($r('app.media.icon'))
            .width(88)
            .height(88)
            .borderRadius(24)
            .objectFit(ImageFit.Cover)
          Text('户外装备库')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('版本 1.0.0')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text('把装备克重、成色与山野路线对照放进同一个账本。全部功能免费，不含支付、定位追踪与生成式对话。')
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
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
      }

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => { this.showLegal = false }
        })
          .width('100%')
          .height('100%')
      }
    }
  }
}
