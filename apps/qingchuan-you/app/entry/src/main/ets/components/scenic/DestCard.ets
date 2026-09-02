import { Theme } from '../design-system/Theme'
import { DestItem } from '../../models/ScenicModels'
import { ScenicMedia } from '../../services/ScenicMedia'

@Component
export struct DestCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: DestItem = new DestItem()
  onTap: () => void = () => {}

  build() {
    Column() {
      Image(ScenicMedia.resource(this.item.coverKey))
        .width('100%')
        .height(118)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: Theme.radius.md, topRight: Theme.radius.md })
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.item.categoryLabel())
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(`${this.item.city} · ${this.item.daysLabel()}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .padding(10)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .clip(true)
    .onClick(() => this.onTap())
  }
}
