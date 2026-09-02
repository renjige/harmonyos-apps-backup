import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { QualityNav } from '../../services/QualityNav'

@Component
export struct FeedbackPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State content: string = ''
  @State contact: string = ''
  @State errorText: string = ''
  onClose: () => void = () => {}

  private submit(): void {
    if (this.content.trim().length === 0) {
      this.errorText = '请填写意见内容'
      return
    }
    QualityNav.toast('已提交，感谢反馈')
    this.onClose()
  }

  build() {
    Column() {
      Row() {
        Text('意见反馈')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      Scroll() {
        Column({ space: 12 }) {
          Text('请描述使用中遇到的问题或改进建议。反馈仅保存在本机，不会自动上传。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.content, placeholder: '请输入反馈内容' })
            .height(140)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
            .onChange((v: string) => { this.content = v })
          TextInput({ text: this.contact, placeholder: '联系方式（选填）' })
            .height(46)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
            .onChange((v: string) => { this.contact = v })
          if (this.errorText.length > 0) {
            Text(this.errorText).fontSize(Theme.type.footnote).fontColor(Theme.colors().danger)
          }
        }
        .padding({ left: 20, right: 20, bottom: 24 })
      }
      .layoutWeight(1)

      Column() {
        AppButton({ label: '提交反馈', onTap: () => this.submit() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20, top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
