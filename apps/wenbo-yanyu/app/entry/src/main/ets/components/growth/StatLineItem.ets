import { Theme } from '../design-system/Theme'

/** 知识统计单行 — 独立组件避免 @Builder 参数不刷新 */
@Component
export struct StatLineItem {
  @Prop label: string = ''
  @Prop valueText: string = '0'
  @StorageLink('darkModeOn') darkModeOn: boolean = false

  build() {
    Row() {
      Text(this.label)
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.of(this.darkModeOn).textPrimary)
        .layoutWeight(1)
      Text(this.valueText)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.of(this.darkModeOn).brandPrimary)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
  }
}
