import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { AppButton } from '../components/design-system/AppButton'
import { ContentService } from '../services/ContentService'
import { MessageService } from '../services/MessageService'
import { ContactInfo } from '../models/ZhukeModels'
import { ContentCover } from '../components/common/ContentCover'
import { ContactUtil } from '../utils/ContactUtil'
import promptAction from '@ohos.promptAction'
import { common } from '@kit.AbilityKit'

@Component
export struct ContactPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State contact: ContactInfo = new ContactInfo()
  @State msgName: string = ''
  @State msgPhone: string = ''
  @State msgContent: string = ''
  @State submitting: boolean = false
  onBack: () => void = () => {}

  aboutToAppear(): void {
    this.contact = ContentService.contact()
  }

  private async submitMessage(): Promise<void> {
    if (this.msgName.length === 0 || this.msgPhone.length === 0 || this.msgContent.length === 0) {
      promptAction.showToast({ message: '请填写完整留言信息' })
      return
    }
    if (this.submitting) {
      return
    }
    this.submitting = true
    const ok = await MessageService.submitContact(this.msgName, this.msgPhone, this.msgContent)
    this.submitting = false
    if (ok) {
      promptAction.showToast({ message: '留言已提交，我们将尽快与您联系' })
      this.msgName = ''
      this.msgPhone = ''
      this.msgContent = ''
    } else {
      promptAction.showToast({ message: '提交失败，请稍后重试' })
    }
  }

  private dialCompanyPhone(): void {
    const ctx = getContext(this) as common.UIAbilityContext
    ContactUtil.dial(ctx, this.contact.phone)
  }

  private sendCompanyEmail(): void {
    const ctx = getContext(this) as common.UIAbilityContext
    ContactUtil.sendEmail(ctx, this.contact.email)
  }

  build() {
    Column() {
      AppNavBar({ title: '联系我们', onBack: () => this.onBack() })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppCard({ title: '公司地址', variant: 'inverse' }) {
            Column({ space: Theme.space.s2 }) {
              Text(this.contact.address)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textOnInverse)
              Text(`工作时间：${this.contact.workHours}`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textOnInverse)
                .opacity(0.85)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          AppCard({ title: '联系电话' }) {
            Column({ space: Theme.space.s2 }) {
              Text(this.contact.phone)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick(() => this.dialCompanyPhone())
              Text(this.contact.email)
                .fontSize(Theme.type.callout)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick(() => this.sendCompanyEmail())
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          AppCard({ title: '地图导航' }) {
            Column({ space: Theme.space.s3 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                ContentCover({
                  imageKey: this.contact.imageKey,
                  coverHeight: 140,
                  coverRadius: Theme.radius.md,
                  showGradient: true
                })
                Column({ space: Theme.space.s1 }) {
                  Text('筑科大厦')
                    .fontSize(Theme.type.subhead)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Medium)
                  Text(this.contact.address)
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                    .opacity(0.9)
                }
                .padding(Theme.space.s3)
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }
              .width('100%')

              AppButton({
                label: '打开地图导航',
                variant: 'secondary',
                onTap: () => {
                  promptAction.showToast({ message: '演示模式：将跳转系统地图应用' })
                }
              })
            }
            .width('100%')
          }

          AppCard({ title: '在线留言' }) {
            Column({ space: Theme.space.s3 }) {
              TextInput({ placeholder: '您的姓名', text: this.msgName })
                .onChange((v: string) => { this.msgName = v })
                .height(44)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.sm)
                .padding({ left: Theme.space.s3, right: Theme.space.s3 })

              TextInput({ placeholder: '联系电话', text: this.msgPhone })
                .type(InputType.PhoneNumber)
                .onChange((v: string) => { this.msgPhone = v })
                .height(44)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.sm)
                .padding({ left: Theme.space.s3, right: Theme.space.s3 })

              TextArea({ placeholder: '留言内容', text: this.msgContent })
                .onChange((v: string) => { this.msgContent = v })
                .height(100)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.sm)
                .padding(Theme.space.s3)

              AppButton({
                label: this.submitting ? '提交中…' : '提交留言',
                disabled: this.submitting,
                onTap: () => this.submitMessage()
              })
            }
            .width('100%')
          }
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
