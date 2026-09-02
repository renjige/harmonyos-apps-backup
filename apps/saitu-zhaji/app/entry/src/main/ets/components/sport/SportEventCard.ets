import { Theme } from '../design-system/Theme'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { SportEvent } from '../../models/SaituSportModels'

@Component
export struct SportEventCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: SportEvent = new SportEvent()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      if (this.item.images.length > 0) {
        Image(ImagePathUtil.toDisplayUri(this.item.images[0]))
          .width(72)
          .height(72)
          .borderRadius(Theme.radius.md)
          .objectFit(ImageFit.Cover)
      }
      Column({ space: Theme.space.s1 }) {
        Row({ space: Theme.space.s2 }) {
          Text(this.item.kindLabel())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
          Text(this.item.typeLabel())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
          if (this.item.moodStars().length > 0) {
            Text(this.item.moodStars())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
          }
          Blank()
          Text(this.item.eventDate)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        .width('100%')
        Text(this.item.title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (this.item.hasScore()) {
          Text(this.item.scoreLine())
            .fontSize(Theme.type.bodyS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
        }
        if (this.item.summaryLine().length > 0 && !this.item.hasScore()) {
          Text(this.item.summaryLine())
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        if (this.item.watchModeLabel().length > 0) {
          Text(this.item.watchModeLabel())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        if (this.item.kind === 'plan') {
          Text(this.item.statusLabel())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick((): void => this.onTap())
  }
}
