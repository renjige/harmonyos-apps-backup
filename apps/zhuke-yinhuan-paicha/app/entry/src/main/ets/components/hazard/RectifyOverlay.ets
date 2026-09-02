import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'

@Component
export struct RectifyOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State note: string = ''
  @State worker: string = ''
  @State doneAt: string = ''
  @State errorText: string = ''
  onClose: () => void = () => {}
  onSubmit: (note: string, worker: string, doneAt: string) => void = () => {}

  private submit(): void {
    if (this.note.trim().length === 0) {
      this.errorText = '请填写整改说明'
      return
    }
    this.errorText = ''
    this.onSubmit(this.note.trim(), this.worker.trim(), this.doneAt)
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('取消').fontSize(15).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).onClick(() => this.onClose())
        Text('记录整改')
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
          Column({ space: 8 }) {
            Text('整改说明').fontSize(13).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
            TextArea({ text: this.note, placeholder: '请输入本次整改情况' })
              .height(120)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .onChange((v: string) => { this.note = v })
          }
          .padding(16)
          .width('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .alignItems(HorizontalAlign.Start)

          Column({ space: 8 }) {
            AppDatePickerField({
              label: '整改时间',
              value: this.doneAt,
              placeholder: '请选择日期',
              minDaysFromToday: -7,
              maxDaysFromToday: 0,
              onChange: (v: string) => { this.doneAt = v }
            })
            Text('整改人员').fontSize(13).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
            TextInput({ text: this.worker, placeholder: '请输入整改人员' })
              .height(42)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .onChange((v: string) => { this.worker = v })
          }
          .padding(16)
          .width('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .alignItems(HorizontalAlign.Start)

          AppButton({ label: '提交整改', onTap: (): void => { this.submit() } })
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
