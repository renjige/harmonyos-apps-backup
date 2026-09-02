import { Theme } from '../design-system/Theme'
import { KitchenMedia } from './KitchenMedia'

@Component
export struct RecipeCover {
  @Prop coverKey: string = 'tomato_egg_noodles'
  @Prop title: string = ''
  @Prop imageHeight: number = 168
  @Prop rounded: number = Theme.radius.card

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(KitchenMedia.of(this.coverKey))
        .width('100%')
        .height(this.imageHeight)
        .objectFit(ImageFit.Cover)
      Column() {}
        .width('100%')
        .height(this.imageHeight)
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0.00)', 0.42], ['rgba(18,63,50,0.58)', 1]]
        })
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s3, bottom: Theme.space.s4 })
      }
    }
    .width('100%')
    .height(this.imageHeight)
    .clip(true)
    .borderRadius(this.rounded)
  }
}
