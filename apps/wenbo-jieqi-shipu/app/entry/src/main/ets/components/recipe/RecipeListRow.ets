import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SymbolCover } from '../design-system/SymbolVisual'
import { RecipeItem } from '../../models/SolarModels'
import { SolarMedia } from '../../services/SolarMedia'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

/** 列表模式：左图/ SymbolCover + Emoji 标签 + chevron */
@Component
export struct RecipeListRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop recipe: RecipeItem = new RecipeItem()
  @Prop useSymbolThumb: boolean = false
  onOpen: (id: string) => void = (_id: string) => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      if (this.useSymbolThumb) {
        SymbolCover({
          solarTerm: this.recipe.solarTerm,
          effect: this.recipe.effect,
          tileSize: 72,
          cornerRadius: Theme.radius.sm
        })
      } else {
        Image(SolarMedia.resource(this.recipe.coverKey))
          .width(72)
          .height(72)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sm)
      }
      Column({ space: 4 }) {
        Text(this.recipe.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${CategoryEmojiUtil.markForSolarTerm(this.recipe.solarTerm)} ${this.recipe.solarTerm} · ${CategoryEmojiUtil.markForEffect(this.recipe.effect)} ${this.recipe.effect}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .width('100%')
        if (this.recipe.summary.length > 0) {
          Text(this.recipe.summary)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(() => this.onOpen(this.recipe.id))
  }
}
