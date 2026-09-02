import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { XuNoteItem } from '../../models/XuModels'
import { XuMedia } from '../../services/XuMedia'

@Component
export struct XuNoteCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: XuNoteItem = new XuNoteItem()
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(XuMedia.note())
        .width(72)
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .width('100%')
        Text(this.item.summary(48))
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .width('100%')
        if (this.item.tagPreview().length > 0) {
          Text(this.item.tagPreview())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
            .maxLines(1)
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick(() => this.onOpen())
  }
}
