import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct TodayHeroSection {
  @Prop greetingLine: string = ''
  @Prop dateLabel: string = ''
  @Prop quote: string = ''
  @Prop streak: number = 0

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_ambient'))
        .width('100%')
        .height(200)
        .objectFit(ImageFit.Cover)

      Column()
        .width('100%')
        .height(200)
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(26,42,58,0.12)', 0.0],
            ['rgba(26,42,58,0.48)', 0.45],
            ['rgba(26,42,58,0.92)', 1.0]
          ]
        })

      Column({ space: Theme.space.s3 }) {
        Row() {
          Column({ space: 4 }) {
            Text(this.greetingLine)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.dateLabel)
              .fontSize(Theme.type.bodyS)
              .fontColor('rgba(255,255,255,0.88)')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          if (this.streak > 0) {
            Row({ space: 6 }) {
              AppIcon({ name: 'refresh', iconSize: 14, color: '#FFFFFF' })
              Text(`${this.streak} 天`)
                .fontSize(Theme.type.caption)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor('rgba(255,107,53,0.94)')
            .borderRadius(Theme.radius.pill)
            .shadow({
              radius: 12,
              color: 'rgba(255,107,53,0.35)',
              offsetX: 0,
              offsetY: 4
            })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Text(this.quote)
          .fontSize(Theme.type.body)
          .fontColor('#FFFFFF')
          .lineHeight(22)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s5,
        top: Theme.space.s6
      })
    }
    .width('100%')
    .clip(true)
  }
}
