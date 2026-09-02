import { Theme } from '../design-system/Theme'

@Component
export struct TagChipRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop namesCsv: string = ''
  @Prop selectedCsv: string = ''
  @Prop chipEpoch: number = 0
  onToggle: (name: string) => void = (_name: string) => {}

  private names(): string[] {
    const out: string[] = []
    const parts = this.namesCsv.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private isOn(name: string): boolean {
    const parts = this.selectedCsv.split(',')
    for (const p of parts) {
      if (p.trim() === name) {
        return true
      }
    }
    return false
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.names(), (name: string) => {
        Text(name)
          .fontSize(Theme.type.caption)
          .fontColor(this.isOn(name) ? Theme.colors().brandOnPrimary : Theme.colors().labelOnContainer)
          .padding({ left: 12, right: 12, top: 7, bottom: 7 })
          .margin({ right: 8, bottom: 8 })
          .backgroundColor(this.isOn(name) ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .border({
            width: 1,
            color: this.isOn(name) ? Theme.colors().brandPrimary : Theme.colors().strokeStrong
          })
          .onClick((): void => { this.onToggle(name) })
      }, (name: string) => `${this.chipEpoch}|${name}`)
    }
    .width('100%')
  }
}
