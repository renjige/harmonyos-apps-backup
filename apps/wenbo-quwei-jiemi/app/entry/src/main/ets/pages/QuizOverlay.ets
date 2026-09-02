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
  @State hintLevel: number = 0
  @State earnedPoints: number = 0
  @State celebrate: boolean = false
  @StorageLink('quizTick') tick: number = 0

  aboutToAppear(): void {
    void this.boot()
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
    this.hintLevel = QuizNav.hintLevel()
    if (this.index >= 0 && this.index < ids.length) {
      const found = QuizBizService.find(this.puzzles, ids[this.index])
      if (found !== undefined) {
        this.current = found
      }
    }
  }

  private tone(i: number): string {
    if (this.phase === 'correct' || this.phase === 'rethink' || this.hintLevel >= 3) {
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
    if (this.phase !== 'answering' || this.hintLevel >= 3) {
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
    const base = QuizBizService.wisdomPointsOf(this.current)
    const earned = ok ?
      ProgressStore.computeWisdomEarned(base, QuizNav.maxHintUsed()) : 0
    this.earnedPoints = earned
    await ProgressStore.recordAnswer(
      this.current.id,
      this.current.title,
      this.current.category,
      this.current.categoryLabel,
      ok,
      earned
    )
    if (ok) {
      this.celebrate = true
      QuizNav.setPhase('correct')
      this.phase = 'correct'
      setTimeout(() => { this.celebrate = false }, 700)
    } else {
      QuizNav.setPhase('rethink')
      this.phase = 'rethink'
    }
  }

  private retry(): void {
    QuizNav.setSelected(-1)
    QuizNav.setPhase('answering')
    QuizNav.setHintLevel(0)
    this.selected = -1
    this.phase = 'answering'
    this.hintLevel = 0
  }

  private advanceHint(): void {
    const next = this.hintLevel + 1
    if (next > 3) {
      return
    }
    QuizNav.setHintLevel(next)
    this.hintLevel = next
  }

  private hintActionLabel(): string {
    if (this.hintLevel === 0) {
      return '智慧提示'
    }
    if (this.hintLevel === 1) {
      return '查看解析'
    }
    if (this.hintLevel === 2) {
      return '揭晓答案'
    }
    return '再试一次'
  }

  private onHintAction(): void {
    if (this.hintLevel >= 3) {
      this.retry()
      return
    }
    this.advanceHint()
  }

  private next(): void {
    if (this.index + 1 >= this.total) {
      QuizNav.close()
      return
    }
    QuizNav.setIndex(this.index + 1)
    this.earnedPoints = 0
    this.sync()
  }

  private answerLetter(): string {
    if (this.current.answerIndex === 0) {
      return 'A'
    }
    if (this.current.answerIndex === 1) {
      return 'B'
    }
    if (this.current.answerIndex === 2) {
      return 'C'
    }
    return 'D'
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

      if (this.celebrate) {
        AppIcon({ name: 'check', iconSize: 28, color: Theme.colors().success })
          .margin({ top: 72 })
          .opacity(0.92)
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
      Text('答对了！')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.earnedPoints > 0 ? `+${this.earnedPoints} 智慧值` : '回答正确')
        .fontSize(16)
        .fontColor(Theme.colors().success)
        .width('100%')
      Column({ space: 8 }) {
        Text('解析')
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
      Blank()
      AppButton({
        label: ProgressStore.isFavorite(this.current.id) ? '已收藏' : '收藏这题',
        variant: 'secondary',
        onTap: () => { void ProgressStore.toggleFavorite(this.current.id) }
      })
      AppButton({
        label: this.index + 1 >= this.total ? '完成挑战' : '下一题',
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
      if (this.hintLevel >= 1 && this.current.hint.length > 0) {
        Column({ space: 6 }) {
          Text('智慧提示')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandAccent)
            .width('100%')
          Text(this.current.hint)
            .fontSize(15)
            .lineHeight(24)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .padding(16)
        .backgroundColor(Theme.colors().warningContainer)
        .borderRadius(18)
        .width('100%')
      }
      if (this.hintLevel >= 2 && this.current.explanation.length > 0) {
        Column({ space: 6 }) {
          Text('思路解析')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text(this.current.explanation)
            .fontSize(15)
            .lineHeight(24)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .padding(16)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(18)
        .width('100%')
      }
      if (this.hintLevel >= 3) {
        Column({ space: 6 }) {
          Text('正确答案')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().success)
            .width('100%')
          Text(`${this.answerLetter()}. ${QuizBizService.optionAt(this.current, this.current.answerIndex)}`)
            .fontSize(16)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        .padding(16)
        .backgroundColor(Theme.colors().successContainer)
        .borderRadius(18)
        .width('100%')
      }
      Blank()
      AppButton({
        label: this.hintActionLabel(),
        variant: this.hintLevel >= 3 ? 'primary' : 'secondary',
        onTap: () => this.onHintAction()
      })
      if (this.hintLevel < 3) {
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
