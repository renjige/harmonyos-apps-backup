import { Theme } from '../components/design-system/Theme'
import { PhotoHeroStack } from '../components/design-system/PhotoHeroStack'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { BookItem, CreateCheckinRequest, CreateQuoteRequest } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { AuthService } from '../services/AuthService'

/** 灯下共读：氛围计时结束后必须写下「今日一句」，不是普通打卡计时器 */
@Component
export struct LampSessionPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State phase: string = 'idle'
  @State planned: number = 25
  @State remain: number = 25 * 60
  @State books: BookItem[] = []
  @State selectedBookId: string = ''
  @State selectedBookTitle: string = ''
  @State sentence: string = ''
  @State submitting: boolean = false
  @State errorText: string = ''
  private tickId: number = -1

  aboutToAppear(): void {
    void this.loadBooks()
  }

  aboutToDisappear(): void {
    this.clearTick()
  }

  private async loadBooks(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.books = []
      return
    }
    const all = await ReadingBizService.loadBooks(this.currentUsername)
    const reading: BookItem[] = []
    for (const b of all) {
      if (b.readStatus === 'reading') {
        reading.push(b)
      }
    }
    this.books = reading
  }

  private clearTick(): void {
    if (this.tickId >= 0) {
      clearInterval(this.tickId)
      this.tickId = -1
    }
  }

  private clockText(): string {
    const m = Math.floor(this.remain / 60)
    const s = this.remain % 60
    const mm = m < 10 ? `0${m}` : `${m}`
    const ss = s < 10 ? `0${s}` : `${s}`
    return `${mm}:${ss}`
  }

  private usedMinutes(): number {
    const used = this.planned * 60 - this.remain
    const mins = Math.floor(used / 60)
    if (mins < 1) {
      return 1
    }
    return mins
  }

  private choose(mins: number): void {
    if (this.phase !== 'idle') {
      return
    }
    this.planned = mins
    this.remain = mins * 60
  }

  private pickBook(item: BookItem): void {
    if (this.selectedBookId === item.id) {
      this.selectedBookId = ''
      this.selectedBookTitle = ''
      return
    }
    this.selectedBookId = item.id
    this.selectedBookTitle = item.title
  }

  private startSession(): void {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    this.remain = this.planned * 60
    this.phase = 'running'
    this.errorText = ''
    this.clearTick()
    this.tickId = setInterval((): void => {
      if (this.remain <= 1) {
        this.remain = 0
        this.enterCapture()
        return
      }
      this.remain = this.remain - 1
    }, 1000)
  }

  private enterCapture(): void {
    this.clearTick()
    this.phase = 'capture'
    this.sentence = ''
  }

  private cancelSession(): void {
    this.clearTick()
    this.phase = 'idle'
    this.remain = this.planned * 60
    this.sentence = ''
    this.errorText = ''
  }

  private async finishWithSentence(): Promise<void> {
    if (this.sentence.trim().length === 0) {
      this.errorText = '灯下共读需要留下今日一句，才能记入书房'
      return
    }
    if (this.submitting) {
      return
    }
    this.submitting = true
    this.errorText = ''
    const mins = this.usedMinutes()
    const checkin = new CreateCheckinRequest()
    checkin.title = '灯下共读'
    checkin.readingMinutes = mins
    checkin.bookId = this.selectedBookId
    checkin.comment = this.sentence.trim()
    const quote = new CreateQuoteRequest()
    quote.title = '今日一句'
    quote.content = this.sentence.trim()
    quote.source = this.selectedBookTitle.length > 0 ? this.selectedBookTitle : '灯下共读'
    quote.bookId = this.selectedBookId
    quote.comment = `灯下共读 ${mins} 分钟`
    const tags: string[] = []
    tags.push('灯下共读')
    quote.tags = tags
    const savedQuote = await ReadingBizService.createQuote(quote)
    if (savedQuote === undefined) {
      this.submitting = false
      this.errorText = '今日一句保存失败，尚未记入时长'
      return
    }
    const savedCheckin = await ReadingBizService.createCheckin(checkin)
    this.submitting = false
    if (savedCheckin === undefined) {
      this.errorText = '今日一句已保存，打卡时长未记入，请到打卡页补记'
      this.onChanged()
      return
    }
    this.onChanged()
    this.onClose()
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
        .onClick((): void => {
          this.clearTick()
          this.onClose()
        })
        Text('灯下共读')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          PhotoHeroStack({
            coverKey: 'lamp_session',
            heroHeight: 168,
            title: '把这一段阅读收成一句自己的话',
            subtitle: '计时只是陪读。结束时必须写下今日一句，才记入打卡与札语。'
          })

          if (this.phase === 'idle') {
            this.IdleBody()
          } else if (this.phase === 'running') {
            this.RunningBody()
          } else {
            this.CaptureBody()
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
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  IdleBody() {
    Column({ space: Theme.space.s3 }) {
      Text('共读时长')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.MinuteChip(15)
        this.MinuteChip(25)
        this.MinuteChip(45)
      }
      .width('100%')
      if (this.books.length > 0) {
        Text('正在读的书（可选）')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.books, (item: BookItem) => {
          Text(item.title)
            .fontSize(Theme.type.caption)
            .fontColor(this.selectedBookId === item.id ?
              Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 10, bottom: 10 })
            .width('100%')
            .backgroundColor(this.selectedBookId === item.id ?
              Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { this.pickBook(item) })
        }, (item: BookItem) => item.id)
      }
      AppButton({
        label: `开始 ${this.planned} 分钟灯下共读`,
        onTap: (): void => { this.startSession() }
      })
    }
    .width('100%')
  }

  @Builder
  MinuteChip(mins: number) {
    Text(`${mins} 分钟`)
      .fontSize(Theme.type.caption)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.planned === mins ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.planned === mins ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .onClick((): void => { this.choose(mins) })
  }

  @Builder
  RunningBody() {
    Column({ space: Theme.space.s4 }) {
      Text(this.clockText())
        .fontSize(Theme.type.display)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(this.selectedBookTitle.length > 0 ? `灯火未灭 · ${this.selectedBookTitle}` : '灯火未灭，先把这一页读完')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .textAlign(TextAlign.Center)
      AppButton({
        label: '结束并写下今日一句',
        onTap: (): void => { this.enterCapture() }
      })
      AppButton({
        label: '取消本次（不记录）',
        variant: 'secondary',
        onTap: (): void => { this.cancelSession() }
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  CaptureBody() {
    Column({ space: Theme.space.s3 }) {
      Text(`共读约 ${this.usedMinutes()} 分钟`)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Text('今日一句')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      TextArea({ text: this.sentence, placeholder: '写下此刻最想留下的一句…' })
        .width('100%')
        .height(120)
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textSecondary)
        .caretColor(Theme.colors().brandPrimary)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .onChange((v: string) => { this.sentence = v })
      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
      }
      AppButton({
        label: this.submitting ? '保存中…' : '收进札语并记入时长',
        disabled: this.submitting,
        onTap: (): void => { void this.finishWithSentence() }
      })
    }
    .width('100%')
  }
}
