import { Theme } from '../design-system/Theme'

@Component
export struct DimensionSummaryChips {
  @Prop exerciseLabel: string = ''
  @Prop moodLabel: string = ''
  @Prop energyLabel: string = ''

  build() {
    Row({ space: Theme.space.s2 }) {
      this.chip('运动', this.exerciseLabel)
      this.chip('心情', this.moodLabel)
      this.chip('精力', this.energyLabel)
    }
    .width('100%')
  }

  @Builder
  chip(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
      Text(value)
        .fontSize(Theme.type.bodyS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .padding({ top: Theme.space.s3, bottom: Theme.space.s3 })
    .backgroundColor(Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }
}
