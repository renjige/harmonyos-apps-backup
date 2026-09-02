import { Theme } from '../design-system/Theme'
import { JournalItem } from '../../models/EscapeModels'
import { EscapeMedia } from '../../services/EscapeMedia'

@Component
export struct JournalCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: JournalItem = new JournalItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      if (this.item.coverKey.length > 0) {
        Image(EscapeMedia.resource(this.item.coverKey))
          .width(72)
          .height(72)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sm)
      }
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .width('100%')
        Text(this.item.placeLabel)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.item.body)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Theme.colors().surfaceGlass)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
