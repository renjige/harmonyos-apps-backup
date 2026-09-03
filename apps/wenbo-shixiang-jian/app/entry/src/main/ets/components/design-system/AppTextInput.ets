import { Theme } from './Theme'
import { SketchStyle } from './SketchStyle'

/** 统一 TextInput：手绘边框 + 便签底 */
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
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.sketchRadius())
      .border({ width: 2, color: SketchStyle.borderInk() })
      .fontColor(Theme.colors().textPrimary)
      .placeholderColor(Theme.colors().textTertiary)
      .enableAutoFill(false)
      .onChange((value: string) => {
        this.onChange(value)
      })
  }
}
