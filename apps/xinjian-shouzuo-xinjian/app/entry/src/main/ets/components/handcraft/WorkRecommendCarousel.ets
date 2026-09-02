import { Theme } from '../design-system/Theme'
import { HandcraftWork } from '../../models/HandcraftModels'
import { CraftMedia } from '../../services/CraftMedia'

/** 首页推荐作品 — 自动轮播卡片 */
@Component
export struct WorkRecommendCarousel {
  @Prop works: HandcraftWork[] = []
  onTapWork: (workId: string) => void = () => {}

  build() {
    Swiper() {
      ForEach(this.works, (w: HandcraftWork) => {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(CraftMedia.byKey(w.coverKey))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height('100%')
            .linearGradient({
              angle: 180,
              colors: [['rgba(42,37,35,0.15)', 0], ['rgba(42,37,35,0.88)', 1]]
            })
          Column({ space: 6 }) {
            Text(w.category)
              .fontSize(Theme.type.caption)
              .fontColor('#FAF7F2')
              .padding({ left: 10, right: 10, top: 3, bottom: 3 })
              .backgroundColor('#2A2724')
              .borderRadius(Theme.radius.pill)
            Text(w.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FAF7F2')
              .maxLines(2)
            Text(w.summary)
              .fontSize(Theme.type.footnote)
              .fontColor('#FAF7F2')
              .maxLines(2)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height('100%')
        .borderRadius(Theme.radius.xl)
        .clip(true)
        .onClick((): void => { this.onTapWork(w.id) })
      }, (w: HandcraftWork) => `carousel_${w.id}`)
    }
    .width('100%')
    .autoPlay(true)
    .interval(3500)
    .loop(true)
    .indicator(
      new DotIndicator()
        .itemWidth(6)
        .itemHeight(6)
        .selectedItemWidth(18)
        .selectedItemHeight(6)
        .color('rgba(255,255,255,0.45)')
        .selectedColor('#FFFFFF')
    )
    .borderRadius(Theme.radius.xl)
    .clip(true)
    .height(220)
  }
}
