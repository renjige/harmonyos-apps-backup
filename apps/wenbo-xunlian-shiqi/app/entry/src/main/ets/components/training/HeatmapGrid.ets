import { Theme } from '../design-system/Theme'
import { HeatmapCell } from '../../models/TrainingModels'

@Component
export struct HeatmapGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop cells: HeatmapCell[] = []
  @Prop year: number = 2026
  @Prop month: number = 8

  private levelColor(level: number): string {
    if (level === 0) {
      return Theme.colors().surfaceSubtle
    }
    if (level === 1) {
      return 'rgba(0,122,255,0.25)'
    }
    if (level === 2) {
      return 'rgba(0,122,255,0.45)'
    }
    if (level === 3) {
      return 'rgba(0,122,255,0.65)'
    }
    return '#007AFF'
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text(`${this.year} 年 ${this.month} 月训练热力`)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.cells, (cell: HeatmapCell) => {
          Column({ space: 2 }) {
            Row()
              .width(14)
              .height(14)
              .borderRadius(4)
              .backgroundColor(this.levelColor(cell.level))
          }
          .width('6.5%')
          .margin({ bottom: 6 })
        }, (cell: HeatmapCell) => cell.dateKey)
      }
      .width('100%')

      Row({ space: Theme.space.s2 }) {
        Text('少')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
        Row()
          .width(12)
          .height(12)
          .borderRadius(3)
          .backgroundColor(Theme.colors().surfaceSubtle)
        Row()
          .width(12)
          .height(12)
          .borderRadius(3)
          .backgroundColor('rgba(0,122,255,0.45)')
        Row()
          .width(12)
          .height(12)
          .borderRadius(3)
          .backgroundColor('#007AFF')
        Text('多')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
