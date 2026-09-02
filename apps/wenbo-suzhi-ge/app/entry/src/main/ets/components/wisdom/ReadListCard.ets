import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { WisdomMedia } from '../../services/WisdomMedia'

@Component
export struct ReadListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop category: string = ''
  @Prop readMinutes: number = 0
  @Prop coverKey: string = 'cover_reading'
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(WisdomMedia.resource(this.coverKey))
        .width(80)
        .height(80)
        .borderRadius(Theme.radius.sm)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
        Text(this.summary)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
        Text(`${this.category} · ${this.readMinutes} 分钟`)
          .fontSize(Theme.type.overline)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick((): void => { this.onOpen() })
  }
}
