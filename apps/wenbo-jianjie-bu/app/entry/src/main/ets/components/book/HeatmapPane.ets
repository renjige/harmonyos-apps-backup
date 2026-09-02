import { Theme } from '../design-system/Theme'
import { HeatDay } from '../../models/InsightModels'

@Component
export struct HeatmapPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop days: HeatDay[] = []
  onPick: (dateKey: string) => void = (_k: string) => {}

  private cellColor(count: number): string {
    if (count <= 0) {
      return Theme.colors().surfaceSubtle
    }
    if (count === 1) {
      return '#C4B5FD'
    }
    if (count === 2) {
      return '#8B7CF7'
    }
    return Theme.colors().brandDeep
  }

  build() {
    Column({ space: 8 }) {
      Text('近 28 天书写热力')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.days, (d: HeatDay) => {
          Column() {
            Column()
              .width(18)
              .height(18)
              .borderRadius(4)
              .backgroundColor(this.cellColor(d.count))
          }
          .width(22)
          .height(22)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onPick(d.dateKey) })
        }, (d: HeatDay) => d.dateKey)
      }
      .width('100%')
      Text('格子越深，当天写下的见解越多。点格子可回看当日。')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
