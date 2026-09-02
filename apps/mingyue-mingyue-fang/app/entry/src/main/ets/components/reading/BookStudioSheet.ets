import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CreateNoteRequest, CreateQuoteRequest, CreateReadingLogRequest } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { AuthService } from '../../services/AuthService'

/** 书籍详情内的阅读时长 / 笔记 / 札语 / 删除确认 */
@Component
export struct BookStudioSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: string = ''
  @Prop bookId: string = ''
  @Prop bookTitle: string = ''
  onClose: () => void = () => {}
  onDone: (kind: string) => void = (kind: string) => { if (kind.length < 0) { return } }
  onRequireAuth: () => void = () => {}
  @State noteTitle: string = ''
  @State noteBody: string = ''
  @State quoteContent: string = ''
  @State submitting: boolean = false
  @State errorText: string = ''

  aboutToAppear(): void {
    this.resetForm()
  }

  private resetForm(): void {
    this.noteTitle = `${this.bookTitle} 笔记`
    this.noteBody = ''
    this.quoteContent = ''
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
      this.errorText = '请填写明悟内容'
      return
    }
    this.submitting = true
    const req = new CreateQuoteRequest()
    req.title = '明悟摘录'
    req.content = this.quoteContent.trim()
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
          } else if (this.mode === 'note') {
            TextInput({ text: this.noteTitle, placeholder: '笔记标题' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.noteTitle = v })
            TextArea({ text: this.noteBody, placeholder: '写下这段阅读的思考…' })
              .width('100%')
              .height(160)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.noteBody = v })
            AppButton({
              label: this.submitting ? '保存中…' : '保存笔记',
              disabled: this.submitting,
              onTap: (): void => { void this.saveNote() }
            })
          } else if (this.mode === 'quote') {
            TextArea({ text: this.quoteContent, placeholder: '摘录一句打动你的话…' })
              .width('100%')
              .height(160)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.quoteContent = v })
            AppButton({
              label: this.submitting ? '收藏中…' : '收藏至明悟',
              disabled: this.submitting,
              onTap: (): void => { void this.saveQuote() }
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
    if (this.mode === 'note') {
      return '写一条笔记'
    }
    if (this.mode === 'quote') {
      return '摘录明悟'
    }
    return '从书架移除'
  }
}
