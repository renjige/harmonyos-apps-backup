import { Theme } from '../design-system/Theme'

/** 单格统计 — 用 @Prop 子组件保证数字随父级 @State 刷新（避免 @Builder 传参卡 0） */
@Component
export struct ObserveStatTile {
  @Prop value: number = 0
  @Prop label: string = ''
  @Prop fontScale: number = 1
  @Prop compact: boolean = false

  build() {
    Column({ space: this.compact ? 2 : 4 }) {
      Text(`${this.value}`)
        .fontSize((this.compact ? Theme.type.title3 : Theme.type.title2) * this.fontScale)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(this.label)
        .fontSize(Theme.type.caption * this.fontScale)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(this.compact ? { top: 10, bottom: 10 } : Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
