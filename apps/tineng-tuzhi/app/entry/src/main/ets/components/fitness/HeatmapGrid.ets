import { Theme } from '../design-system/Theme'
import { HeatmapCell } from '../../models/WorkoutModels'

@Component
export struct HeatmapGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop cells: HeatmapCell[] = []
  @Prop monthLabel: string = ''
  onCellTap: (dateKey: string) => void = () => {}

  private levelColor(level: number): string {
    if (level === 0) {
      return Theme.colors().surfaceSubtle
    }
    if (level === 1) {
      return '#FFD4C2'
    }
    if (level === 2) {
      return '#FFB088'
    }
    if (level === 3) {
      return '#FF8A5C'
    }
    return Theme.colors().brandPrimary
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      if (this.monthLabel.length > 0) {
        Text(this.monthLabel)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.cells, (cell: HeatmapCell) => {
          Column() {
            Text(`${cell.dayOfMonth}`)
              .fontSize(9)
              .fontColor(cell.level > 0 ? Theme.colors().brandOnPrimary : Theme.colors().textTertiary)
          }
          .width(36)
          .height(36)
          .margin(2)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.levelColor(cell.level))
          .borderRadius(Theme.radius.xs)
          .onClick((): void => {
            if (cell.dateKey.length >= 8) {
              this.onCellTap(cell.dateKey)
            }
          })
        }, (cell: HeatmapCell) => cell.dateKey)
      }
      .width('100%')
    }
    .width('100%')
  }
}
