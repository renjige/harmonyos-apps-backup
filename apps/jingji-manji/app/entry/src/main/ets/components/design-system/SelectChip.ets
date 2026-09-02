import { Theme } from './Theme'

/** 可选 Chip — 选中态高对比（实心主色底 + 白字） */
@Component
export struct SelectChip {
  @Prop label: string = ''
  @Prop active: boolean = false
  onTap: () => void = () => {}

  build() {
    Text(this.label)
      .fontSize(Theme.type.footnote)
      .fontWeight(this.active ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.active ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.active ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .border({
        width: this.active ? 2 : 1,
        color: this.active ? Theme.colors().brandPrimary : Theme.colors().strokeStrong
      })
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.onTap()
      })
  }
}
