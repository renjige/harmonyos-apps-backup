import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { XuNoteItem } from '../../models/XuModels'
import { XuLocalStore } from '../../services/XuLocalStore'
import { XuDetailNav } from '../../services/XuDetailNav'
import { XuMedia } from '../../services/XuMedia'
import { XuConfirmDialog } from '../xu/XuConfirmDialog'
import { XuBizService } from '../../services/XuBizService'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') noteId: string = ''
  @State item: XuNoteItem = new XuNoteItem()
  @State confirmDel: boolean = false
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await XuLocalStore.findNote(this.noteId)
    if (found !== undefined) {
      this.item = found
    }
  }

  private async doDelete(): Promise<void> {
    await XuLocalStore.deleteNote(this.item.id)
    this.confirmDel = false
    this.onChanged()
    XuDetailNav.closeNote()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(XuMedia.note())
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column() {
              Text('知识碎片')
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,42,58,0)', 0], ['rgba(26,42,58,0.82)', 1]]
            })
          }
          .width('100%')
          .borderRadius(Theme.radius.xl)
          .clip(true)

          if (this.item.tagPreview().length > 0) {
            Text(this.item.tagPreview())
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().brandAccent)
              .width('100%')
          }

          AppCard({ title: '摘要' }) {
            Text(this.item.summary(120))
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }

          AppCard({ title: '正文' }) {
            Text(this.item.body.length > 0 ? this.item.body : '尚未写下正文。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }

          Column({ space: Theme.space.s3 }) {
            AppButton({
              label: '编辑',
              onTap: (): void => { XuDetailNav.openNoteEditor(this.item.id) }
            })
            AppButton({
              label: '删除',
              variant: 'danger',
              onTap: (): void => { this.confirmDel = true }
            })
          }
          .width('100%')
          .padding({ bottom: Theme.space.s10 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        .width('100%')
      }
      .layoutWeight(1)

      if (this.confirmDel) {
        XuConfirmDialog({
          title: '删除这条笔记？',
          message: '删除后无法恢复。',
          onConfirm: (): void => { void this.doDelete() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
