import { Theme } from '../components/design-system/Theme'

/** 登录/注册输入框 — 显式字色，避免系统深色模式下 TextInput 默认字色与浅底冲突 */
@Component
export struct AppAuthField {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop value: string = ''
  @Prop placeholder: string = ''
  @Prop fieldType: InputType = InputType.Normal
  @Prop maxLen: number = 256
  onChange: (value: string) => void = () => {}

  build() {
    TextInput({ text: this.value, placeholder: this.placeholder })
      .type(this.fieldType)
      .maxLength(this.maxLen)
      .height(48)
      .padding({ left: 12, right: 12 })
      .fontSize(Theme.type.body)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .placeholderColor(this.themeEpoch >= 0 ? Theme.colors().textTertiary : Theme.colors().textTertiary)
      .caretColor(Theme.colors().brandPrimary)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.sm)
      .border({ width: 1, color: Theme.colors().strokeStrong })
      .onChange((v: string): void => { this.onChange(v) })
  }
}
