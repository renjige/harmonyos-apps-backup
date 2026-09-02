import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { ReadingDoc } from '../../models/FolioModels'
import { FolioStore } from '../../services/FolioStore'

@Component
export struct PasteDocSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @State title: string = ''
  @State body: string = ''
  @State errorText: string = ''
  onClose: () => void = () => {}
  onSaved: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.prefill()
  }

  private async prefill(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const found = await FolioStore.findDoc(this.editId)
    if (found !== undefined) {
      this.title = found.title
      this.body = found.body
    }
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写文稿标题'
      return
    }
    if (this.body.trim().length === 0) {
      this.errorText = '请粘贴或输入正文'
      return
    }
    if (this.editId.length > 0) {
      const found = await FolioStore.findDoc(this.editId)
      if (found !== undefined) {
        found.title = this.title.trim()
        found.body = this.body
        await FolioStore.saveDoc(found)
        this.onSaved(found.id)
        this.onClose()
        return
      }
    }
    const doc = ReadingDoc.create(this.title.trim(), 'paste', this.body)
    await FolioStore.saveDoc(doc)
    this.onSaved(doc.id)
    this.onClose()
  }

  build() {
    Column() {
      AppNavBar({ title: this.editId.length > 0 ? '补充正文' : '粘贴文稿', onBack: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: 12 }) {
          Text('标题')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.title, placeholder: '例如：产品研究摘记' })
            .onChange((v: string) => { this.title = v })
            .height(48)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
          Text('正文')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.body, placeholder: '从 TXT / Markdown 复制正文粘贴到这里' })
            .onChange((v: string) => { this.body = v })
            .height(280)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
          if (this.errorText.length > 0) {
            Text(this.errorText)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }
          AppButton({ label: '保存并阅读', onTap: (): void => { void this.save() } })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
