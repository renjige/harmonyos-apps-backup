import { Theme } from '../design-system/Theme'

@Component
export struct TodoAddBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onWipe') wipeSeq: number = 0
  @Prop adding: boolean = false
  @Prop bottomInset: number = 76
  onSubmitText: (text: string) => void = (_text: string) => {}
  @State localText: string = ''
  private pending: boolean = false

  onWipe(): void {
    this.localText = ''
  }

  private fire(): void {
    if (this.pending || this.adding) {
      return
    }
    this.pending = true
    setTimeout((): void => {
      this.pending = false
    }, 700)
    this.onSubmitText(this.localText)
  }

  build() {
    Row({ space: Theme.space.s2 }) {
      TextInput({ text: this.localText, placeholder: '添加今日待办' })
        .layoutWeight(1)
        .height(48)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textTertiary)
        .caretColor(Theme.colors().brandPrimary)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(12)
        .padding({ left: 12, right: 12 })
        .defaultFocus(false)
        .enterKeyType(EnterKeyType.Done)
        .onChange((v: string): void => {
          this.localText = v
        })
        .onSubmit((): void => this.fire())
      Column() {
        Text('添加')
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
      }
      .width(96)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(12)
      .focusable(false)
      .focusOnTouch(false)
      .hitTestBehavior(HitTestMode.Block)
      .gesture(
        TapGesture({ count: 1 })
          .onAction((): void => this.fire())
      )
      .onClick((): void => this.fire())
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      top: Theme.space.s2,
      bottom: this.bottomInset > 0 ? 8 : Theme.space.s4
    })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
