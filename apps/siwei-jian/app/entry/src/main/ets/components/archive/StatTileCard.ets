import { Theme } from '../design-system/Theme'

/** 用 @Prop 组件替代 @Builder，避免父页 @State 变化时数字不重绘 */
@Component
export struct StatTileCard {
  @Prop label: string = ''
  @Prop value: number = 0
  @Prop large: boolean = false

  build() {
    Column({ space: 4 }) {
      Text(`${this.value}`)
        .fontSize(this.large ? Theme.type.title1 : Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
