import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { CampMedia } from '../../services/CampMedia'

@Component
export struct CampCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = ''
  @Prop region: string = ''
  @Prop campType: string = ''
  @Prop rating: number = 0
  onTap: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(CampMedia.resource(this.coverKey))
          .width('100%')
          .height(168)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(64)
          .linearGradient({
            angle: 180,
            colors: [['rgba(22,51,24,0)', 0.0], ['rgba(22,51,24,0.55)', 1.0]]
          })
        Text(this.campType)
          .fontSize(Theme.type.caption)
          .fontColor('#F5F0E8')
          .padding({ left: 12, bottom: 10 })
      }
      .width('100%')
      .height(168)
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
          Text(this.region)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text(`${this.rating.toFixed(1)}`)
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
    .borderRadius(Theme.radius.card)
    .clip(true)
    .onClick(() => this.onTap())
  }
}
