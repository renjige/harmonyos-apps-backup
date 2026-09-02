import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { DocumentService } from '../../services/DocumentService'

@Component
export struct ZhukeDocCategory {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop type: string = 'drawing'
  @Prop count: number = 0
  @Prop icon: AppIconName = 'biz'
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({ name: this.icon, iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.lg)

      Column({ space: Theme.space.s1 }) {
        Text(DocumentService.typeLabel(this.type))
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(`${this.count} 份文件`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textTertiary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow(Theme.cardShadow())
    .onClick(() => this.onTap())
  }
}
