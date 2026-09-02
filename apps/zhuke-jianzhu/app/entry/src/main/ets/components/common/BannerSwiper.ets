import { Theme } from '../design-system/Theme'
import { BannerItem } from '../../models/ZhukeModels'
import { ContentCover } from './ContentCover'

@Component
export struct BannerSwiper {
  @Prop items: BannerItem[] = []

  build() {
    Swiper() {
      ForEach(this.items, (item: BannerItem) => {
        Stack({ alignContent: Alignment.BottomStart }) {
          ContentCover({
            imageKey: item.imageKey,
            coverHeight: 180,
            coverRadius: Theme.radius.lg,
            showGradient: true
          })
          Column({ space: Theme.space.s1 }) {
            Text(item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(item.subtitle)
              .fontSize(Theme.type.callout)
              .fontColor('#FFFFFF')
              .opacity(0.9)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height('100%')
        .borderRadius(Theme.radius.lg)
        .clip(true)
      }, (item: BannerItem) => item.id)
    }
    .width('100%')
    .height(180)
    .autoPlay(true)
    .interval(4000)
    .indicator(
      new DotIndicator()
        .itemWidth(6)
        .itemHeight(6)
        .selectedItemWidth(16)
        .selectedItemHeight(6)
        .color('rgba(255,255,255,0.4)')
        .selectedColor('#FFFFFF')
    )
    .borderRadius(Theme.radius.lg)
    .clip(true)
  }
}
