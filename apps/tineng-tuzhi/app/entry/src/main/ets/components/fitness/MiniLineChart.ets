import { Theme } from '../design-system/Theme'
import { TrendPoint } from '../../models/WorkoutModels'

@Component
export struct MiniLineChart {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop points: TrendPoint[] = []
  @Prop chartHeight: number = 80

  private maxValue(): number {
    let max = 1
    for (const p of this.points) {
      if (p.value > max) {
        max = p.value
      }
    }
    return max
  }

  private hasMinutes(): boolean {
    for (const p of this.points) {
      if (p.value > 0) {
        return true
      }
    }
    return false
  }

  private barHeight(value: number): number {
    const max = this.maxValue()
    if (max <= 0 || isNaN(value) || isNaN(max)) {
      return 6
    }
    const ratio = value / max
    const usable = this.chartHeight - 28
    const h = Math.round(usable * ratio)
    if (h < 6 || isNaN(h)) {
      return 6
    }
    return h
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      if (this.points.length === 0) {
        Text('暂无趋势数据')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.points, (p: TrendPoint) => {
            Column({ space: 6 }) {
              Column()
                .width('100%')
                .height(this.barHeight(p.value))
                .backgroundColor(p.value > 0 ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.xs)
              Text(p.label)
                .fontSize(10)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Clip })
            }
            .layoutWeight(1)
            .height(this.chartHeight)
            .justifyContent(FlexAlign.End)
            .alignItems(HorizontalAlign.Center)
          }, (p: TrendPoint) => p.dateKey)
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
        if (!this.hasMinutes()) {
          Text('记下训练后，各周柱子会升高')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
        }
      }
    }
    .width('100%')
  }
}
