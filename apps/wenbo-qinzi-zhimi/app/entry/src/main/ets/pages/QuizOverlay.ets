import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { QuizOptionRow } from '../components/design-system/PuzzleCards'
import { PuzzleItem } from '../models/PuzzleModels'
import { QuizBizService } from '../services/QuizBizService'
import { QuizNav } from '../services/QuizNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct QuizOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State puzzles: PuzzleItem[] = []
  @State current: PuzzleItem = new PuzzleItem()
  @State index: number = 0
  @State total: number = 0
  @State selected: number = -1
  @State phase: string = 'answering'
  @State showHint: boolean = false
  @State starOn: boolean = false
  @State favoriteOn: boolean = false
  @State toastText: string = ''
  @StorageLink('quizTick') tick: number = 0

  aboutToAppear(): void {
    void this.boot()
  }

  onPageShow(): void {
    this.sync()
  }

  async boot(): Promise<void> {
    this.puzzles = await QuizBizService.loadPuzzles()
    this.sync()
  }

  private sync(): void {
    const ids = QuizNav.queue()
    this.total = ids.length
    this.index = QuizNav.index()
    this.selected = QuizNav.selected()
    this.phase = QuizNav.phase()
    this.showHint = AppStorage.get<boolean>('quizShowHint') === true
    if (this.index >= 0 && this.index < ids.length) {
      const found = QuizBizService.find(this.puzzles, ids[this.index])
      if (found !== undefined) {
        this.current = found
        this.favoriteOn = ProgressStore.isFavorite(found.id)
      }
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async handleFavorite(): Promise<void> {
    if (this.current.id.length === 0) {
      return
    }
    await ProgressStore.toggleFavorite(this.current.id, this.current.title)
    this.favoriteOn = ProgressStore.isFavorite(this.current.id)
    this.showToast(this.favoriteOn ? '已收藏' : '已取消收藏')
  }

  private tone(i: number): string {
    if (this.phase === 'correct' || this.phase === 'rethink') {
      if (i === this.current.answerIndex) {
        return 'correct'
      }
      if (i === this.selected && i !== this.current.answerIndex) {
        return 'wrong'
      }
    }
    if (this.selected === i) {
      return 'selected'
    }
    return 'idle'
  }

  private pick(i: number): void {
    if (this.phase !== 'answering') {
      return
    }
    QuizNav.setSelected(i)
    this.selected = i
  }

  private async submit(): Promise<void> {
    if (this.selected < 0) {
      return
    }
    const ok = this.selected === this.current.answerIndex
    await ProgressStore.recordAnswer(
      this.current.id,
      this.current.title,
      this.current.category,
      this.current.categoryLabel,
      ok
    )
    ProgressStore.sync()
    QuizNav.bump()
    if (ok) {
      QuizNav.addSessionCorrect()
      this.starOn = true
      QuizNav.setPhase('correct')
      this.phase = 'correct'
      setTimeout(() => { this.starOn = false }, 700)
    } else {
      QuizNav.setPhase('rethink')
      this.phase = 'rethink'
    }
  }

  private retry(): void {
    QuizNav.setSelected(-1)
    QuizNav.setPhase('answering')
    AppStorage.setOrCreate('quizShowHint', false)
    this.selected = -1
    this.phase = 'answering'
    this.showHint = false
  }

  private hint(): void {
    AppStorage.setOrCreate('quizShowHint', true)
    this.showHint = true
  }

  private next(): void {
    if (this.index + 1 >= this.total) {
      QuizNav.openSummary(QuizNav.sessionCorrect(), this.total)
      return
    }
    QuizNav.setIndex(this.index + 1)
    this.sync()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('返回')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => QuizNav.close())
          Blank()
          Text(`第 ${this.index + 1} 题`)
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 8 })

        if (this.phase === 'correct') {
          this.CorrectPane()
        } else if (this.phase === 'rethink') {
          this.RethinkPane()
        } else {
          this.AnswerPane()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.starOn) {
        AppIcon({ name: 'ai', iconSize: 28, color: Theme.colors().brandAccent })
          .margin({ top: 72 })
          .opacity(0.92)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(30,42,58,0.88)')
          .borderRadius(20)
          .margin({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AnswerPane() {
    Column({ space: 16 }) {
      Text(this.current.question)
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(34)
        .width('100%')
      QuizOptionRow({ label: 'A', text: this.current.optionA, tone: this.tone(0), onPick: () => this.pick(0) })
      QuizOptionRow({ label: 'B', text: this.current.optionB, tone: this.tone(1), onPick: () => this.pick(1) })
      QuizOptionRow({ label: 'C', text: this.current.optionC, tone: this.tone(2), onPick: () => this.pick(2) })
      QuizOptionRow({ label: 'D', text: this.current.optionD, tone: this.tone(3), onPick: () => this.pick(3) })
      Blank()
      AppButton({
        label: '提交答案',
        disabled: this.selected < 0,
        onTap: () => { void this.submit() }
      })
    }
    .padding({ left: 20, right: 20, bottom: 28, top: 8 })
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  CorrectPane() {
    Column({ space: 14 }) {
      Text('太棒啦！')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('回答正确')
        .fontSize(16)
        .fontColor(Theme.colors().success)
        .width('100%')
      Column({ space: 8 }) {
        Text('为什么？')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.current.explanation)
          .fontSize(16)
          .lineHeight(26)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(18)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(22)
      .width('100%')
      if (this.current.knowledge && this.current.knowledge.length > 0 && this.current.knowledge !== this.current.explanation) {
        Column({ space: 8 }) {
          Text('知识小卡片')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.current.knowledge)
            .fontSize(15)
            .lineHeight(24)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .padding(18)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(22)
        .width('100%')
      }
      Blank()
      Row() {
        AppButton({
          label: this.favoriteOn ? '已收藏' : '收藏这题',
          variant: 'secondary',
          onTap: (): void => { void this.handleFavorite() }
        })
      }
      .width('100%')
      .onClick((): void => { void this.handleFavorite() })
      AppButton({
        label: this.index + 1 >= this.total ? '完成今日挑战' : '下一题',
        onTap: () => this.next()
      })
    }
    .padding({ left: 20, right: 20, bottom: 28, top: 8 })
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  RethinkPane() {
    Column({ space: 14 }) {
      Text('再想想，也许还有一个角度。')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(32)
        .width('100%')
      QuizOptionRow({ label: 'A', text: this.current.optionA, tone: this.tone(0), onPick: () => {} })
      QuizOptionRow({ label: 'B', text: this.current.optionB, tone: this.tone(1), onPick: () => {} })
      QuizOptionRow({ label: 'C', text: this.current.optionC, tone: this.tone(2), onPick: () => {} })
      QuizOptionRow({ label: 'D', text: this.current.optionD, tone: this.tone(3), onPick: () => {} })
      if (this.showHint) {
        Text(this.current.hint)
          .fontSize(15)
          .lineHeight(24)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(16)
          .backgroundColor(Theme.colors().warningContainer)
          .borderRadius(18)
          .width('100%')
      }
      Blank()
      AppButton({
        label: this.showHint ? '再试一次' : '看看提示',
        variant: this.showHint ? 'primary' : 'secondary',
        onTap: () => {
          if (this.showHint) {
            this.retry()
          } else {
            this.hint()
          }
        }
      })
      if (!this.showHint) {
        AppButton({
          label: '再试一次',
          variant: 'ghost',
          onTap: () => this.retry()
        })
      }
    }
    .padding({ left: 20, right: 20, bottom: 28, top: 8 })
    .layoutWeight(1)
    .width('100%')
  }
}
