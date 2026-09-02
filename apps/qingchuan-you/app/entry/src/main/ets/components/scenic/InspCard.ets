import { Theme } from '../design-system/Theme'
import { InspItem } from '../../models/ScenicModels'
import { ScenicMedia } from '../../services/ScenicMedia'

@Component
export struct InspCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InspItem = new InspItem()
  onTap: () => void = () => {}

  build() {
    Column() {
      Image(ScenicMedia.resource(this.item.coverKey))
        .width('100%')
        .height(140)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: Theme.radius.md, topRight: Theme.radius.md })
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.item.sourceLabel)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(10)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .clip(true)
    .onClick(() => this.onTap())
  }
}
