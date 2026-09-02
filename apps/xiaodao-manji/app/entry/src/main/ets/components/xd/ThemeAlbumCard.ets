import { Theme } from '../design-system/Theme'
import { XdDateUtil, XdTheme } from '../../models/XdModels'
import { XdMedia } from '../../services/XdMedia'

@Component
export struct ThemeAlbumCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop theme: XdTheme = new XdTheme()
  @Prop countLabel: string = '0 条'
  onOpen: () => void = () => {}

  build() {
    Column() {
      Stack() {
        Image(XdMedia.coverOf(this.theme.coverKey))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(48)
          .linearGradient({
            angle: 180,
            colors: [['rgba(47,74,71,0)', 0], ['rgba(47,74,71,0.72)', 1]]
          })
          .align(Alignment.BottomStart)
      }
      .borderRadius({ topLeft: Theme.radius.md, topRight: Theme.radius.md })
      .clip(true)

      Column({ space: 4 }) {
        Text(this.theme.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(1)
          .width('100%')
        Text(`${this.countLabel} · ${XdDateUtil.displayDate(XdDateUtil.keyFromDate(new Date(this.theme.updatedAt)))}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(Theme.space.s3)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { this.onOpen() })
  }
}
