import { Theme } from './Theme'

/**
 * 统一输入框样式 — 浅/深模式下文字与占位符均可见（审核 3.1 输入不可见修复）
 */
@Component
export struct AppTextField {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop text: string = ''
  @Prop placeholder: string = ''
  @Prop fieldHeight: number = 48
  @Prop multiline: boolean = false
  @Prop inputType: InputType = InputType.Normal
  onChange: (value: string) => void = (_v: string) => {}

  build() {
    if (this.multiline) {
      TextArea({ text: this.text, placeholder: this.placeholder })
        .height(this.fieldHeight)
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .placeholderColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .onChange((v: string): void => { this.onChange(v) })
    } else {
      TextInput({ text: this.text, placeholder: this.placeholder })
        .type(this.inputType)
        .height(this.fieldHeight)
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .placeholderColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .onChange((v: string): void => { this.onChange(v) })
    }
  }
}
