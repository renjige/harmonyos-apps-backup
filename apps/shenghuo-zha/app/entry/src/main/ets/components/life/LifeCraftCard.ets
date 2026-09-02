import { Theme } from '../design-system/Theme'
import { LifeCraftItem } from '../../models/LifeModels'
import { LifeDateHelper } from '../../services/LifeLocalStore'

@Component
export struct LifeCraftCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: LifeCraftItem = new LifeCraftItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text(this.item.kindLabel())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
        if (this.item.pinned) {
          Text('收藏')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandDeep)
            .margin({ left: Theme.space.s2 })
        }
        Blank()
        Text(this.item.category)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .width('100%')
      Text(this.item.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .maxLines(2)
      if (this.item.summary(80).length > 0) {
        Text(this.item.summary(80))
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(2)
          .lineHeight(18)
      }
      if (this.item.progressLabel().length > 0) {
        Text(this.item.progressLabel())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandDeep)
      }
      Text(LifeDateHelper.formatDateTime(LifeDateHelper.effectiveTs(
        this.item.createdAt, this.item.updatedAt, this.item.id)))
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}
