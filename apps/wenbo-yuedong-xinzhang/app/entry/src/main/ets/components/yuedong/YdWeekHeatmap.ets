import { Theme } from '../design-system/Theme'
import { YdWeekDayStat } from '../../models/YdModels'

@Component
export struct YdWeekHeatmap {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop days: YdWeekDayStat[] = []

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('近 7 日执行热力')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Row({ space: Theme.space.s2 }) {
        ForEach(this.days, (d: YdWeekDayStat) => {
          Column({ space: 6 }) {
            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width(36)
                .height(36)
                .borderRadius(18)
                .backgroundColor(this.heatColor(d))
              Text(`${d.doneCount}`)
                .fontSize(Theme.type.caption)
                .fontWeight(FontWeight.Medium)
                .fontColor(d.doneCount > 0 ? Theme.colors().brandOnPrimary : Theme.colors().textTertiary)
            }
            Text(d.weekday)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
        }, (d: YdWeekDayStat) => d.dateKey)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  private heatColor(d: YdWeekDayStat): string {
    if (d.totalCount === 0) {
      return Theme.colors().surfaceSubtle
    }
    const p = d.completionPercent()
    if (p >= 100) {
      return Theme.colors().brandPrimary
    }
    if (p >= 50) {
      return Theme.colors().brandPrimaryContainer
    }
    if (d.doneCount > 0) {
      return Theme.colors().info
    }
    return Theme.colors().surfaceSubtle
  }
}
