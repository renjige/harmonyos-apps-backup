import { Theme } from './design-system/Theme'
import { AppIcon } from './design-system/AppIcon'
import { FactItem } from '../models/CommonSenseModels'
import { CommonSenseMedia } from '../services/CommonSenseMedia'
import { CommonSenseStore } from '../services/CommonSenseStore'

@Component
export struct ContentCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: FactItem = new FactItem()
  @Prop compact: boolean = false
  onOpen: () => void = () => {}

  build() {
    if (this.compact) {
      Column() {
        Image(CommonSenseMedia.resource(this.item.coverKey))
          .width('100%')
          .height(100)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })
        Column({ space: 4 }) {
          Text(this.item.title)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(2)
            .width('100%')
          Text(this.item.categoryLabel())
            .fontSize(10)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        .padding(10)
        .width('100%')
      }
      .width('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(12)
      .clip(true)
      .onClick((): void => { this.onOpen() })
    } else {
      Row({ space: Theme.space.s3 }) {
        Image(CommonSenseMedia.resource(this.item.coverKey))
          .width(96)
          .height(96)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sm)
        Column({ space: 6 }) {
          Text(this.item.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(2)
            .width('100%')
          Text(this.item.summary)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(2)
            .width('100%')
          Row({ space: 8 }) {
            Text(this.item.categoryLabel())
              .fontSize(11)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(8)
            if (CommonSenseStore.isFavorite(this.item.id)) {
              AppIcon({ name: 'heart', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
            }
            Blank()
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(12)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.card)
      .onClick((): void => { this.onOpen() })
    }
  }
}
