import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { LegalDocs } from '../../models/LegalDocs'

export type LegalDocKind = 'privacy' | 'agreement'

/** 设置页叠加：隐私政策 / 用户协议全文（须高于 SettingsPanel zIndex） */
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
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })

        Text(this.title())
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Blank().width(44)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s3
      })

      Scroll() {
        Text(this.body())
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(22)
          .width('100%')
          .padding({ bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)

      Column() {
        AppButton({
          label: '我知道了',
          onTap: (): void => { this.onClose() }
        })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.s8
      })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .zIndex(60)
  }
}
