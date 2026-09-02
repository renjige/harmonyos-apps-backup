import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { CampDetailNav } from '../services/CampDetailNav'

@Component
export struct FeedbackPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State content: string = ''
  @State contact: string = ''
  @State toastText: string = ''
  @State sent: boolean = false

  private submit(): void {
    if (this.content.trim().length < 4) {
      this.toastText = '请再写几个字，方便我们改进'
      setTimeout(() => { this.toastText = '' }, 2200)
      return
    }
    this.sent = true
    this.toastText = '已记下，谢谢你的露营经验'
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({ title: '意见反馈', onClose: () => CampDetailNav.close() }) {
        Column({ space: 14 }) {
          Text('装备漏带、营地信息不准、还是打包勾选不好用？写下来即可。')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.content, placeholder: '描述你遇到的问题或想要的清单规则' })
            .onChange((v: string) => { this.content = v })
            .height(140)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
          TextInput({ text: this.contact, placeholder: '选填：邮箱或手机，方便回你' })
            .onChange((v: string) => { this.contact = v })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
          if (this.sent) {
            Text('这条反馈已留在本机。后续版本会按露营场景处理。')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
          }
          AppButton({
            label: this.sent ? '再写一条' : '送出',
            variant: 'primary',
            onTap: (): void => {
              if (this.sent) {
                this.sent = false
                this.content = ''
                return
              }
              this.submit()
            }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
