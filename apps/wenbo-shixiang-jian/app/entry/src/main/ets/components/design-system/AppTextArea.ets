import { Theme } from './Theme'
import { SketchStyle } from './SketchStyle'

/** 多行输入：便签式手绘边框 */
@Component
export struct AppTextArea {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop text: string = ''
  @Prop placeholder: string = ''
  @Prop maxLength: number = 500
  onChange: (value: string) => void = () => {}

  build() {
    TextArea({
      text: this.text,
      placeholder: this.placeholder
    })
      .maxLength(this.maxLength)
      .width('100%')
      .height(120)
      .padding(12)
      .backgroundColor(Theme.colors().stickyYellow)
      .borderRadius(Theme.sketchRadius())
      .border({ width: 2, color: SketchStyle.borderInk() })
      .fontSize(Theme.type.body)
      .fontColor(Theme.colors().textPrimary)
      .placeholderColor(Theme.colors().textTertiary)
      .enableAutoFill(false)
      .onChange((value: string) => {
        this.onChange(value)
      })
  }
}
