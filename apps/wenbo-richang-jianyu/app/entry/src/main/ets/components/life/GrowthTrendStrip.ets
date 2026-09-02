import { Theme } from '../design-system/Theme'
import { DayCount } from '../../models/LifeHubModels'

@Component
export struct GrowthTrendStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop trend: DayCount[] = []

  private barHeight(count: number): number {
    const h = 12 + count * 18
    if (h > 72) {
      return 72
    }
    return h
  }

  private dayLabel(iso: string): string {
    if (iso.length < 10) {
      return ''
    }
    return iso.substring(8, 10)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('近七日记录趋势')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: 8 }) {
        ForEach(this.trend, (row: DayCount) => {
          Column({ space: 4 }) {
            Column()
              .width(18)
              .height(this.barHeight(row.count))
              .backgroundColor(row.count > 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.sm)
            Text(this.dayLabel(row.iso))
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.End)
          .height(96)
        }, (row: DayCount) => row.iso)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
  }
}
