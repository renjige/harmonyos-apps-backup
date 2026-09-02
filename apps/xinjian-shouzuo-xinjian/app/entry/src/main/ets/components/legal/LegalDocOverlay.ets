import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { LegalDocs } from '../../models/LegalDocs'

export type LegalDocKind = 'privacy' | 'agreement'

/** 登录页叠加：隐私政策 / 用户协议全文 */
@Component
export struct LegalDocOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: LegalDocKind = 'privacy'
  onClose: () => void = () => {}

  private title(): string {
    if (this.kind === 'agreement') {
      return LegalDocs.agreementTitle()
    }
    return LegalDocs.privacyTitle()
  }

  private body(): string {
    if (this.kind === 'agreement') {
      return LegalDocs.agreementBody()
    }
    return LegalDocs.privacyBody()
  }

  build() {
    Column() {
      Row() {
        Text(this.title())
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandDeep)
          .padding({ left: 12, right: 4, top: 8, bottom: 8 })
          .onClick(() => this.onClose())
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })

      Scroll() {
        Text(this.body())
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(22)
          .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .scrollBar(BarState.Auto)

      Column() {
        AppButton({
          label: '我知道了',
          onTap: () => this.onClose()
        })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.pageY
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
