import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SymbolCover } from '../design-system/SymbolVisual'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct ExploreListCard {
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop category: string = 'nature'
  @Prop coverKey: string = ''
  @Prop badge: string = ''
  @Prop meta: string = ''
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s4 }) {
      SymbolCover({
        category: this.category,
        coverKey: this.coverKey,
        tileSize: 80,
        cornerRadius: Theme.radius.xl
      })
      Column({ space: 6 }) {
        Row() {
          Text(this.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (this.badge.length > 0) {
            Text(this.badge)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
          }
        }
        .width('100%')
        if (this.meta.length > 0) {
          Text(this.meta)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        Text(this.summary.length > 0 ? this.summary : CategoryEmojiUtil.chipLabel(this.category))
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}
