import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { FeedbackService } from '../../services/FeedbackService'

@Component
export struct FeedbackPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State content: string = ''
  @State contact: string = ''
  @State sent: boolean = false
  onBack: () => void = () => {}
  onToast: (msg: string) => void = (_m: string) => {}

  private submit(): void {
    if (this.content.trim().length < 4) {
      this.onToast('请至少写 4 个字，方便我们理解你的建议')
      return
    }
    void FeedbackService.save(this.content.trim(), this.contact.trim()).then((ok: boolean) => {
      if (ok) {
        this.sent = true
        this.onToast('反馈已保存，感谢你的建议')
        return
      }
      this.onToast('保存失败，请稍后重试')
    })
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        AppIcon({ name: 'chevron', iconSize: 18, color: Theme.colors().textSecondary })
          .rotate({ angle: 180 })
        Text('意见反馈')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: 8 })
      .onClick(() => this.onBack())

      Scroll() {
        Column({ space: 14 }) {
          Text('欢迎反馈功能建议、体验问题或使用场景。反馈会保存在本机，便于我们在后续版本改进。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.content, placeholder: '例如：希望看板能显示本周计划汇总…' })
            .height(140)
            .onChange((v: string) => { this.content = v })
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          TextInput({ text: this.contact, placeholder: '选填：手机号或邮箱，方便回访（可不填）' })
            .onChange((v: string) => { this.contact = v })
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          if (this.sent) {
            Text('已收到你的反馈。也可在华为应用市场留下评价，帮助我们持续优化。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
          }
          Row() {
            AppButton({
              label: this.sent ? '再写一条' : '提交反馈',
              variant: 'primary',
              onTap: (): void => {
                if (this.sent) {
                  this.sent = false
                  this.content = ''
                  this.contact = ''
                  return
                }
                this.submit()
              }
            })
          }
          .width('100%')
          .onClick((): void => {
            if (this.sent) {
              this.sent = false
              this.content = ''
              this.contact = ''
              return
            }
            this.submit()
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
