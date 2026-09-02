import { Theme } from './Theme'

@Component
export struct AppStatCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop value: string = ''
  @Prop trend: string = ''
  @Prop positive: boolean = true
  @Prop accent: boolean = false

  build() {
    Column({ space: Theme.space.s1 }) {
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(this.value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.accent ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
      if (this.trend.length > 0) {
        Text(this.trend)
          .fontSize(Theme.type.footnote)
          .fontColor(this.positive ? Theme.colors().success : Theme.colors().danger)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct AppMetricTile {
  @Prop label: string = ''
  @Prop value: string = ''
  @Prop showDivider: boolean = false

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.value)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.label)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      if (this.showDivider) {
        Divider()
          .vertical(true)
          .height(36)
          .color(Theme.colors().strokeHairline)
      }
    }
    .layoutWeight(1)
  }
}
