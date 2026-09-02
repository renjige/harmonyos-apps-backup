import { Theme } from '../design-system/Theme'
import { NoteItem } from '../../models/ScenicModels'
import { ScenicMedia } from '../../services/ScenicMedia'

@Component
export struct NoteCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: NoteItem = new NoteItem()
  onTap: () => void = () => {}

  build() {
    Column() {
      Image(ScenicMedia.resource(this.item.coverKey))
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: Theme.radius.lg, topRight: Theme.radius.lg })
      Column({ space: 6 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .width('100%')
        Text(this.item.summary)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .width('100%')
        Row() {
          Text(this.item.userName)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Blank()
          Text(this.item.likesLabel())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
      }
      .padding(14)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .clip(true)
    .onClick(() => this.onTap())
  }
}
