import { Theme } from '../design-system/Theme'

@Component
export struct EditorialBanner {
  @Prop countLabel: string = '0 件作品'

  @Builder
  BannerFrame(image: Resource, title: string, subtitle: string) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(image)
        .width('100%')
        .height(148)
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height(148)
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0.06)', 0], ['rgba(26,35,50,0.82)', 1]]
        })
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F5F6F8')
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor('#E5E7EB')
      }
      .padding(Theme.space.s4)
    }
    .width('100%')
    .borderRadius(Theme.radius.md)
    .clip(true)
  }

  build() {
    Swiper() {
      this.BannerFrame($r('app.media.hero_studio'), '匠心陈列 · 连接成长', this.countLabel)
      this.BannerFrame($r('app.media.banner_curate'), '精选策展视角', '按分类浏览你的代表作')
    }
    .width('100%')
    .height(148)
    .indicator(true)
    .loop(true)
    .duration(Theme.motion.normal)
  }
}
