import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { NoteItem } from '../../models/TuceModels'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'

@Component
export struct NoteFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop noteId: string = ''
  @State title: string = ''
  @State body: string = ''
  @State errorText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.noteId.length === 0) {
      return
    }
    const found = await TuceStore.findNote(this.noteId)
    if (found !== undefined) {
      this.title = found.title
      this.body = found.body
    }
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0 || this.body.trim().length === 0) {
      this.errorText = '请填写标题和正文'
      return
    }
    const n = new NoteItem()
    n.id = this.noteId.length > 0 ? this.noteId : TuceStore.newId('note')
    n.title = this.title.trim()
    n.body = this.body.trim()
    n.createdAt = Date.now()
    await TuceStore.saveNote(n)
    TuceNav.bump()
    TuceNav.close()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      TextInput({ text: this.title, placeholder: '笔记标题，如我的深蹲笔记' })
        .onChange((v: string): void => { this.title = v })
      TextArea({ text: this.body, placeholder: '训练心得、动作体会或自我总结' })
        .height(160)
        .onChange((v: string): void => { this.body = v })
      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().danger)
      }
      AppButton({
        label: this.noteId.length > 0 ? '保存修改' : '保存笔记',
        variant: 'primary',
        onTap: (): void => { void this.save() }
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
