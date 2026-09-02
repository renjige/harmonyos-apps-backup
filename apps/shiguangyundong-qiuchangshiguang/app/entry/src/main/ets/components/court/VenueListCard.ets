import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { VenueItem } from '../../models/CourtModels'
import { CourtMedia } from '../../config/CourtMedia'
@Component
export struct VenueListCard {
  @Prop item: VenueItem = new VenueItem()
  @Prop showDistance: boolean = false
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(CourtMedia.byKey(this.item.coverKey))
        .width(88)
        .height(88)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)

      Column({ space: 4 }) {
        Row({ space: Theme.space.s2 }) {
          Text(this.item.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (this.showDistance) {
            Text(`${this.item.distanceKm}km`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
          }
        }
        .width('100%')

        Text(`${this.item.category} · ${this.item.priceLabel}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.item.summary)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: Theme.space.s2 }) {
          Text(`评分 ${this.item.rating.toFixed(1)}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
          Text(`· ${this.item.durationLabel}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => {
      this.onTap()
    })
  }
}
