import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { JigsawItem } from '../../models/JigsawModels'
import { JigsawMedia } from '../../services/JigsawMedia'

@Component
export struct JigsawListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: JigsawItem = new JigsawItem()
  onOpen: (id: string) => void = (_id: string) => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(JigsawMedia.cover(this.item.coverKey))
        .width(88)
        .height(88)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
      Column({ space: 6 }) {
        Text(this.item.themeLabel)
          .fontSize(12)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Text(this.item.title)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
        Text(this.item.summary)
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(20)
    .shadow({ radius: 12, color: 'rgba(92,46,18,0.08)', offsetY: 4, offsetX: 0 })
    .onClick(() => {
      this.onOpen(this.item.id)
    })
  }
}
