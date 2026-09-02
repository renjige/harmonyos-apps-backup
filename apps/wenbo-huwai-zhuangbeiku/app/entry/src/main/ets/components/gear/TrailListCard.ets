import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { GearMedia } from '../../services/GearMedia'

@Component
export struct TrailListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop meta: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = ''
  onTap: () => void = () => {}

  build() {
    Column({ space: 0 }) {
      Image(GearMedia.resource(this.coverKey))
        .width('100%')
        .height(140)
        .objectFit(ImageFit.Cover)
      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.meta)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.summary)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .width('100%')
        Row() {
          Blank()
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
        }
        .width('100%')
      }
      .padding(12)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .clip(true)
    .onClick(() => this.onTap())
  }
}
