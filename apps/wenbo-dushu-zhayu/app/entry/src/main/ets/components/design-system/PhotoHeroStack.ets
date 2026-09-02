import { Theme } from './Theme'
import { ReadingMedia } from '../../services/ReadingMedia'

/** 摄影 Hero：深色渐变遮罩 + 固定浅色叠字（深浅模式均清晰） */
@Component
export struct PhotoHeroStack {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop coverKey: string = 'book_default'
  @Prop heroHeight: number = 148
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop compactTitle: boolean = false
  @Prop cornerRadius: number = Theme.radius.xl

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(ReadingMedia.coverMedia(this.coverKey))
        .width('100%')
        .height(this.heroHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius(this.cornerRadius)
      Column()
        .width('100%')
        .height(this.heroHeight)
        .linearGradient({
          angle: 180,
          colors: Theme.heroScrimStops()
        })
        .borderRadius(this.cornerRadius)
      if (this.title.length > 0 || this.subtitle.length > 0) {
        Column({ space: 4 }) {
          if (this.title.length > 0) {
            Text(this.title)
              .fontSize(this.compactTitle ? Theme.type.subhead : Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.heroTitleColor())
              .maxLines(2)
              .width('100%')
          }
          if (this.subtitle.length > 0) {
            Text(this.subtitle)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.heroSubtitleColor())
              .maxLines(3)
              .width('100%')
              .lineHeight(18)
          }
        }
        .padding(Theme.space.s4)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
    }
    .width('100%')
  }
}
