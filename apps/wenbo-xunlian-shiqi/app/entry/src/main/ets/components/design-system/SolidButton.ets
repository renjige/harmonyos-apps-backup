import { Theme } from './Theme'

@Component
export struct SolidButton {
  @Prop label: string = ''
  @Prop tone: string = 'primary'
  onTap: () => void = () => {}

  private bg(): string {
    if (this.tone === 'danger') {
      return Theme.colors().danger
    }
    if (this.tone === 'secondary') {
      return Theme.colors().surfaceSubtle
    }
    return Theme.primaryButtonFill()
  }

  private fg(): string {
    if (this.tone === 'secondary') {
      return Theme.colors().textPrimary
    }
    return '#FFFFFF'
  }

  build() {
    Button(this.label)
      .width('100%')
      .height(48)
      .fontSize(Theme.type.body)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.fg())
      .backgroundColor(this.bg())
      .borderRadius(Theme.radius.lg)
      .onClick((): void => { this.onTap() })
  }
}
