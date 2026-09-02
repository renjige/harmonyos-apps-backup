import { Theme } from './Theme'

/** 主题感知单行输入 — 深色模式显式字色/占位色，避免系统默认黑字不可见 */
@Component
export struct AppTextField {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop text: string = ''
  @Prop placeholder: string = ''
  @Prop fieldHeight: number = 48
  @Prop inputKind: string = 'normal'
  @Prop maxLen: number = 500
  @Prop pill: boolean = false
  onChange: (value: string) => void = () => {}

  private inputType(): InputType {
    if (this.inputKind === 'password') {
      return InputType.Password
    }
    if (this.inputKind === 'phone') {
      return InputType.PhoneNumber
    }
    return InputType.Normal
  }

  build() {
    TextInput({ text: this.text, placeholder: this.placeholder })
      .type(this.inputType())
      .maxLength(this.maxLen)
      .height(this.fieldHeight)
      .padding({ left: 12, right: 12 })
      .fontColor(Theme.colors().textPrimary)
      .placeholderColor(Theme.colors().textSecondary)
      .caretColor(Theme.colors().brandPrimary)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(this.pill ? Theme.radius.pill : Theme.radius.sm)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onChange((value: string) => {
        this.onChange(value)
      })
  }
}

@Component
export struct AppTextAreaField {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop text: string = ''
  @Prop placeholder: string = ''
  @Prop areaHeight: number = 160
  onChange: (value: string) => void = () => {}

  build() {
    TextArea({ text: this.text, placeholder: this.placeholder })
      .height(this.areaHeight)
      .fontColor(Theme.colors().textPrimary)
      .placeholderColor(Theme.colors().textSecondary)
      .caretColor(Theme.colors().brandPrimary)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.sm)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onChange((value: string) => {
        this.onChange(value)
      })
  }
}
