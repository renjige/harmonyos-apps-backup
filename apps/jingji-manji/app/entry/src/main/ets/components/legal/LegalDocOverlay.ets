import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { LegalDocs } from '../../models/LegalDocs'

export type LegalDocKind = 'privacy' | 'agreement'

/** 全屏协议 overlay：正文可滚到底，底部按钮不遮挡末行 */
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

  private footerInset(): number {
    return Theme.space.s10 + 72
  }

  build() {
    Column() {
      Row() {
        Text(this.title())
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .padding({ left: 12, right: 4, top: 8, bottom: 8 })
          .onClick(() => {
            this.onClose()
          })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })

      Stack({ alignContent: Alignment.Bottom }) {
        Scroll() {
          Column() {
            Text(this.body())
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .lineHeight(24)
              .width('100%')
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s2,
            bottom: this.footerInset()
          })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)

        Column() {
          AppButton({
            label: '我知道了',
            onTap: (): void => {
              this.onClose()
            }
          })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s6
        })
        .backgroundColor(Theme.colors().surfacePage)
        .border({
          width: { top: 1, left: 0, right: 0, bottom: 0 },
          color: Theme.colors().strokeHairline
        })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
