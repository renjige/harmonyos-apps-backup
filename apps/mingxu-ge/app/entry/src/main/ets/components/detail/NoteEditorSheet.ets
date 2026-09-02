import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { XuNoteItem } from '../../models/XuModels'
import { XuLocalStore } from '../../services/XuLocalStore'
import { XuBizService } from '../../services/XuBizService'

@Component
export struct NoteEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @State title: string = ''
  @State body: string = ''
  @State tags: string = ''
  @State errorText: string = ''
  onSaved: () => void = () => {}
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const found = await XuLocalStore.findNote(this.editId)
    if (found !== undefined) {
      this.title = found.title
      this.body = found.body
      this.tags = found.tags.split('|').join(' ')
    }
  }

  private normalizeTags(raw: string): string {
    const parts: string[] = []
    let cur = ''
    for (let i = 0; i < raw.length; i++) {
      const c = raw.charAt(i)
      if (c === ' ' || c === ',' || c === '，' || c === '|') {
        if (cur.length > 0 && parts.length < 3) {
          parts.push(cur)
        }
        cur = ''
      } else {
        cur += c
      }
    }
    if (cur.length > 0 && parts.length < 3) {
      parts.push(cur)
    }
    return parts.join('|')
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写标题'
      return
    }
    const tagRaw = this.normalizeTags(this.tags)
    let item = XuNoteItem.create(this.title.trim(), this.body, tagRaw)
    if (this.editId.length > 0) {
      const found = await XuLocalStore.findNote(this.editId)
      if (found !== undefined) {
        item = found
        item.title = this.title.trim()
        item.body = this.body
        item.tags = tagRaw
        item.updatedAt = Date.now()
      }
    }
    await XuLocalStore.saveNote(item)
    void XuBizService.syncNote(item)
    this.onSaved()
    this.onClose()
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Text(this.editId.length > 0 ? '编辑知识碎片' : '写下知识碎片')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      TextInput({ text: this.title, placeholder: '✨ 标题' })
        .onChange((v: string) => { this.title = v })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
      TextArea({ text: this.body, placeholder: '摘抄、灵感或一段观察…' })
        .onChange((v: string) => { this.body = v })
        .layoutWeight(1)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
      TextInput({ text: this.tags, placeholder: '标签，空格分隔，最多 3 个' })
        .onChange((v: string) => { this.tags = v })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
      if (this.errorText.length > 0) {
        Text(this.errorText).fontSize(Theme.type.footnote).fontColor(Theme.colors().danger).width('100%')
      }
      AppButton({ label: '保存', onTap: (): void => { void this.save() } })
      AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.onClose() } })
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
