import { Theme } from '../design-system/Theme'

@Component
export struct StatTileCard {
  @Prop label: string = ''
  @Prop value: number = 0

  build() {
    Column({ space: 2 }) {
      Text(`${this.value}`)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.sm)
  }
}
