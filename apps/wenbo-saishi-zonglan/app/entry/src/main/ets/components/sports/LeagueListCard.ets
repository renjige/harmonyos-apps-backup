import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { LeagueItem } from '../../models/MatchModels'
import { SportsMedia } from '../../services/SportsMedia'

@Component
export struct LeagueListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: LeagueItem = new LeagueItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column()
        .width(52)
        .height(52)
        .linearGradient({
          angle: 135,
          colors: [[SportsMedia.mediaResource(this.item.coverKey)[0], 0],
            [SportsMedia.mediaResource(this.item.coverKey)[1], 1]]
        })
        .borderRadius(Theme.radius.md)

      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.item.sportLabel())
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        if (this.item.statsValue.length > 0) {
          Text(`${this.item.statsLabel} ${this.item.statsValue}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
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
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}
