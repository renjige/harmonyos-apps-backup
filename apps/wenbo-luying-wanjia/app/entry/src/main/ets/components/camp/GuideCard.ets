import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { CampMedia } from '../../services/CampMedia'

@Component
export struct GuideCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = ''
  @Prop minutes: number = 0
  onTap: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      Image(CampMedia.resource(this.coverKey))
        .width(96)
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.summary)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.minutes > 0 ? `${this.minutes} 分钟阅读` : '攻略')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick(() => this.onTap())
  }
}
