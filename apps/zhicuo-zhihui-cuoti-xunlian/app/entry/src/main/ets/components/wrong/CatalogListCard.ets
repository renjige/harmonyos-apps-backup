import { Theme } from '../design-system/Theme'
import { WrongMedia } from '../../services/WrongMedia'
import { CatalogItem } from '../../models/WrongModels'

@Component
export struct CatalogListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: CatalogItem = new CatalogItem()
  onOpen: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Image(WrongMedia.resource(this.item.coverKey))
        .width(148)
        .height(96)
        .borderRadius(Theme.radius.sm)
        .objectFit(ImageFit.Cover)
      Text(this.item.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .width('100%')
      Text(this.item.summary)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
        .width('100%')
    }
    .width(148)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => this.onOpen())
  }
}
