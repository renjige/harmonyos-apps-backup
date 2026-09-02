import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SymbolCover } from '../design-system/SymbolVisual'
import { QuoteItem } from '../../models/CoolPlanModels'

@Component
export struct QuoteListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: QuoteItem = new QuoteItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      SymbolCover({
        category: '语录',
        coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_mist_lake',
        tileSize: 56,
        cornerRadius: Theme.radius.md
      })
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.item.summary)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (this.item.author.length > 0) {
          Text(`— ${this.item.author}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
