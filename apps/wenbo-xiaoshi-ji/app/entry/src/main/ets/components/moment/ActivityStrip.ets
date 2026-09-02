import { Theme } from '../design-system/Theme'
import { DayActivity } from '../../models/MomentModels'

@Component
export struct ActivityStrip {
  @Prop @Watch('onDaysChange') days: DayActivity[] = []
  @Prop title: string = '近 7 日活跃'

  onDaysChange(): void {
  }

  private barHeight(count: number, max: number): number {
    if (max <= 0) {
      return 4
    }
    const pct = count / max
    const h = Math.floor(pct * 48)
    if (h < 4) {
      return 4
    }
    return h
  }

  private maxCount(): number {
    let max = 0
    for (const d of this.days) {
      const total = d.noteCount + d.todoDone
      if (total > max) {
        max = total
      }
    }
    if (max === 0) {
      return 1
    }
    return max
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.title)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Row({ space: 6 }) {
        ForEach(this.days, (d: DayActivity) => {
          Column({ space: 4 }) {
            Column()
              .width(18)
              .height(this.barHeight(d.noteCount + d.todoDone, this.maxCount()))
              .backgroundColor(d.noteCount + d.todoDone > 0 ?
                Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(4)
            Text(d.weekday)
              .fontSize(10)
              .fontColor(Theme.colors().textTertiary)
          }
          .layoutWeight(1)
          .height(68)
          .justifyContent(FlexAlign.End)
        }, (d: DayActivity) => d.dateKey)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
      Text('柱高 = 当日随记条数 + 完成待办数')
        .fontSize(10)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(16)
  }
}
