import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { WanderMedia } from '../../services/WanderMedia'

@Component
export struct JournalCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop place: string = ''
  @Prop mood: string = ''
  @Prop dateLabel: string = ''
  @Prop preview: string = ''
  @Prop photoUri: string = ''
  @Prop coverKey: string = ''
  onTap: () => void = () => {}

  private hasThumb(): boolean {
    return this.photoUri.length > 0 || this.coverKey.length > 0
  }

  @Builder
  Thumb() {
    if (this.photoUri.length > 0) {
      Image(this.photoUri)
        .width(56)
        .height(56)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)
    } else if (this.coverKey.length > 0) {
      Image(WanderMedia.resource(this.coverKey))
        .width(56)
        .height(56)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)
    }
  }

  build() {
    Row({ space: 12 }) {
      if (this.hasThumb()) {
        this.Thumb()
      }
      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.preview)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${this.place}  ·  ${this.mood}  ·  ${this.dateLabel}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(() => this.onTap())
  }
}
