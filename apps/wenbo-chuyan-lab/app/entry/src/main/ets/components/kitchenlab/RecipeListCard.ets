import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { RecipeItem } from '../../models/KitchenLabModels'
import { KitchenLabMedia } from '../../services/KitchenLabMedia'

@Component
export struct RecipeListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RecipeItem = new RecipeItem()
  @Prop compact: boolean = false
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(KitchenLabMedia.cover(this.item.coverKey))
        .width(this.compact ? 72 : 88)
        .height(this.compact ? 72 : 88)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
      Column({ space: Theme.space.s1 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.item.summary)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          if (this.item.cuisine.length > 0) {
            Text(this.item.cuisine)
              .fontSize(Theme.type.overline)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
          }
          if (this.item.matchRatio > 0) {
            Text(`匹配 ${Math.round(this.item.matchRatio * 100)}%`)
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().success)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
