import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { CoverPickRow } from '../note/CoverPickRow'
import { NoteFieldCard, NoteAreaCard } from '../note/NoteFieldCard'
import { OverlayShell } from './OverlayShell'
import { BookLibraryItem } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'
import { PhotoPickService } from '../../services/PhotoPickService'

@Component
export struct BookLibraryEditorPane {
  @Prop bookId: string = ''
  @State title: string = ''
  @State author: string = ''
  @State status: string = 'reading'
  @State coverImage: string = ''
  @State totalPagesText: string = ''
  @State currentPageText: string = ''
  @State memo: string = ''
  @State toastText: string = ''
  private uiContext: common.UIAbilityContext | null = null
  onClose: () => void = () => {}
  onSaved: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    if (this.bookId.length === 0) {
      return
    }
    const found = await StudyStore.findBook(this.bookId)
    if (found === undefined) {
      return
    }
    this.title = found.title
    this.author = found.author
    this.status = found.status
    this.coverImage = found.coverImage
    this.totalPagesText = found.totalPages > 0 ? `${found.totalPages}` : ''
    this.currentPageText = found.currentPage > 0 ? `${found.currentPage}` : ''
    this.memo = found.memo
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private numText(raw: string): number {
    if (raw.trim().length === 0) {
      return 0
    }
    const n = Number.parseInt(raw, 10)
    if (n !== n || n < 0) {
      return 0
    }
    return n
  }

  private async pickCover(): Promise<void> {
    if (this.uiContext === null) {
      this.uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext
    }
    const uri = await PhotoPickService.pickAlbum(this.uiContext)
    if (uri.length > 0) {
      this.coverImage = uri
    }
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写书名')
      return
    }
    let book: BookLibraryItem
    if (this.bookId.length > 0) {
      const found = await StudyStore.findBook(this.bookId)
      book = found ?? BookLibraryItem.createNew()
    } else {
      book = BookLibraryItem.createNew()
    }
    book.title = this.title.trim()
    book.author = this.author.trim()
    book.status = this.status
    book.coverImage = this.coverImage
    book.totalPages = this.numText(this.totalPagesText)
    book.currentPage = this.numText(this.currentPageText)
    book.memo = this.memo.trim()
    await StudyStore.saveBook(book)
    this.showToast('书籍已保存')
    this.onSaved(book.id)
  }

  build() {
    Stack() {
      OverlayShell({
        title: this.bookId.length > 0 ? '编辑书籍' : '添加书籍',
        onClose: (): void => { this.onClose() },
        body: (): void => { this.Body() }
      })
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
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
  Body() {
    Column({ space: Theme.space.s3 }) {
      CoverPickRow({
        coverImage: this.coverImage,
        onAlbum: (): void => { void this.pickCover() }
      })
      NoteFieldCard({
        label: '书名 *',
        value: this.title,
        placeholder: '如：人类简史',
        onChange: (v: string): void => { this.title = v }
      })
      NoteFieldCard({
        label: '作者',
        value: this.author,
        placeholder: '可选',
        onChange: (v: string): void => { this.author = v }
      })
      Row({ space: 8 }) {
        this.StatusChip('在读', 'reading')
        this.StatusChip('已读完', 'finished')
        this.StatusChip('想读', 'wish')
      }
      .width('100%')
      NoteFieldCard({
        label: '总页数',
        value: this.totalPagesText,
        placeholder: '可选，用于进度',
        numberOnly: true,
        onChange: (v: string): void => { this.totalPagesText = v }
      })
      NoteFieldCard({
        label: '当前读到',
        value: this.currentPageText,
        placeholder: '可选',
        numberOnly: true,
        onChange: (v: string): void => { this.currentPageText = v }
      })
      NoteAreaCard({
        label: '阅读备忘',
        value: this.memo,
        placeholder: '为什么想读、阅读目标等',
        onChange: (v: string): void => { this.memo = v }
      })
      AppButton({
        label: '保存',
        onTap: (): void => { void this.save() }
      })
    }
    .width('100%')
  }

  @Builder
  StatusChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.status === key ? '#FFFFFF' : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.status === key ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.status = key })
  }
}
