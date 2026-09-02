import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { TeamItem } from '../../models/MatchModels'
import { SportsMedia } from '../../services/SportsMedia'

@Component
export struct TeamListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: TeamItem = new TeamItem()
  @Prop showForm: boolean = true
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image(SportsMedia.coverImage(this.item.coverKey))
          .width(56)
          .height(56)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
        Column()
          .width(56)
          .height(56)
          .borderRadius(Theme.radius.lg)
          .linearGradient({
            angle: 180,
            colors: [['rgba(15,23,42,0.15)', 0], ['rgba(15,23,42,0.45)', 1]]
          })
        Text(this.item.title.length > 0 ? this.item.title.substring(0, 1) : '队')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnInverse)
      }

      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(this.item.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.item.sportLabel())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')

        Text(this.item.leagueName.length > 0 ? this.item.leagueName : this.item.summary)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.showForm && this.item.statsValue.length > 0) {
          Row({ space: 6 }) {
            Text(this.item.statsLabel.length > 0 ? this.item.statsLabel : '联赛战绩')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
            Text(this.item.statsValue)
              .fontSize(Theme.type.callout)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().success)
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}
