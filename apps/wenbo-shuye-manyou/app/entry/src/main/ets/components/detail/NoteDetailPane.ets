import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { RoamNote, RoamTime } from '../../models/RoamModels'
import { RoamDetailNav } from '../../services/RoamDetailNav'
import { RoamStore } from '../../services/RoamStore'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop noteId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State note: RoamNote = new RoamNote()
  @State editText: string = ''
  @State loaded: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private reload(): void {
    const found = RoamStore.findNote(this.noteId)
    if (found !== undefined) {
      this.note = found
      this.editText = found.body
      this.loaded = true
    }
  }

  private async saveEdit(): Promise<void> {
    const text = this.editText.trim()
    if (text.length === 0) {
      this.showToast('笔记不能为空')
      return
    }
    this.note.body = text
    await RoamStore.saveNote(this.note)
    this.reload()
    this.showToast('已更新')
  }

  private async removeNote(): Promise<void> {
    await RoamStore.removeNote(this.noteId)
    RoamDetailNav.close()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '阅读笔记',
        onClose: (): void => { RoamDetailNav.close() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '笔记不存在', description: '可能已被删除。' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: 6 }) {
                Text(this.note.bookTitle)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(this.note.excerptTitle)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                Text(`更新于 ${RoamTime.formatDateTime(this.note.updatedAt)}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              TextArea({ text: this.editText, placeholder: '笔记内容（最多 200 字）' })
                .height(160)
                .maxLength(200)
                .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
                .onChange((v: string): void => { this.editText = v })

              Column({ space: Theme.space.s3 }) {
                AppButton({
                  label: '保存修改',
                  variant: 'primary',
                  onTap: (): void => { void this.saveEdit() }
                })
                AppButton({
                  label: '删除笔记',
                  variant: 'danger',
                  onTap: (): void => { void this.removeNote() }
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s10
              })
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
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
