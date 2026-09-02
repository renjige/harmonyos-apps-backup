import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { LeagueItem } from '../../models/MatchModels'
import { SportsMedia } from '../../services/SportsMedia'

@Component
export struct LeagueListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: LeagueItem = new LeagueItem()
  @Prop compact: boolean = false
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(SportsMedia.coverImage(this.item.coverKey))
        .width(this.compact ? 56 : 72)
        .height(this.compact ? 56 : 72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(this.compact ? Theme.type.subhead : Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.item.sportLabel())
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        if (this.item.statsLabel.length > 0 && this.item.statsValue.length > 0) {
          Text(`${this.item.statsLabel} ${this.item.statsValue}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        } else if (this.item.summary.length > 0) {
          Text(this.item.summary)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(this.compact ? Theme.space.s3 : Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}
