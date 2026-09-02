import { Theme } from '../design-system/Theme'
import { ReadingMedia } from '../../services/ReadingMedia'

/** 两列书架网格卡片 */
@Component
export struct BookGridCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop author: string = ''
  @Prop coverKey: string = 'book_default'
  @Prop progressLabel: string = ''
  @Prop statusLabel: string = ''
  onTap: () => void = () => {}
  onLongPress: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(ReadingMedia.coverMedia(this.coverKey))
          .width('100%')
          .height(128)
          .borderRadius(Theme.radius.lg)
          .objectFit(ImageFit.Cover)
        if (this.statusLabel.length > 0) {
          Text(this.statusLabel)
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().brandAccent)
            .borderRadius(Theme.radius.pill)
            .margin(8)
        }
      }
      .width('100%')
      Text(this.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(2)
        .width('100%')
      Text(this.author)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(1)
        .width('100%')
      if (this.progressLabel.length > 0) {
        Text(this.progressLabel)
          .fontSize(Theme.type.overline)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 8, color: 'rgba(26,42,58,0.06)', offsetY: 2 })
    .onClick((): void => { this.onTap() })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction((): void => { this.onLongPress() })
    )
  }
}
