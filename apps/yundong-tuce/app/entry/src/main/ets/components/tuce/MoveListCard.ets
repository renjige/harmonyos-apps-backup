import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { TuceMedia } from '../../services/TuceMedia'
import { TuceNav } from '../../services/TuceNav'

@Component
export struct MoveListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop moveId: string = ''
  @Prop name: string = ''
  @Prop meta: string = ''
  @Prop coverKey: string = 'warmup'

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(TuceMedia.cover(this.coverKey))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)
      Column({ space: 4 }) {
        Text(this.name)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
        Text(this.meta)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { TuceNav.open('move', this.moveId) })
  }
}
