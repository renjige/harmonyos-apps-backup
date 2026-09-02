import { Theme } from './Theme'

/** 多行输入：关闭 AutoFill，用于事项说明等 */
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
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.sm)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .fontSize(Theme.type.body)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .placeholderColor(Theme.colors().textTertiary)
      .enableAutoFill(false)
      .onChange((value: string) => {
        this.onChange(value)
      })
  }
}
