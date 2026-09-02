import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { GewuStore } from '../../services/GewuStore'

@Component
export struct InquiryNotePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTokenChange') objectId: string = ''
  @Prop @Watch('onTokenChange') refreshToken: number = 0
  @StorageLink('detailRefreshToken') @Watch('onTokenChange') detailTick: number = 0
  onDataChanged: () => void = () => {}
  @State a1: string = ''
  @State a2: string = ''
  @State a3: string = ''
  @State noteText: string = ''
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const answers = await GewuStore.loadInquiry(this.objectId)
    this.a1 = answers[0]
    this.a2 = answers[1]
    this.a3 = answers[2]
    this.noteText = await GewuStore.loadNote(this.objectId)
    this.confirmDelete = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async saveInquiry(): Promise<void> {
    await GewuStore.saveInquiry(this.objectId, this.a1.trim(), this.a2.trim(), this.a3.trim())
    this.showToast('格物三问已保存')
    this.onDataChanged()
  }

  private async saveNote(): Promise<void> {
    await GewuStore.saveNote(this.objectId, this.noteText)
    this.showToast(this.noteText.trim().length > 0 ? '札记已保存' : '札记已清空')
    this.onDataChanged()
  }

  private async removeNote(): Promise<void> {
    await GewuStore.deleteNote(this.objectId)
    this.noteText = ''
    this.confirmDelete = false
    this.showToast('札记已删除')
    this.onDataChanged()
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Column({ space: Theme.space.s3 }) {
        Text('格物三问')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('读完后写下自己的理解，完成「格物致知」闭环')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text('此物当初要解决什么问题？')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.a1, placeholder: '用一两句话写下你的理解' })
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .caretColor(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .onChange((v: string) => { this.a1 = v })
        Text('它如何改变了当时人们的生活？')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.a2, placeholder: '用一两句话写下你的理解' })
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .caretColor(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .onChange((v: string) => { this.a2 = v })
        Text('今天我们还能从中学到什么？')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.a3, placeholder: '用一两句话写下你的理解' })
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .caretColor(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .onChange((v: string) => { this.a3 = v })
        AppButton({
          label: '保存三问',
          variant: 'secondary',
          onTap: (): void => { void this.saveInquiry() }
        })
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)

      Column({ space: Theme.space.s3 }) {
        Text('我的札记')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        TextArea({ text: this.noteText, placeholder: '写下与此物相关的体会、疑问或联想…' })
          .height(96)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .caretColor(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .onChange((v: string) => { this.noteText = v })
        AppButton({
          label: '保存札记',
          variant: 'primary',
          onTap: (): void => { void this.saveNote() }
        })
        if (!this.confirmDelete) {
          AppButton({
            label: '删除札记',
            variant: 'ghost',
            onTap: (): void => { this.confirmDelete = true }
          })
        } else {
          Row({ space: Theme.space.s3 }) {
            Column() {
              AppButton({
                label: '取消',
                variant: 'ghost',
                onTap: (): void => { this.confirmDelete = false }
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '确认删除',
                variant: 'danger',
                onTap: (): void => { void this.removeNote() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
      }
    }
    .width('100%')
  }
}
