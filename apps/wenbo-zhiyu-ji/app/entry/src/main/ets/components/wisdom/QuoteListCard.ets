import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SymbolCover } from '../design-system/SymbolVisual'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'
import { WisdomItem } from '../../models/WisdomHallModels'

@Component
export struct QuoteListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: WisdomItem = new WisdomItem()
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      SymbolCover({
        category: this.item.category,
        coverKey: this.item.coverKey,
        tileSize: 56,
        cornerRadius: 12
      })
      Column({ space: 8 }) {
        Text(`「${this.item.summaryLine()}」`)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row() {
          Text(this.item.authorName.length > 0 ? `—— ${this.item.authorName}` : '')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .layoutWeight(1)
          if (this.item.category.length > 0) {
            Text(CategoryEmojiUtil.chipLabel(this.item.category))
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(16)
    .shadow({ radius: 6, color: 'rgba(26,42,58,0.06)', offsetY: 2 })
    .onClick((): void => { this.onOpen() })
  }
}
