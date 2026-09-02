import { Theme } from '../design-system/Theme'
import { DayScorePoint } from '../../models/MoodModels'

@Component
export struct MoodCurveChart {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop points: DayScorePoint[] = []
  @Prop chartHeight: number = 160

  private maxScore(): number {
    return 10
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      if (this.points.length === 0) {
        Text('暂无数据')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      } else {
        Row() {
          ForEach(this.points, (p: DayScorePoint) => {
            Column() {
              Blank()
              if (p.score > 0) {
                Column()
                  .width(8)
                  .height(Math.max(8, (p.score / this.maxScore()) * (this.chartHeight - 24)))
                  .backgroundColor(p.color)
                  .borderRadius(4)
              } else {
                Column()
                  .width(6)
                  .height(4)
                  .backgroundColor(Theme.colors().strokeHairline)
                  .borderRadius(2)
              }
              Text(`${p.day}`)
                .fontSize(8)
                .fontColor(Theme.colors().textTertiary)
                .margin({ top: 4 })
            }
            .height(this.chartHeight)
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }, (p: DayScorePoint) => p.dateKey)
        }
        .width('100%')
        .height(this.chartHeight)
      }
    }
    .width('100%')
  }
}
