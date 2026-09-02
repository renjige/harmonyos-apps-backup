import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { ZhaLocalStore } from '../../services/ZhaLocalStore'
import { ZhaDetailNav } from '../../services/ZhaDetailNav'
import { ZhaSmartParse } from '../../services/ZhaSmartParse'

@Component
export struct NoteEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onNoteIdChange') noteId: string = ''
  @State formTitle: string = ''
  @State formBody: string = ''
  @State previewTags: string[] = []
  @State toast: string = ''
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onNoteIdChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.noteId.length === 0) {
      return
    }
    const note = await ZhaLocalStore.findNote(this.noteId)
    if (note !== undefined) {
      this.formTitle = note.title
      this.formBody = note.body
      this.previewTags = note.tags
    }
  }

  private refreshTags(): void {
    this.previewTags = ZhaSmartParse.extractTags(`${this.formTitle}\n${this.formBody}`)
  }

  private async save(): Promise<void> {
    if (this.formTitle.trim().length === 0 && this.formBody.trim().length === 0) {
      this.toast = '请填写标题或正文'
      setTimeout(() => { this.toast = '' }, 2000)
      return
    }
    if (this.noteId.length > 0) {
      await ZhaLocalStore.updateNote(this.noteId, this.formTitle.trim(), this.formBody.trim())
      this.onSaved()
      ZhaDetailNav.closeNoteEditor()
      ZhaDetailNav.openNote(this.noteId)
    } else {
      const note = await ZhaLocalStore.createNote(this.formTitle.trim(), this.formBody.trim())
      this.onSaved()
      ZhaDetailNav.closeNoteEditor()
      ZhaDetailNav.openNote(note.id)
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text(this.noteId.length > 0 ? '编辑笔记' : '新建笔记')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
            .onClick(() => ZhaDetailNav.closeNoteEditor())
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.formTitle, placeholder: '笔记标题' })
              .fontSize(Theme.type.title3)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .onChange((v: string) => {
                this.formTitle = v
                this.refreshTags()
              })
            TextArea({ text: this.formBody, placeholder: '正文内容…' })
              .height(260)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .onChange((v: string) => {
                this.formBody = v
                this.refreshTags()
              })
            if (this.previewTags.length > 0) {
              Column({ space: Theme.space.s2 }) {
                Text('智慧识别标签')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.previewTags, (tag: string) => {
                    Text(tag)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .backgroundColor(Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                  }, (tag: string) => tag)
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            AppButton({
              label: '保存',
              variant: 'primary',
              onTap: () => { void this.save() }
            })
          }
          .padding(Theme.space.pageX)
          .width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
