import { Theme } from '../design-system/Theme'

/** 成长/我的 — 指标卡片（@Prop 驱动，避免 @Builder 不刷新） */
@Component
export struct YdMetricTile {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop value: string = '0'
  @Prop label: string = ''

  build() {
    Column({ space: 4 }) {
      Text(this.value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(this.label)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }
}
