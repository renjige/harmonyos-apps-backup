import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { RoadMedia } from '../../services/RoadMedia'

@Component
export struct RouteCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = ''
  @Prop duration: string = ''
  @Prop mileage: string = ''
  @Prop ageRange: string = ''
  @Prop themeLabel: string = ''
  onTap: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(RoadMedia.resource(this.coverKey))
          .width('100%')
          .height(176)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(72)
          .linearGradient({
            angle: 180,
            colors: [['rgba(20,61,40,0)', 0.0], ['rgba(20,61,40,0.72)', 1.0]]
          })
        Text(this.themeLabel)
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(45,143,92,0.92)')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(Theme.radius.pill)
          .margin({ left: 12, bottom: 12 })
      }
      .width('100%')
      .clip(true)

      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.summary)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: 8 }) {
          Text(this.duration)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text(this.mileage)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text(this.ageRange)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Blank()
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
        }
        .width('100%')
      }
      .padding({ left: 16, right: 16, bottom: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .clip(true)
    .onClick(() => this.onTap())
  }
}
