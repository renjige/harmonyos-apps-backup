import { Theme } from './Theme'

/** 统一 TextInput：关闭系统 AutoFill，避免模拟器 libhint2type 报错 */
@Component
export struct AppTextInput {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop text: string = ''
  @Prop placeholder: string = ''
  @Prop inputType: InputType = InputType.Normal
  @Prop maxLength: number = 256
  onChange: (value: string) => void = () => {}

  build() {
    TextInput({
      text: this.text,
      placeholder: this.placeholder
    })
      .type(this.inputType)
      .maxLength(this.maxLength)
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.sm)
      .enableAutoFill(false)
      .onChange((value: string) => {
        this.onChange(value)
      })
  }
}
