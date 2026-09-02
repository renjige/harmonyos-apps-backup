import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { LearningHubService } from '../services/LearningHubService'
import { UserNote } from '../models/LearningHubModels'

@Component
export struct UserNotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: UserNote[] = []
  @State editing: boolean = false
  @State noteId: string = ''
  @State titleDraft: string = ''
  @State bodyDraft: string = ''
  @State tagsDraft: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    this.items = LearningHubService.notes()
  }

  private openEditor(note?: UserNote): void {
    this.editing = true
    if (note !== undefined) {
      this.noteId = note.id
      this.titleDraft = note.title
      this.bodyDraft = note.body
      this.tagsDraft = note.tags
    } else {
      this.noteId = ''
      this.titleDraft = ''
      this.bodyDraft = ''
      this.tagsDraft = ''
    }
  }

  private async saveNote(): Promise<void> {
    const title = this.titleDraft.trim()
    const body = this.bodyDraft.trim()
    if (title.length === 0 || body.length === 0) {
      this.toastText = '标题和正文不能为空'
      setTimeout((): void => { this.toastText = '' }, 1800)
      return
    }
    const note = new UserNote()
    note.id = this.noteId
    note.title = title
    note.body = body
    note.tags = this.tagsDraft.trim()
    await LearningHubService.saveNote(note)
    this.editing = false
    this.items = LearningHubService.notes()
    this.toastText = '笔记已保存'
    setTimeout((): void => { this.toastText = '' }, 1800)
  }

  private async deleteNote(id: string): Promise<void> {
    await LearningHubService.deleteNote(id)
    this.items = LearningHubService.notes()
    this.toastText = '已删除'
    setTimeout((): void => { this.toastText = '' }, 1800)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.editing) {
        Column({ space: Theme.space.s3 }) {
          Row({ space: Theme.space.s2 }) {
            Text('返回列表')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.editing = false })
            Blank()
            Text('编辑笔记')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

          TextInput({ text: this.titleDraft, placeholder: '笔记标题' })
            .onChange((v: string): void => { this.titleDraft = v })
          TextInput({ text: this.tagsDraft, placeholder: '标签（选填）' })
            .onChange((v: string): void => { this.tagsDraft = v })
          TextArea({ text: this.bodyDraft, placeholder: '记录你的思考与延伸…' })
            .height(200)
            .onChange((v: string): void => { this.bodyDraft = v })
          AppButton({ label: '保存', onTap: (): void => { void this.saveNote() } })
        }
        .width('100%').height('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .backgroundColor(Theme.colors().surfacePage)
      } else {
        Column() {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44).height(44).justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick((): void => { CommonSenseDetailNav.close() })
            Text('学习笔记')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('新建')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.openEditor() })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

          if (this.items.length === 0) {
            AppEmpty({
              title: '还没有笔记',
              description: '阅读后可记录心得，与收藏夹互补。',
              actionLabel: '写第一篇',
              onAction: (): void => { this.openEditor() }
            })
          } else {
            List({ space: Theme.space.s2 }) {
              ForEach(this.items, (row: UserNote) => {
                ListItem() {
                  Column({ space: 6 }) {
                    Text(row.title)
                      .fontSize(Theme.type.body)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.colors().textPrimary)
                      .width('100%')
                    Text(row.body)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.colors().textSecondary)
                      .maxLines(3)
                      .width('100%')
                    Row() {
                      Text('编辑')
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().brandPrimary)
                        .onClick((): void => { this.openEditor(row) })
                      Text('删除')
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().danger)
                        .margin({ left: 16 })
                        .onClick((): void => { void this.deleteNote(row.id) })
                    }
                    .width('100%')
                  }
                  .padding(Theme.space.s4)
                  .width('100%')
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.card)
                  .onClick((): void => { this.openEditor(row) })
                }
              }, (row: UserNote) => row.id)
            }
            .layoutWeight(1)
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
          }
        }
        .width('100%').height('100%')
        .backgroundColor(Theme.colors().surfacePage)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%').height('100%').zIndex(18)
  }
}
