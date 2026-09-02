import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { GewuStore } from '../../services/GewuStore'
import { HomeRefresh } from '../../services/HomeRefresh'

@Component
export struct GewuInquiryCompact {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onObjectChange') objectId: string = ''
  @Prop @Watch('onObjectChange') refreshToken: number = 0
  onSaved: () => void = () => {}
  @State a1: string = ''
  @State a2: string = ''
  @State a3: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onObjectChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (this.objectId.length === 0) {
      return
    }
    const answers = await GewuStore.loadInquiry(this.objectId)
    this.a1 = answers[0]
    this.a2 = answers[1]
    this.a3 = answers[2]
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    await GewuStore.saveInquiry(this.objectId, this.a1.trim(), this.a2.trim(), this.a3.trim())
    HomeRefresh.bump()
    this.showToast('格物三问已保存')
    this.onSaved()
  }

  build() {
    Stack() {
      Column({ space: Theme.space.s3 }) {
        Column({ space: Theme.space.s1 }) {
          Text('格物三问')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('围绕今日知识物作答，完成「格物致知」理解闭环')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }

        Text('此物当初要解决什么问题？')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.a1, placeholder: '写下你的理解' })
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string): void => { this.a1 = v })

        Text('它的结构或形态有什么特点？')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.a2, placeholder: '形态、材质或用法' })
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string): void => { this.a2 = v })

        Text('今天观察后，有什么新体会？')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.a3, placeholder: '联系图鉴或现场' })
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string): void => { this.a3 = v })

        AppButton({
          label: '保存格物三问',
          variant: 'primary',
          onTap: (): void => { void this.save() }
        })
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 8 })
          .translate({ x: '-50%' })
          .zIndex(10)
      }
    }
    .width('100%')
  }
}
