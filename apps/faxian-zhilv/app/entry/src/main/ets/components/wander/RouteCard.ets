import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { WanderMedia } from '../../services/WanderMedia'

@Component
export struct RouteCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = ''
  @Prop duration: string = ''
  @Prop difficulty: string = ''
  @Prop kindLabel: string = ''
  onTap: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(WanderMedia.resource(this.coverKey))
          .width('100%')
          .height(168)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Theme.radius.lg, topRight: Theme.radius.lg })
        Column()
          .width('100%')
          .height(56)
          .linearGradient({
            angle: 180,
            colors: [['rgba(36,53,43,0)', 0.0], ['rgba(36,53,43,0.42)', 1.0]]
          })
          .borderRadius({ topLeft: 0, topRight: 0 })
      }
      .width('100%')
      .borderRadius({ topLeft: Theme.radius.lg, topRight: Theme.radius.lg })
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
          Text(this.difficulty)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text(this.kindLabel)
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
