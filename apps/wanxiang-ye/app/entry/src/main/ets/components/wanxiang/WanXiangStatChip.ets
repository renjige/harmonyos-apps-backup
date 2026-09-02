import { Theme } from '../design-system/Theme'
import { WanXiangGradients } from '../../services/WanXiangGradients'

@Component
export struct WanXiangStatChip {
  @Prop label: string = ''
  @Prop value: string = ''
  @Prop accent: boolean = false

  build() {
    Column({ space: 4 }) {
      Text(this.value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.accent ? WanXiangGradients.statChipAccentFg() : WanXiangGradients.statChipFg())
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(WanXiangGradients.statChipFg())
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor(WanXiangGradients.statChipBg())
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }
}
