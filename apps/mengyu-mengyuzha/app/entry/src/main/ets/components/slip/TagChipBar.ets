import { Theme } from '../design-system/Theme'

@Component
export struct TagChipBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop choices: string[] = []
  @Prop selectedCsv: string = ''
  onToggle: (tag: string) => void = (_tag: string) => {}

  private isOn(tag: string): boolean {
    const parts = this.selectedCsv.split(',')
    for (const p of parts) {
      if (p.trim() === tag) {
        return true
      }
    }
    return false
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.choices, (tag: string) => {
        Text(tag)
          .fontSize(Theme.type.caption)
          .fontColor(this.isOn(tag) ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .margin({ right: 8, bottom: 8 })
          .backgroundColor(this.isOn(tag) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.onToggle(tag) })
      }, (tag: string) => tag)
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
