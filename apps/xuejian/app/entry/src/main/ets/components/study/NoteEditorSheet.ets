import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { StudyNote } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'
import { StudyMedia } from '../../services/StudyMedia'

@Component
export struct NoteEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop noteId: string = ''
  @State titleText: string = ''
  @State bodyText: string = ''
  @State tagsText: string = ''
  @State coverKey: string = 'hero_desk'
  @State toastText: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.noteId.length === 0) {
      return
    }
    const found = await StudyStore.findNote(this.noteId)
    if (found !== undefined) {
      this.titleText = found.title
      this.bodyText = found.body
      this.tagsText = found.tags
      this.coverKey = found.coverKey
    }
  }

  private pickCover(key: string): void {
    this.coverKey = key
  }

  private async save(): Promise<void> {
    if (this.titleText.trim().length === 0) {
      this.toastText = '请填写笔记标题'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    let item = await StudyStore.findNote(this.noteId)
    if (item === undefined) {
      item = StudyNote.createNew()
    }
    item.title = this.titleText.trim()
    item.body = this.bodyText
    item.tags = this.tagsText.trim()
    item.coverKey = this.coverKey
    await StudyStore.saveNote(item)
    this.onChanged()
    this.onClose()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(48).height(48).justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text(this.noteId.length > 0 ? '✏️ 编辑笔记' : '📝 新建笔记')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.titleText, placeholder: '笔记标题' })
              .width('100%')
              .height(48)
              .fontColor(Theme.inputInk())
              .placeholderColor(Theme.inputHint())
              .backgroundColor(Theme.inputFill())
              .border({ width: 1, color: '#CBD5E1' })
              .borderRadius(12)
              .onChange((v: string) => { this.titleText = v })
            TextArea({ text: this.bodyText, placeholder: '写下重点摘要或学习心得…' })
              .width('100%')
              .height(180)
              .fontColor(Theme.inputInk())
              .placeholderColor(Theme.inputHint())
              .backgroundColor(Theme.inputFill())
              .onChange((v: string) => { this.bodyText = v })
            TextInput({ text: this.tagsText, placeholder: '标签，用逗号分隔' })
              .width('100%')
              .height(44)
              .fontColor(Theme.inputInk())
              .placeholderColor(Theme.inputHint())
              .backgroundColor(Theme.inputFill())
              .border({ width: 1, color: '#CBD5E1' })
              .borderRadius(12)
              .onChange((v: string) => { this.tagsText = v })
            Text('配图（本机影像，不读取相册）')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Row({ space: 8 }) {
              this.CoverPick('hero_desk')
              this.CoverPick('banner_focus')
              this.CoverPick('banner_insight')
              this.CoverPick('texture_paper')
            }
            .width('100%')
            AppButton({ label: '保存笔记', onTap: (): void => { void this.save() } })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(12)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  CoverPick(key: string) {
    Image(StudyMedia.resource(key))
      .width(64)
      .height(64)
      .objectFit(ImageFit.Cover)
      .borderRadius(10)
      .border({
        width: this.coverKey === key ? 3 : 0,
        color: Theme.colors().textPrimary
      })
      .onClick((): void => { this.pickCover(key) })
  }
}
