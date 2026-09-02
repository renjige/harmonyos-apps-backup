import { Theme } from '../design-system/Theme'

@Component
export struct ChoiceChip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop active: boolean = false
  onPick: () => void = () => {}

  build() {
    Text(this.label)
      .fontSize(Theme.type.caption)
      .fontWeight(this.active ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.active ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.active ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.sm)
      .onClick(() => this.onPick())
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
