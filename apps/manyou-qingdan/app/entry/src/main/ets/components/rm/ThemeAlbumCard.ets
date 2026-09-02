import { Theme } from '../design-system/Theme'
import { RmDateUtil, RmTheme } from '../../models/RmModels'
import { RmMedia } from '../../services/RmMedia'

@Component
export struct ThemeAlbumCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop theme: RmTheme = new RmTheme()
  @Prop countLabel: string = '0 条'
  onOpen: () => void = () => {}

  private imageId(): string {
    return `${this.theme.id}_${this.theme.coverKey}_${this.theme.updatedAt}`
  }

  build() {
    Column() {
      Stack() {
        Image(RmMedia.coverOf(this.theme.coverKey))
          .id(this.imageId())
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
        Text(`${this.countLabel} · ${RmDateUtil.displayDate(RmDateUtil.keyFromDate(new Date(this.theme.updatedAt)))}`)
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
