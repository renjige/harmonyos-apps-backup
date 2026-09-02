import { Theme } from '../design-system/Theme'

@Component
export struct HomeHero {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '微观志'
  @Prop subtitle: string = ''

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_ivory_desk'))
        .width('100%')
        .height(148)
        .objectFit(ImageFit.Cover)
      Image($r('app.media.banner_micro'))
        .width('100%')
        .height(148)
        .objectFit(ImageFit.Cover)
        .opacity(0.18)
      Column()
        .width('100%')
        .height(148)
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(26,42,58,0.82)', 1]]
        })
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text(this.subtitle)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .padding(Theme.space.s4)
    }
    .width('100%')
    .height(148)
    .clip(true)
  }
}
