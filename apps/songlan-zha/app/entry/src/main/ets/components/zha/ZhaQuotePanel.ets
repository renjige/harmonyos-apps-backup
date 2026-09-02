import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ZhaQuoteItem } from '../../models/ZhaModels'

@Component
export struct ZhaQuotePanel {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop quote: ZhaQuoteItem = new ZhaQuoteItem()

  build() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s2 }) {
        AppIcon({
          name: 'bookmark',
          iconSize: Theme.icon.md,
          color: Theme.colors().brandAccent
        })
        Text('今日智慧札')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
      Text(`「${this.quote.text}」`)
        .fontSize(Theme.type.title3)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(28)
        .fontWeight(FontWeight.Medium)
      Text(`— ${this.quote.author}`)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
