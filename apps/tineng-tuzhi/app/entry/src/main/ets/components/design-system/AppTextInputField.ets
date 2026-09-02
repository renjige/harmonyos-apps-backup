import { Theme } from './Theme'

/**
 * 高对比度文本输入 — 浅色/深色均满足正文 ≥4.5:1（审核 TextInput 拒审修复）。
 * 背景 surfaceSubtle + 描边；正文 textPrimary；占位 textSecondary（禁止系统默认浅灰）。
 */
@Component
export struct AppTextInputField {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop text: string = ''
  @Prop placeholder: string = ''
  @Prop label: string = ''
  @Prop password: boolean = false
  @Prop numeric: boolean = false
  @Prop phone: boolean = false
  @Prop maxLength: number = 512
  @Prop compact: boolean = false
  onChange: (value: string) => void = () => {}

  private inputType(): InputType {
    if (this.password) {
      return InputType.Password
    }
    if (this.phone) {
      return InputType.PhoneNumber
    }
    if (this.numeric) {
      return InputType.Number
    }
    return InputType.Normal
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      if (this.label.length > 0) {
        Text(this.label)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      TextInput({ text: this.text, placeholder: this.placeholder })
        .type(this.inputType())
        .fontSize(this.compact ? Theme.type.bodyS : Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textSecondary)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
        .caretColor(Theme.colors().brandPrimary)
        .maxLength(this.maxLength)
        .height(48)
        .padding({ left: 12, right: 12 })
        .borderRadius(Theme.radius.sm)
        .border({ width: 1, color: Theme.colors().strokeStrong })
        .width('100%')
        .onChange((v: string): void => { this.onChange(v) })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
