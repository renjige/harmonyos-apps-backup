import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { HomeItem } from '../../models/JujiaModels'
import { TaskMedia } from '../../services/TaskMedia'

@Component
export struct ItemRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: HomeItem = new HomeItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      Image(TaskMedia.cover(this.item.coverKey()))
        .width(56)
        .height(56)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Text(this.item.name)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(`${this.item.category}${this.item.location.length > 0 ? ' · ' + this.item.location : ''}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.item.expiryLabel())
          .fontSize(Theme.type.caption)
          .fontColor(this.item.isExpiringSoon() ? Theme.colors().danger : Theme.colors().textTertiary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(() => this.onTap())
  }
}
