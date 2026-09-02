import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct WeekPosterCard {
  @Prop posterTitle: string = ''
  @Prop posterLine: string = ''
  @Prop posterKeep: string = ''
  onCopy: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.hero_warm_desk'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(16)
        Column()
          .width('100%')
          .height(72)
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(45,45,45,0.72)', 1]]
          })
          .borderRadius({ bottomLeft: 16, bottomRight: 16 })
        Column({ space: 4 }) {
          Text('本周生活海报')
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
          Text(this.posterTitle)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .padding({ left: 16, right: 16, bottom: 12 })
      }
      .clip(true)
      .borderRadius(16)

      Text(this.posterLine)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textPrimary)
        .lineHeight(20)
        .width('100%')
      Text(this.posterKeep)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(20)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      AppButton({
        label: '复制本周生活海报',
        variant: 'secondary',
        onTap: (): void => this.onCopy()
      })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(16)
  }
}
