import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SymbolCover } from '../design-system/SymbolVisual'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct ThoughtListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop category: string = ''
  @Prop coverKey: string = 'cover_wisdom'
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      SymbolCover({
        category: this.category,
        coverKey: this.coverKey,
        tileSize: 72,
        cornerRadius: Theme.radius.md
      })
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
        Text(this.summary)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
        if (this.category.length > 0) {
          Text(CategoryEmojiUtil.chipLabel(this.category))
            .fontSize(Theme.type.overline)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 6, color: Theme.colors().overlayScrim, offsetY: 2 })
    .onClick((): void => { this.onOpen() })
  }
}
