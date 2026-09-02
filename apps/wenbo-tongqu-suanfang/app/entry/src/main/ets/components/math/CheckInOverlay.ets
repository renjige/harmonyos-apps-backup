import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MathBizService } from '../../services/MathBizService'

@Component
export struct CheckInOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State note: string = ''
  @State done: boolean = false
  @State toast: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    const c = MathBizService.todayCheckIn()
    this.done = c !== undefined
    this.note = c !== undefined ? c.note : ''
  }

  private async save(): Promise<void> {
    await MathBizService.saveCheckIn(this.note)
    this.done = true
    this.toast = '今天已记下'
    setTimeout(() => { this.toast = '' }, 2000)
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44).height(44).justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('学习打卡')
          .fontSize(Theme.type.title3).fontWeight(FontWeight.Medium)
          .layoutWeight(1).textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%').padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })

      Column({ space: Theme.space.s4 }) {
        Text(this.done ? '今天已经打过卡了，可以补一句家长备注。' : '记下今天练过。练习完成也会自动记一天。')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        TextInput({ text: this.note, placeholder: '可选：今天口算很专心' })
          .width('100%').height(44)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onChange((v: string) => { this.note = v })
        if (this.toast.length > 0) {
          Text(this.toast)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
        }
        AppButton({
          label: this.done ? '更新备注' : '记下今天',
          onTap: (): void => { void this.save() }
        })
      }
      .padding(Theme.space.s6)
      .width('100%')
      Blank().layoutWeight(1)
    }
    .width('100%').height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
