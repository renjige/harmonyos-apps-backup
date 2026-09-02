import { Theme } from '../design-system/Theme'
import { SenseCount, DayCount } from '../../models/GrowthModels'

@Component
export struct SenseWeekCharts {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop senseRows: SenseCount[] = []
  @Prop weekRows: DayCount[] = []

  private senseMax(): number {
    let m = 1
    for (const it of this.senseRows) {
      if (it.count > m) {
        m = it.count
      }
    }
    return m
  }

  private weekMax(): number {
    let m = 1
    for (const it of this.weekRows) {
      if (it.count > m) {
        m = it.count
      }
    }
    return m
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Text('五感分布')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.senseRows, (item: SenseCount) => {
        Row({ space: 8 }) {
          Text(item.label)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width(36)
          Stack({ alignContent: Alignment.Start }) {
            Column()
              .width('100%')
              .height(10)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
            Column()
              .width(`${Math.round(item.count * 100 / this.senseMax())}%`)
              .height(10)
              .backgroundColor('#1A2A3A')
              .borderRadius(Theme.radius.pill)
          }
          .layoutWeight(1)
          .height(10)
          Text(`${item.count}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width(24)
        }
        .width('100%')
      }, (item: SenseCount) => item.key)

      Text('近 7 日篇数')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: 4 }) {
        ForEach(this.weekRows, (item: DayCount) => {
          Column({ space: 4 }) {
            Column()
              .width('100%')
              .height(8 + 72 * item.count / this.weekMax())
              .backgroundColor('#C9A96E')
              .borderRadius(Theme.radius.xs)
            Text(item.label)
              .fontSize(9)
              .fontColor(Theme.colors().textTertiary)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)
          .height(110)
        }, (item: DayCount) => item.label)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
