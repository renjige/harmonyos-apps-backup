import { Theme } from './Theme'

/** 统一输入框：深色模式高对比字色 + 可见边框 */
@Component
export struct AppTextField {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop text: string = ''
  @Prop placeholder: string = ''
  @Prop multiline: boolean = false
  @Prop fieldHeight: number = 48
  onChange: (value: string) => void = () => {}

  build() {
    Column() {
      if (this.multiline) {
        TextArea({ text: this.text, placeholder: this.placeholder })
          .width('100%')
          .height(this.fieldHeight)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
          .caretColor(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceInput)
          .borderRadius(Theme.radius.sm)
          .border({ width: 1, color: Theme.colors().strokeStrong })
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .onChange((v: string) => { this.onChange(v) })
      } else {
        TextInput({ text: this.text, placeholder: this.placeholder })
          .width('100%')
          .height(this.fieldHeight)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
          .caretColor(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceInput)
          .borderRadius(Theme.radius.sm)
          .border({ width: 1, color: Theme.colors().strokeStrong })
          .padding({ left: 12, right: 12 })
          .onChange((v: string) => { this.onChange(v) })
      }
    }
    .width('100%')
  }
}
