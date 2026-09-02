import { Theme } from './Theme'

/** 统一输入框：深色/浅色均显式字色，避免系统控件与主题不同步时看不清 */
@Component
export struct AppTextField {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop text: string = ''
  @Prop placeholder: string = ''
  @Prop multiline: boolean = false
  @Prop fieldHeight: number = 48
  @Prop inputType: InputType = InputType.Normal
  @Prop maxLength: number = 0
  /** 搜索栏等外层已有底色的场景 */
  @Prop transparentBg: boolean = false
  onChange: (value: string) => void = () => {}

  private fillColor(): string {
    if (this.transparentBg) {
      return '#00000000'
    }
    return this.themeEpoch >= 0 ? Theme.inputFill() : Theme.inputFill()
  }

  private strokeColor(): string {
    if (this.transparentBg) {
      return '#00000000'
    }
    return Theme.colorOf(this.themeEpoch).strokeStrong
  }

  @Builder
  singleLineInput() {
    if (this.maxLength > 0) {
      TextInput({ text: this.text, placeholder: this.placeholder })
        .width('100%')
        .height(this.fieldHeight)
        .type(this.inputType)
        .maxLength(this.maxLength)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.inputInk() : Theme.inputInk())
        .placeholderColor(this.themeEpoch >= 0 ? Theme.inputHint() : Theme.inputHint())
        .caretColor(Theme.colorOf(this.themeEpoch).brandPrimary)
        .backgroundColor(this.fillColor())
        .borderRadius(this.transparentBg ? 0 : Theme.radius.sm)
        .border({ width: this.transparentBg ? 0 : 1, color: this.strokeColor() })
        .padding({ left: 12, right: 12 })
        .onChange((v: string): void => { this.onChange(v) })
    } else {
      TextInput({ text: this.text, placeholder: this.placeholder })
        .width('100%')
        .height(this.fieldHeight)
        .type(this.inputType)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.inputInk() : Theme.inputInk())
        .placeholderColor(this.themeEpoch >= 0 ? Theme.inputHint() : Theme.inputHint())
        .caretColor(Theme.colorOf(this.themeEpoch).brandPrimary)
        .backgroundColor(this.fillColor())
        .borderRadius(this.transparentBg ? 0 : Theme.radius.sm)
        .border({ width: this.transparentBg ? 0 : 1, color: this.strokeColor() })
        .padding({ left: 12, right: 12 })
        .onChange((v: string): void => { this.onChange(v) })
    }
  }

  build() {
    Column() {
      if (this.multiline) {
        TextArea({ text: this.text, placeholder: this.placeholder })
          .width('100%')
          .height(this.fieldHeight)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.inputInk() : Theme.inputInk())
          .placeholderColor(this.themeEpoch >= 0 ? Theme.inputHint() : Theme.inputHint())
          .caretColor(Theme.colorOf(this.themeEpoch).brandPrimary)
          .backgroundColor(this.fillColor())
          .borderRadius(this.transparentBg ? 0 : Theme.radius.sm)
          .border({ width: this.transparentBg ? 0 : 1, color: this.strokeColor() })
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .onChange((v: string): void => { this.onChange(v) })
      } else {
        this.singleLineInput()
      }
    }
    .width('100%')
  }
}
