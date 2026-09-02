import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import {
  BookCategoryUtil,
  CreateInspirationRequest,
  CreateNoteRequest,
  CreateQuoteRequest,
  CreateReadingLogRequest,
  CreateReviewRequest,
  PatchBookRequest
} from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { AuthService } from '../../services/AuthService'

/** 书籍详情内：时长 / 页数 / 笔记 / 札语 / 书评 / 灵感 / 删除 */
@Component
export struct BookStudioSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: string = ''
  @Prop bookId: string = ''
  @Prop bookTitle: string = ''
  @Prop initialPageCount: number = 0
  @Prop initialCurrentPage: number = 0
  onClose: () => void = () => {}
  onDone: (kind: string) => void = (kind: string) => { if (kind.length < 0) { return } }
  onRequireAuth: () => void = () => {}
  @State noteTitle: string = ''
  @State noteBody: string = ''
  @State noteCoverKey: string = 'note_scene_desk'
  @State quoteContent: string = ''
  @State quoteComment: string = ''
  @State pageCountText: string = ''
  @State currentPageText: string = ''
  @State reviewBody: string = ''
  @State reviewRating: number = 5
  @State inspirationContent: string = ''
  @State submitting: boolean = false
  @State errorText: string = ''
  private starOptions: number[] = [1, 2, 3, 4, 5]

  aboutToAppear(): void {
    this.resetForm()
  }

  private resetForm(): void {
    this.noteTitle = `${this.bookTitle} 笔记`
    this.noteBody = ''
    this.noteCoverKey = 'note_scene_desk'
    this.quoteContent = ''
    this.quoteComment = ''
    this.pageCountText = this.initialPageCount > 0 ? `${this.initialPageCount}` : ''
    this.currentPageText = this.initialCurrentPage > 0 ? `${this.initialCurrentPage}` : ''
    this.reviewBody = ''
    this.reviewRating = 5
    this.inspirationContent = ''
    this.errorText = ''
    this.submitting = false
  }

  private todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private async saveSession(minutes: number): Promise<void> {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    if (this.submitting) {
      return
    }
    this.submitting = true
    const req = new CreateReadingLogRequest()
    req.title = `阅读《${this.bookTitle}》`
    req.bookId = this.bookId
    req.readingMinutes = minutes
    req.recordDate = this.todayIso()
    const created = await ReadingBizService.createReadingLog(req)
    this.submitting = false
    if (created !== undefined) {
      this.onDone('session')
      return
    }
    this.errorText = '记录失败，请稍后重试'
  }

  private async savePages(): Promise<void> {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    this.submitting = true
    const req = new PatchBookRequest()
    const pages = Number(this.pageCountText)
    const cur = Number(this.currentPageText)
    req.pageCount = pages > 0 ? pages : 0
    req.currentPage = cur > 0 ? cur : 0
    const updated = await ReadingBizService.patchBook(this.bookId, req)
    this.submitting = false
    if (updated !== undefined) {
      this.onDone('pages')
      return
    }
    this.errorText = '更新失败，请稍后重试'
  }

  private async saveNote(): Promise<void> {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    if (this.noteTitle.trim().length === 0 || this.noteBody.trim().length === 0) {
      this.errorText = '请填写笔记标题和内容'
      return
    }
    this.submitting = true
    const req = new CreateNoteRequest()
    req.title = this.noteTitle.trim()
    req.body = this.noteBody.trim()
    req.summary = this.noteBody.trim().slice(0, 80)
    req.bookId = this.bookId
    req.recordDate = this.todayIso()
    req.coverKey = this.noteCoverKey
    req.kind = 'note'
    const created = await ReadingBizService.createNote(req)
    this.submitting = false
    if (created !== undefined) {
      this.onDone('note')
      return
    }
    this.errorText = '保存失败，请稍后重试'
  }

  private async saveQuote(): Promise<void> {
    if (!AuthService.requireAuth('add_quote')) {
      this.onRequireAuth()
      return
    }
    if (this.quoteContent.trim().length === 0) {
      this.errorText = '请填写札语内容'
      return
    }
    this.submitting = true
    const req = new CreateQuoteRequest()
    req.title = '札语摘录'
    req.content = this.quoteContent.trim()
    req.comment = this.quoteComment.trim()
    req.source = this.bookTitle
    req.bookId = this.bookId
    const created = await ReadingBizService.createQuote(req)
    this.submitting = false
    if (created !== undefined) {
      this.onDone('quote')
      return
    }
    this.errorText = '收藏失败，请稍后重试'
  }

  private async saveReview(): Promise<void> {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    if (this.reviewBody.trim().length === 0) {
      this.errorText = '请写下阅读评价'
      return
    }
    this.submitting = true
    const req = new CreateReviewRequest()
    req.title = `《${this.bookTitle}》书评`
    req.body = this.reviewBody.trim()
    req.summary = req.body.substring(0, 80)
    req.bookId = this.bookId
    req.rating = this.reviewRating
    const created = await ReadingBizService.createReview(req)
    this.submitting = false
    if (created !== undefined) {
      this.onDone('review')
      return
    }
    this.errorText = '保存失败，请稍后重试'
  }

  private async saveInspiration(): Promise<void> {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    if (this.inspirationContent.trim().length === 0) {
      this.errorText = '请写下灵感'
      return
    }
    this.submitting = true
    const req = new CreateInspirationRequest()
    req.title = `读《${this.bookTitle}》想到`
    req.content = this.inspirationContent.trim()
    req.bookId = this.bookId
    const created = await ReadingBizService.createInspiration(req)
    this.submitting = false
    if (created !== undefined) {
      this.onDone('inspiration')
      return
    }
    this.errorText = '保存失败，请稍后重试'
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text(this.sheetTitle())
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.mode === 'session') {
            Text('选择本次阅读时长，将计入今日阅读与年度报告。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: this.submitting ? '记录中…' : '记下 15 分钟',
              disabled: this.submitting,
              onTap: (): void => { void this.saveSession(15) }
            })
            AppButton({
              label: '记下 25 分钟',
              variant: 'secondary',
              disabled: this.submitting,
              onTap: (): void => { void this.saveSession(25) }
            })
            AppButton({
              label: '记下 45 分钟',
              variant: 'secondary',
              disabled: this.submitting,
              onTap: (): void => { void this.saveSession(45) }
            })
          } else if (this.mode === 'pages') {
            TextInput({ text: this.pageCountText, placeholder: '全书页数' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.pageCountText = v })
            TextInput({ text: this.currentPageText, placeholder: '当前读到第几页' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.currentPageText = v })
            AppButton({
              label: this.submitting ? '保存中…' : '更新页数进度',
              disabled: this.submitting,
              onTap: (): void => { void this.savePages() }
            })
          } else if (this.mode === 'note') {
            TextInput({ text: this.noteTitle, placeholder: '笔记标题' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.noteTitle = v })
            TextArea({ text: this.noteBody, placeholder: '写下这段阅读的思考…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(140)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.noteBody = v })
            Row({ space: 8 }) {
              ForEach(BookCategoryUtil.noteScenes(), (key: string) => {
                Text(BookCategoryUtil.sceneLabel(key))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.noteCoverKey === key ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.noteCoverKey === key ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.noteCoverKey = key })
              }, (key: string) => key)
            }
            AppButton({
              label: this.submitting ? '保存中…' : '保存笔记',
              disabled: this.submitting,
              onTap: (): void => { void this.saveNote() }
            })
          } else if (this.mode === 'quote') {
            TextArea({ text: this.quoteContent, placeholder: '摘录一句打动你的话…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(120)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.quoteContent = v })
            TextArea({ text: this.quoteComment, placeholder: '个人点评（可选）' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(80)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.quoteComment = v })
            AppButton({
              label: this.submitting ? '收藏中…' : '收藏到札语',
              disabled: this.submitting,
              onTap: (): void => { void this.saveQuote() }
            })
          } else if (this.mode === 'review') {
            Row({ space: 8 }) {
              ForEach(this.starOptions, (n: number) => {
                Text(`${n}星`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.reviewRating === n ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.reviewRating === n ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.reviewRating = n })
              }, (n: number) => `${n}`)
            }
            TextArea({ text: this.reviewBody, placeholder: '记录这本书给你的阅读体验…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(140)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.reviewBody = v })
            AppButton({
              label: this.submitting ? '保存中…' : '发布书评',
              disabled: this.submitting,
              onTap: (): void => { void this.saveReview() }
            })
          } else if (this.mode === 'inspiration') {
            TextArea({ text: this.inspirationContent, placeholder: '把阅读时冒出的想法记下来…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(160)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.inspirationContent = v })
            AppButton({
              label: this.submitting ? '保存中…' : '收入思考库',
              disabled: this.submitting,
              onTap: (): void => { void this.saveInspiration() }
            })
          } else {
            Text(`确认从书架移除「${this.bookTitle}」？移除后可随时再添加。`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            AppButton({
              label: '确认移除',
              onTap: (): void => { this.onDone('delete') }
            })
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.onClose() }
            })
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private sheetTitle(): string {
    if (this.mode === 'session') {
      return '记录本次阅读'
    }
    if (this.mode === 'pages') {
      return '更新阅读页数'
    }
    if (this.mode === 'note') {
      return '写一条笔记'
    }
    if (this.mode === 'quote') {
      return '摘录金句'
    }
    if (this.mode === 'review') {
      return '写书评'
    }
    if (this.mode === 'inspiration') {
      return '收藏灵感'
    }
    return '从书架移除'
  }
}
