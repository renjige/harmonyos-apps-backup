import { Theme } from '../design-system/Theme'
import { WarmCompanionMedia } from '../../services/WarmCompanionMedia'

@Component
export struct WarmMediaCover {
  @Prop coverKey: string = 'hero_warm_glow'
  @Prop tileSize: number = 72
  @Prop cornerRadius: number = Theme.radius.md

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image(WarmCompanionMedia.resource(this.coverKey))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [['rgba(44,44,44,0)', 0], ['rgba(44,44,44,0.18)', 1]]
        })
    }
    .width(this.tileSize)
    .height(this.tileSize)
    .borderRadius(this.cornerRadius)
    .clip(true)
  }
}

@Component
export struct WarmMediaHero {
  @Prop coverKey: string = 'hero_warm_glow'
  @Prop bannerHeight: number = 200
  @Prop overline: string = ''
  @Prop title: string = ''
  @Prop compact: boolean = false

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(WarmCompanionMedia.resource(this.coverKey))
        .width('100%')
        .height(this.bannerHeight)
        .objectFit(ImageFit.Cover)

      Column()
        .width('100%')
        .height(this.compact ? 100 : 120)
        .linearGradient({
          angle: 180,
          colors: [['rgba(44,44,44,0)', 0], ['rgba(44,44,44,0.88)', 1]]
        })

      if (this.title.length > 0 || this.overline.length > 0) {
        Column({ space: 6 }) {
          if (this.overline.length > 0) {
            Text(this.overline)
              .fontSize(Theme.type.overline)
              .fontColor('#FFE8C8')
          }
          if (this.title.length > 0) {
            Text(this.title)
              .fontSize(this.compact ? Theme.type.title3 : Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
      }
    }
    .width('100%')
    .height(this.bannerHeight)
  }
}
