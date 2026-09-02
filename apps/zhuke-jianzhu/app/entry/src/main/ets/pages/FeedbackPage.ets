import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { AppButton } from '../components/design-system/AppButton'
import { MessageService } from '../services/MessageService'
import promptAction from '@ohos.promptAction'

@Component
export struct FeedbackPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State content: string = ''
  @State contact: string = ''
  @State submitting: boolean = false
  onBack: () => void = () => {}

  private async submit(): Promise<void> {
    if (this.content.length === 0) {
      promptAction.showToast({ message: '请填写反馈内容' })
      return
    }
    if (this.submitting) {
      return
    }
    this.submitting = true
    const ok = await MessageService.submitFeedback(this.content, this.contact)
    this.submitting = false
    if (ok) {
      promptAction.showToast({ message: '感谢您的反馈，我们会认真处理' })
      this.content = ''
      this.contact = ''
    } else {
      promptAction.showToast({ message: '提交失败，请稍后重试' })
    }
  }

  build() {
    Column() {
      AppNavBar({ title: '意见反馈', onBack: () => this.onBack() })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppCard({ title: '反馈说明' }) {
            Text('请描述您在使用过程中遇到的问题或改进建议，我们将持续优化产品体验。')
              .fontSize(Theme.type.callout)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(22)
          }

          TextArea({ placeholder: '请输入反馈内容（必填）', text: this.content })
            .onChange((v: string) => { this.content = v })
            .height(140)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .padding(Theme.space.s3)

          TextInput({ placeholder: '联系方式（选填）', text: this.contact })
            .onChange((v: string) => { this.contact = v })
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .padding({ left: Theme.space.s3, right: Theme.space.s3 })

          AppButton({
            label: this.submitting ? '提交中…' : '提交反馈',
            disabled: this.submitting,
            onTap: () => this.submit()
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s8
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
