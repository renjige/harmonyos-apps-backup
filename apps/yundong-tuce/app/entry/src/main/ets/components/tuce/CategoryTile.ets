import { Theme } from '../design-system/Theme'
import { TuceMedia } from '../../services/TuceMedia'

@Component
export struct CategoryTile {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop coverKey: string = 'warmup'
  @Prop count: number = 0
  onTap: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(TuceMedia.cover(this.coverKey))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
      Column({ space: 2 }) {
        Text(this.label)
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text(`${this.count} 个动作`)
          .fontSize(Theme.type.overline)
          .fontColor('#FFFFFF')
          .opacity(0.9)
      }
      .width('100%')
      .padding(Theme.space.s3)
      .linearGradient({
        angle: 180,
        colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.75)', 1]]
      })
    }
    .width('100%')
    .height(88)
    .onClick((): void => { this.onTap() })
  }
}
