import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct ReviewOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State passed: boolean = true
  @State note: string = ''
  @State errorText: string = ''
  onClose: () => void = () => {}
  onSubmit: (passed: boolean, note: string) => void = () => {}

  private submit(): void {
    if (!this.passed && this.note.trim().length === 0) {
      this.errorText = '未通过时请填写复查说明'
      return
    }
    this.errorText = ''
    this.onSubmit(this.passed, this.note.trim())
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('取消').fontSize(15).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).onClick(() => this.onClose())
        Text('进行复查')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('提交').fontSize(15).fontColor(Theme.colors().brandAccent).onClick(() => this.submit())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .padding(10)
          .backgroundColor(Theme.colors().danger)
          .borderRadius(8)
          .margin({ left: 16, right: 16 })
          .width('100%')
      }

      Scroll() {
        Column({ space: 14 }) {
          Text('复查结果')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: 10 }) {
            Column() {
              Text('通过')
                .fontSize(16)
                .fontColor(this.passed ? '#FFFFFF' : '#2D9B70')
            }
            .layoutWeight(1)
            .height(52)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.passed ? '#2D9B70' : '#E8F7F0')
            .borderRadius(14)
            .onClick(() => { this.passed = true })
            Column() {
              Text('未通过')
                .fontSize(16)
                .fontColor(!this.passed ? '#FFFFFF' : '#D94A4A')
            }
            .layoutWeight(1)
            .height(52)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(!this.passed ? '#D94A4A' : '#FDECEC')
            .borderRadius(14)
            .onClick(() => { this.passed = false })
          }
          .width('100%')

          Column({ space: 8 }) {
            Text(this.passed ? '复查说明（选填）' : '复查说明（必填）')
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextArea({
              text: this.note,
              placeholder: this.passed ? '可补充闭环说明' : '例如：警示标识仍未完善'
            })
              .height(110)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .onChange((v: string) => { this.note = v })
          }
          .padding(16)
          .width('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .alignItems(HorizontalAlign.Start)

          AppButton({
            label: this.passed ? '确认闭环' : '退回整改',
            onTap: (): void => { this.submit() }
          })
        }
        .padding({ left: 16, right: 16, bottom: 32 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
