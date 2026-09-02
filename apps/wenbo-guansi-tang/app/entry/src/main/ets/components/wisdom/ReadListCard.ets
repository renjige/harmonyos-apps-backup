import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SymbolCover } from '../design-system/SymbolVisual'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct ReadListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop category: string = ''
  @Prop readMinutes: number = 0
  @Prop coverKey: string = 'cover_reading'
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      SymbolCover({
        category: this.category.length > 0 ? this.category : '阅读',
        coverKey: this.coverKey,
        tileSize: 80,
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
        Row({ space: 4 }) {
          Text(`${CategoryEmojiUtil.chipLabel(this.category)} · ${this.readMinutes} 分钟`)
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
    .onClick((): void => { this.onOpen() })
  }
}
