import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DetailMissingPane } from './DetailMissingPane'
import { NoteEditorSheet } from '../reading/NoteEditorSheet'
import { CreateQuoteRequest, NoteItem } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'
import { ReadingMedia } from '../../services/ReadingMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State item: NoteItem | undefined = undefined
  @State loading: boolean = true
  @State sheetMode: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private tagsText(): string {
    if (this.item === undefined) {
      return ''
    }
    return this.item.tags.join(', ')
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await ReadingBizService.findNote(this.itemId)
    this.loading = false
  }

  private async handleAddQuote(): Promise<void> {
    if (!AuthService.requireAuth('add_quote')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const req = new CreateQuoteRequest()
    req.title = this.item.title
    req.content = this.item.body.length > 0 ? this.item.body : this.item.summary
    req.bookId = this.item.bookId
    req.tags = this.item.tags
    const created = await ReadingBizService.createQuote(req)
    if (created !== undefined) {
      this.showToast('已收藏到札语')
      this.onChanged()
    } else {
      this.showToast('收藏失败，请稍后重试')
    }
  }

  private handleSheetDone(kind: string): void {
    if (kind === 'delete') {
      void this.handleDelete()
      return
    }
    this.sheetMode = ''
    void this.loadItem()
    this.onChanged()
    this.showToast('笔记已更新')
  }

  private async handleDelete(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const ok = await ReadingBizService.deleteNote(this.item.id)
    this.sheetMode = ''
    if (ok) {
      this.onChanged()
      ReadingDetailNav.close()
      return
    }
    this.showToast('删除失败，请稍后重试')
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载笔记…' })
      } else if (this.item === undefined) {
        DetailMissingPane({
          title: '读书笔记',
          emptyTitle: '笔记不存在',
          emptyDescription: '可能已被删除，请返回继续浏览'
        })
      } else if (this.sheetMode.length > 0) {
        NoteEditorSheet({
          mode: this.sheetMode,
          noteId: this.item.id,
          initialTitle: this.item.title,
          initialBody: this.item.body,
          initialTags: this.tagsText(),
          initialDate: this.item.recordDate,
          onClose: (): void => { this.sheetMode = '' },
          onDone: (kind: string): void => { this.handleSheetDone(kind) }
        })
      } else {
        DetailShell({
          title: '读书笔记',
          onClose: (): void => { ReadingDetailNav.close() },
          body: (): void => { this.DetailBody() }
        })
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      this.NoteBody(this.item)
    }
  }

  @Builder
  NoteBody(note: NoteItem) {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(ReadingMedia.coverMedia(note.coverKey.length > 0 ? note.coverKey : 'note_scene_desk'))
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        Column()
          .width('100%')
          .height(160)
          .linearGradient({
            angle: 180,
            colors: Theme.heroScrimStops()
          })
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        Column({ space: 4 }) {
          if (note.recordDate.length > 0) {
            Text(note.recordDate)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.heroSubtitleColor())
          }
          Text(note.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.heroTitleColor())
        }
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (note.tags.length > 0) {
        Row({ space: 8 }) {
          ForEach(note.tags, (tag: string) => {
            Text(tag)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.tagForeground())
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor(Theme.tagBackground())
              .border({
                width: Theme.isDark() ? 1 : 0,
                color: Theme.colors().strokeStrong
              })
              .borderRadius(Theme.radius.pill)
          }, (tag: string) => tag)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Column() {
        AppCard({ title: '摘要', variant: 'plain' }) {
          Text(note.summary.length > 0 ? note.summary : '暂无摘要')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column() {
        AppCard({ title: '正文', variant: 'plain' }) {
          Text(note.body.length > 0 ? note.body : '暂无正文')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .lineHeight(24)
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: Theme.space.s3 }) {
        AppButton({
          label: '编辑笔记',
          onTap: (): void => { this.sheetMode = 'edit' }
        })
        AppButton({
          label: '收藏到札语',
          variant: 'secondary',
          onTap: (): void => { void this.handleAddQuote() }
        })
        AppButton({
          label: '删除笔记',
          variant: 'ghost',
          onTap: (): void => { this.sheetMode = 'delete' }
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
  }
}
