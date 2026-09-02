import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { QuizOptionRow } from '../components/treasure/TreasureCards'
import { TreasureQuestion } from '../models/TreasureModels'
import { TreasureBizService } from '../services/TreasureBizService'
import { TreasureNav } from '../services/TreasureNav'
import { VaultStore } from '../services/VaultStore'

@Component
export struct QuizOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State questions: TreasureQuestion[] = []
  @State current: TreasureQuestion = new TreasureQuestion()
  @State index: number = 0
  @State total: number = 0
  @State selected: number = -1
  @State phase: string = 'answering'
  @State earnedPoints: number = 0
  @State celebrate: boolean = false
  @StorageLink('treasureTick') tick: number = 0

  aboutToAppear(): void {
    void this.boot()
  }

  async boot(): Promise<void> {
    this.questions = await TreasureBizService.loadQuestions('', false)
    this.sync()
  }

  private sync(): void {
    const ids = TreasureNav.queue()
    this.total = ids.length
    this.index = TreasureNav.index()
    this.selected = TreasureNav.selected()
    this.phase = TreasureNav.phase()
    if (this.index >= 0 && this.index < ids.length) {
      const found = TreasureBizService.findQuestionInList(this.questions, ids[this.index])
      if (found !== undefined) {
        this.current = found
      }
    }
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
    TreasureNav.setSelected(i)
    this.selected = i
  }

  private async submit(): Promise<void> {
    if (this.selected < 0) {
      return
    }
    const ok = this.selected === this.current.answerIndex
    const earned = ok ? TreasureBizService.pointsPerQuestion() : 0
    this.earnedPoints = earned
    await VaultStore.recordAnswer(
      this.current.id,
      this.current.question,
      this.current.categoryLabel,
      ok,
      earned
    )
    if (ok) {
      this.celebrate = true
      TreasureNav.setPhase('correct')
      this.phase = 'correct'
      setTimeout(() => { this.celebrate = false }, 700)
    } else {
      TreasureNav.setPhase('rethink')
      this.phase = 'rethink'
    }
  }

  private retry(): void {
    TreasureNav.setSelected(-1)
    TreasureNav.setPhase('answering')
    this.selected = -1
    this.phase = 'answering'
  }

  private next(): void {
    if (this.index + 1 >= this.total) {
      TreasureNav.close()
      return
    }
    TreasureNav.setIndex(this.index + 1)
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
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => TreasureNav.close())
          Blank()
          Text(`第 ${this.index + 1}/${this.total} 题`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

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
    Column({ space: Theme.space.s4 }) {
      Text(this.current.categoryLabel)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandAccent)
        .width('100%')
      Text(this.current.question)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(32)
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
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8, top: Theme.space.s2 })
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  CorrectPane() {
    Column({ space: Theme.space.s4 }) {
      Text('答对了！')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.earnedPoints > 0 ? `+${this.earnedPoints} 智慧积分` : '回答正确')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().success)
        .width('100%')
      Column({ space: Theme.space.s2 }) {
        Text('解析')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.current.explanation.length > 0 ? this.current.explanation : this.current.tip)
          .fontSize(Theme.type.body)
          .lineHeight(26)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(Theme.space.s5)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .width('100%')
      Blank()
      AppButton({
        label: this.index + 1 >= this.total ? '完成今日闯关' : '下一题',
        onTap: () => this.next()
      })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8, top: Theme.space.s2 })
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  RethinkPane() {
    Column({ space: Theme.space.s4 }) {
      Text('再想想，答案就在细节里。')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(32)
        .width('100%')
      if (this.current.tip.length > 0) {
        Column({ space: Theme.space.s2 }) {
          Text('智慧提示')
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandAccent)
            .width('100%')
          Text(this.current.tip)
            .fontSize(Theme.type.body)
            .lineHeight(24)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().warningContainer)
        .borderRadius(Theme.radius.lg)
        .width('100%')
      }
      Column({ space: Theme.space.s2 }) {
        Text('正确答案')
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().success)
          .width('100%')
        Text(`${this.answerLetter()}. ${TreasureBizService.optionAt(this.current, this.current.answerIndex)}`)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      .padding(Theme.space.s4)
      .backgroundColor(Theme.colors().successContainer)
      .borderRadius(Theme.radius.lg)
      .width('100%')
      Blank()
      AppButton({ label: '再试一次', onTap: () => this.retry() })
      AppButton({
        label: this.index + 1 >= this.total ? '完成' : '下一题',
        variant: 'secondary',
        onTap: () => this.next()
      })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8, top: Theme.space.s2 })
    .layoutWeight(1)
    .width('100%')
  }
}
