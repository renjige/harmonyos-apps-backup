import { Theme } from '../design-system/Theme'
import { BannerSlide } from '../../models/InfoModels'
import { WanXiangMedia } from '../../services/WanXiangMedia'

@Component
export struct EditorialBannerSwiper {
  @Prop slides: BannerSlide[] = []
  onTap: (targetId: string) => void = () => {}

  build() {
    Swiper() {
      ForEach(this.slides, (slide: BannerSlide) => {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(WanXiangMedia.coverResource(slide.coverKey))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)

          Column()
            .width('100%')
            .height('100%')
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0.05)', 0], ['rgba(0,0,0,0.78)', 1]]
            })

          Column({ space: 6 }) {
            Text('编辑精选')
              .fontSize(Theme.type.caption)
              .fontColor('#FF9500')
              .fontWeight(FontWeight.Medium)
            Text(slide.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .maxLines(2)
            Text(slide.subtitle)
              .fontSize(Theme.type.footnote)
              .fontColor('#E2E8F0')
              .maxLines(1)
          }
          .padding(18)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height('100%')
        .borderRadius(Theme.radius.lg)
        .clip(true)
        .onClick((): void => this.onTap(slide.targetId))
      }, (slide: BannerSlide) => slide.id)
    }
    .width('100%')
    .height(196)
    .indicator(
      new DotIndicator()
        .selectedColor('#FFFFFF')
        .color('rgba(255,255,255,0.45)')
        .itemWidth(6)
        .itemHeight(6)
    )
    .loop(true)
    .autoPlay(true)
    .interval(4200)
    .curve(Curve.EaseInOut)
  }
}
