import { Theme } from '../design-system/Theme'
import { MixBar } from '../../models/WorkoutModels'

@Component
export struct MixBarChart {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: MixBar[] = []

  private barWidth(ratio: number): number {
    let r = ratio
    if (isNaN(r) || r < 0) {
      r = 0
    }
    if (r > 1) {
      r = 1
    }
    const w = Math.round(r * 220)
    if (w < 8) {
      return 8
    }
    return w
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('运动配比')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.items.length === 0) {
        Text('本周还没有配比数据')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.items, (bar: MixBar) => {
          Column({ space: 4 }) {
            Row() {
              Text(bar.label)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textPrimary)
              Blank()
              Text(`${bar.minutes} 分钟`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .width('100%')
            Row() {
              Row()
                .width(this.barWidth(bar.ratio))
                .height(8)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.xs)
            }
            .width('100%')
            .height(8)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.xs)
          }
          .width('100%')
        }, (bar: MixBar) => bar.typeKey)
        Row() {
          ForEach(this.items, (bar: MixBar) => {
            Row()
              .width(this.barWidth(bar.ratio))
              .height(16)
              .backgroundColor(this.sliceColor(bar.typeKey))
          }, (bar: MixBar) => `pie-${bar.typeKey}`)
        }
        .width('100%')
        .height(16)
        .borderRadius(Theme.radius.xs)
        .clip(true)
      }
    }
    .width('100%')
  }

  private sliceColor(typeKey: string): string {
    if (typeKey === 'strength' || typeKey === 'gym') {
      return '#FF6B35'
    }
    if (typeKey === 'yoga' || typeKey === 'stretch' || typeKey === 'recover') {
      return '#2A9D8F'
    }
    if (typeKey === 'running' || typeKey === 'ride') {
      return '#1A2332'
    }
    return '#FF9F76'
  }
}
