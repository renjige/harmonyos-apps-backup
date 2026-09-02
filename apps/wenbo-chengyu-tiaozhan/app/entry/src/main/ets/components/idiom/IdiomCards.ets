import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { IdiomMedia } from '../../services/IdiomMedia'

@Component
export struct CoverHero {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop coverKey: string = 'hero_ink'
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop heroHeight: number = 220

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(IdiomMedia.cover(this.coverKey))
        .width('100%')
        .height(this.heroHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
      Column()
        .width('100%')
        .height(110)
        .linearGradient({
          angle: 180,
          colors: [['rgba(12,10,8,0)', 0], ['rgba(12,10,8,0.78)', 1]]
        })
        .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F5F0E8')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(13)
            .fontColor('#F0E8DC')
        }
      }
      .padding({ left: 16, right: 16, bottom: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(this.heroHeight)
  }
}

@Component
export struct IdiomListCard {
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop meta: string = ''
  @Prop coverKey: string = 'cat_intro'
  onTap: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      Image(IdiomMedia.cover(this.coverKey))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
        Text(this.summary)
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
        Text(this.meta)
          .fontSize(12)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Theme.colors().surfaceGlass)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
