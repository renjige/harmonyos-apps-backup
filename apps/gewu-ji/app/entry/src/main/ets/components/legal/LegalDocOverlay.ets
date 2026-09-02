import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { LegalDocs } from '../../models/LegalDocs'

export type LegalDocKind = 'privacy' | 'agreement' | 'collect' | 'third'

/** 全屏协议：须盖住设置底栏，正文可滚动到文末 */
@Component
export struct LegalDocOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: LegalDocKind = 'privacy'
  onClose: () => void = () => {}

  private title(): string {
    if (this.kind === 'agreement') {
      return LegalDocs.agreementTitle()
    }
    if (this.kind === 'collect') {
      return LegalDocs.collectTitle()
    }
    if (this.kind === 'third') {
      return LegalDocs.thirdTitle()
    }
    return LegalDocs.privacyTitle()
  }

  private body(): string {
    if (this.kind === 'agreement') {
      return LegalDocs.agreementBody()
    }
    if (this.kind === 'collect') {
      return LegalDocs.collectBody()
    }
    if (this.kind === 'third') {
      return LegalDocs.thirdBody()
    }
    return LegalDocs.privacyBody()
  }

  build() {
    Column() {
      Row() {
        Text(this.title())
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .maxLines(1)
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 12, right: 4, top: 12, bottom: 12 })
          .onClick((): void => { this.onClose() })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })

      Scroll() {
        Column() {
          Text(this.body())
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(26)
            .width('100%')
            .textAlign(TextAlign.Start)
          Row().height(Theme.space.s10)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .width('100%')
      .height('100%')
      .scrollBar(BarState.On)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.TopStart)

      Column() {
        AppButton({
          label: '我已阅读全文',
          onTap: (): void => { this.onClose() }
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
    .zIndex(90)
  }
}
