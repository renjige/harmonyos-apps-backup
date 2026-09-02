import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MatchItem } from '../../models/MatchModels'

@Component
export struct MatchListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: MatchItem = new MatchItem()
  @Prop compact: boolean = false
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(this.item.timeLabel())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text(this.item.statusLabel())
          .fontSize(Theme.type.overline)
          .fontColor(this.item.status === 'live' ?
            Theme.colors().danger : Theme.colors().brandPrimary)
          .width('100%')
      }
      .width(72)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 6 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (!this.compact) {
          Text(`${this.item.leagueName} · ${this.item.sportLabel()}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        if (this.item.homeScore >= 0 && this.item.awayScore >= 0) {
          Text(this.item.scoreText())
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}
