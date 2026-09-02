import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { OverlayShell } from './OverlayShell'
import { NoteFieldCard } from '../note/NoteFieldCard'
import { BookLibraryItem, ReadingSession } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct ReadingTimerPane {
  @Prop presetBookId: string = ''
  @Prop presetBookTitle: string = ''
  @State books: BookLibraryItem[] = []
  @State bookId: string = ''
  @State bookTitle: string = ''
  @State minutesPreset: number = 25
  @State remainingSec: number = 0
  @State running: boolean = false
  @State finished: boolean = false
  @State pagesText: string = ''
  @State moodNote: string = ''
  @State toastText: string = ''
  private timerId: number = -1
  onClose: () => void = () => {}
  onDone: () => void = () => {}

  aboutToAppear(): void {
    void this.bootstrap()
  }

  aboutToDisappear(): void {
    this.stopTimer()
  }

  private async bootstrap(): Promise<void> {
    this.books = await StudyStore.loadBooks()
    this.bookId = this.presetBookId
    this.bookTitle = this.presetBookTitle
    this.remainingSec = this.minutesPreset * 60
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private stopTimer(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  private startTimer(): void {
    if (this.running) {
      return
    }
    if (this.remainingSec <= 0) {
      this.remainingSec = this.minutesPreset * 60
    }
    this.running = true
    this.finished = false
    this.stopTimer()
    this.timerId = setInterval((): void => {
      if (this.remainingSec <= 1) {
        this.remainingSec = 0
        this.running = false
        this.finished = true
        this.stopTimer()
        return
      }
      this.remainingSec = this.remainingSec - 1
    }, 1000)
  }

  private pauseTimer(): void {
    this.running = false
    this.stopTimer()
  }

  private resetTimer(): void {
    this.pauseTimer()
    this.finished = false
    this.remainingSec = this.minutesPreset * 60
  }

  private pickPreset(m: number): void {
    if (this.running) {
      return
    }
    this.minutesPreset = m
    this.remainingSec = m * 60
  }

  private timeLabel(): string {
    const m = Math.floor(this.remainingSec / 60)
    const s = this.remainingSec % 60
    const ss = s < 10 ? `0${s}` : `${s}`
    const mm = m < 10 ? `0${m}` : `${m}`
    return `${mm}:${ss}`
  }

  private elapsedMinutes(): number {
    const total = this.minutesPreset * 60
    const used = total - this.remainingSec
    let m = Math.floor(used / 60)
    if (m < 1 && used > 0) {
      m = 1
    }
    return m
  }

  private pagesRead(): number {
    if (this.pagesText.trim().length === 0) {
      return 0
    }
    const n = Number.parseInt(this.pagesText, 10)
    if (n !== n || n < 0) {
      return 0
    }
    return n
  }

  private async saveSession(): Promise<void> {
    const session = ReadingSession.createNew()
    session.bookId = this.bookId
    session.bookTitle = this.bookTitle
    session.durationMinutes = this.finished ? this.minutesPreset : this.elapsedMinutes()
    session.pagesRead = this.pagesRead()
    session.moodNote = this.moodNote.trim()
    await StudyStore.saveSession(session)
    if (this.bookId.length > 0 && session.pagesRead > 0) {
      const book = await StudyStore.findBook(this.bookId)
      if (book !== undefined) {
        book.currentPage = book.currentPage + session.pagesRead
        if (book.totalPages > 0 && book.currentPage > book.totalPages) {
          book.currentPage = book.totalPages
        }
        if (book.totalPages > 0 && book.currentPage >= book.totalPages) {
          book.status = 'finished'
        }
        await StudyStore.saveBook(book)
      }
    }
    this.showToast('阅读场次已记录')
    this.onDone()
  }

  build() {
    Stack() {
      OverlayShell({
        title: '专注阅读',
        onClose: (): void => {
          this.pauseTimer()
          this.onClose()
        },
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
    Column({ space: Theme.space.s4 }) {
      Text('选择关联书籍（可选）')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      if (this.books.length === 0) {
        NoteFieldCard({
          label: '书名',
          value: this.bookTitle,
          placeholder: '手动输入书名',
          onChange: (v: string): void => { this.bookTitle = v }
        })
      } else {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.books, (b: BookLibraryItem) => {
              Text(b.title)
                .fontSize(Theme.type.caption)
                .fontColor(this.bookId === b.id ? '#FFFFFF' : Theme.colors().textPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.bookId === b.id ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.bookId = b.id
                  this.bookTitle = b.title
                })
            }, (b: BookLibraryItem) => b.id)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }

      Row({ space: 8 }) {
        this.PresetChip('15 分钟', 15)
        this.PresetChip('25 分钟', 25)
        this.PresetChip('45 分钟', 45)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Column({ space: 8 }) {
        AppIcon({ name: 'clock', iconSize: 40, color: Theme.colors().brandPrimary })
        Text(this.timeLabel())
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        Text(this.running ? '专注中…' : (this.finished ? '本轮完成' : '点击开始专注阅读'))
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
      }
      .width('100%')
      .padding(24)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(16)

      if (!this.finished) {
        Row({ space: 8 }) {
          AppButton({
            label: this.running ? '暂停' : '开始',
            onTap: (): void => {
              if (this.running) {
                this.pauseTimer()
              } else {
                this.startTimer()
              }
            }
          })
            .layoutWeight(1)
          AppButton({
            label: '重置',
            variant: 'secondary',
            onTap: (): void => { this.resetTimer() }
          })
            .layoutWeight(1)
        }
        .width('100%')
      }

      if (this.finished || (!this.running && this.remainingSec < this.minutesPreset * 60)) {
        NoteFieldCard({
          label: '本次阅读页数',
          value: this.pagesText,
          placeholder: '可选',
          numberOnly: true,
          onChange: (v: string): void => { this.pagesText = v }
        })
        NoteFieldCard({
          label: '阅读感受',
          value: this.moodNote,
          placeholder: '可选，一两句即可',
          onChange: (v: string): void => { this.moodNote = v }
        })
        AppButton({
          label: '保存阅读记录',
          onTap: (): void => { void this.saveSession() }
        })
      }
    }
    .width('100%')
  }

  @Builder
  PresetChip(label: string, minutes: number) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.minutesPreset === minutes ? '#FFFFFF' : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.minutesPreset === minutes ?
        Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.pickPreset(minutes) })
  }
}
