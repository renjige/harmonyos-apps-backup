import { Theme } from '../design-system/Theme'
import { EmotionPoint } from '../../services/InsightService'

@Component
export struct EmotionChart {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop points: EmotionPoint[] = []

  private maxVal(): number {
    let m = 1
    for (const p of this.points) {
      if (p.value > m) {
        m = p.value
      }
    }
    return m
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      ForEach(this.points, (p: EmotionPoint) => {
          Row({ space: Theme.space.s2 }) {
          Text(p.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width(48)
          Row()
            .layoutWeight(Math.max(1, p.value))
            .height(10)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
          Row()
            .layoutWeight(Math.max(1, this.maxVal() - p.value))
            .height(10)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
          Text(`${p.value}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width(24)
            .textAlign(TextAlign.End)
        }
        .width('100%')
      }, (p: EmotionPoint) => p.label)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
