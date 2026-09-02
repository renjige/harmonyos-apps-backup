import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { ParentGateService } from '../../services/ParentGateService'

@Component
export struct ParentGateOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onPass: () => void = () => {}
  onClose: () => void = () => {}
  @State answer: string = ''
  @State errorText: string = ''

  aboutToAppear(): void {
    ParentGateService.refresh()
    this.answer = ''
    this.errorText = ''
  }

  private submit(): void {
    if (ParentGateService.check(this.answer)) {
      ParentGateService.markVerified()
      this.onPass()
      return
    }
    this.errorText = '再算一次就可以'
  }

  build() {
    Column({ space: Theme.space.s5 }) {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('家长确认')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      Text('这是给家长看的报告入口。请算出下面这道题，减少误触。')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(ParentGateService.prompt())
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      TextInput({ text: this.answer, placeholder: '请输入得数' })
        .height(52)
        .fontSize(18)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .onChange((v: string) => { this.answer = v })
      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
      }
      AppButton({ label: '确认', onTap: () => this.submit() })
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.s7)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
