import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { DailyQuoteItem } from '../../models/DailyModels'

@Component
export struct QuoteCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop quote: DailyQuoteItem = new DailyQuoteItem()
  @Prop favorited: boolean = false
  onToggleFavorite: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('今日智慧')
          .fontSize(Theme.type.overline)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .layoutWeight(1)
        Column() {
          AppIcon({
            name: this.favorited ? 'heart' : 'bookmark',
            iconSize: Theme.icon.md,
            color: this.favorited ? '#FFB347' : Theme.colors().textSecondary
          })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onToggleFavorite())
      }
      .width('100%')

      Text(`「${this.quote.text}」`)
        .fontSize(Theme.type.subtitleM)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(26)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
