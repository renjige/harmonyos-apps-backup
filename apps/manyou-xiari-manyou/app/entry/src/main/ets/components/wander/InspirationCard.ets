import { Theme } from '../design-system/Theme'
import { WanderMedia } from '../../services/WanderMedia'

@Component
export struct InspirationCard {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop coverKey: string = ''
  @Prop cardWidth: number = 220
  onTap: () => void = () => {}

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(WanderMedia.resource(this.coverKey))
          .width(this.cardWidth)
          .height(260)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(120)
          .linearGradient({
            angle: 180,
            colors: [['rgba(36,53,43,0)', 0.0], ['rgba(36,53,43,0.72)', 1.0]]
          })
        Column({ space: 4 }) {
          Text(this.subtitle)
            .fontSize(Theme.type.caption)
            .fontColor('#F6F1E8')
          Text(this.title)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F6F1E8')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .padding(16)
        .alignItems(HorizontalAlign.Start)
      }
      .width(this.cardWidth)
      .height(260)
      .borderRadius(Theme.radius.lg)
      .clip(true)
    }
    .onClick(() => this.onTap())
  }
}
