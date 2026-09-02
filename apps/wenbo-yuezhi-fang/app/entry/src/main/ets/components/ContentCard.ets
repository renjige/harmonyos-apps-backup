import { Theme } from './design-system/Theme'
import { AppIcon } from './design-system/AppIcon'
import { CardItem } from '../models/AtelierModels'
import { AtelierMedia } from '../services/AtelierMedia'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct ContentCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: CardItem = new CardItem()
  onOpen: () => void = () => {}

  build() {
    Column() {
      Image(AtelierMedia.resource(this.item.coverKey))
        .width('100%')
        .height(148)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: 12, topRight: 12 })
      Column({ space: 6 }) {
        Text(this.item.title)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .width('100%')
        Text(this.item.summary)
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .width('100%')
        Row({ space: 8 }) {
          Text(CategoryEmojiUtil.chipLabel(this.item.category))
            .fontSize(11)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(8)
          Row({ space: 4 }) {
            AppIcon({ name: 'bookmark', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
            Text(`${this.item.readMinutes} 分钟`)
              .fontSize(11)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          Blank()
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
        }
        .width('100%')
      }
      .padding(12)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(12)
    .clip(true)
    .onClick((): void => { this.onOpen() })
  }
}
