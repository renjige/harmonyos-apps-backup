import { Theme } from '../design-system/Theme'
import { SportVisual } from './SportVisual'

@Component
export struct MixProgressBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop sportType: string = ''
  @Prop sessions: number = 0
  @Prop percent: number = 0

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text(this.sportType)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text(`${this.sessions} 次 · ${this.percent}%`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')

      Stack({ alignContent: Alignment.Start }) {
        Column()
          .width('100%')
          .height(8)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
        Column()
          .width(`${Math.max(4, this.percent)}%`)
          .height(8)
          .linearGradient({
            angle: 90,
            colors: [
              [SportVisual.accentHex(this.sportType), 0.0],
              [Theme.colors().brandPrimary, 1.0]
            ]
          })
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')
    }
    .width('100%')
  }
}
