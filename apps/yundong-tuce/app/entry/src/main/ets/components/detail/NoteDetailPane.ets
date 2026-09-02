import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { NoteItem } from '../../models/TuceModels'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop noteId: string = ''
  @State note: NoteItem = new NoteItem()
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await TuceStore.findNote(this.noteId)
    if (found !== undefined) {
      this.note = found
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text(this.note.title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.note.body)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .lineHeight(24)
        AppButton({
          label: '编辑笔记',
          variant: 'primary',
          onTap: (): void => { TuceNav.open('noteform', this.noteId) }
        })
        AppButton({
          label: this.confirmDelete ? '确认删除笔记' : '删除笔记',
          variant: 'secondary',
          onTap: (): void => { void this.remove() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await TuceStore.deleteNote(this.noteId)
    TuceNav.bump()
    TuceNav.close()
  }
}
