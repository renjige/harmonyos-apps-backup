import { Theme } from './Theme'

/** 统一单行/多行输入 — 浅深模式下文字、占位符、边框均可见 */
@Component
export struct AppTextField {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop text: string = ''
  @Prop placeholder: string = ''
  @Prop fieldHeight: number = 48
  @Prop fieldWidth: number = 0
  @Prop multiline: boolean = false
  @Prop inputType: InputType = InputType.Normal
  onChange: (value: string) => void = (_v: string) => {}

  build() {
    if (this.multiline) {
      Column() {
        TextArea({ text: this.text, placeholder: this.placeholder })
          .height(this.fieldHeight)
          .width('100%')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .border({ width: 1, color: Theme.colors().strokeStrong })
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
          .onChange((v: string): void => { this.onChange(v) })
      }
      .width(this.fieldWidth > 0 ? this.fieldWidth : '100%')
      .alignItems(HorizontalAlign.Start)
    } else {
      Column() {
        TextInput({ text: this.text, placeholder: this.placeholder })
          .type(this.inputType)
          .height(this.fieldHeight)
          .width('100%')
          .padding({ left: 12, right: 12 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .border({ width: 1, color: Theme.colors().strokeStrong })
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
          .onChange((v: string): void => { this.onChange(v) })
      }
      .width(this.fieldWidth > 0 ? this.fieldWidth : '100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
