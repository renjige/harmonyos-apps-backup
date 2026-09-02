import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { QuizOptionRow } from '../components/poetry/PoetryCards'
import { QuestionItem } from '../models/PoetryModels'
import { PoetryBizService } from '../services/PoetryBizService'
import { PoetryNav } from '../services/PoetryNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct ChallengeOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State questions: QuestionItem[] = []
  @State current: QuestionItem = new QuestionItem()
  @State index: number = 0
  @State total: number = 0
  @State selected: number = -1
  @State fillText: string = ''
  @State phase: string = 'answering'
  @State remain: number = 15
  @State combo: number = 0
  @State score: number = 0
  @State toast: string = ''
  private timerId: number = -1
  private advanceId: number = -1

  aboutToAppear(): void {
    void this.boot()
  }

  aboutToDisappear(): void {
    this.clearTimer()
    this.clearAdvance()
  }

  async boot(): Promise<void> {
    this.questions = await PoetryBizService.resolveQueue(PoetryNav.queue())
    this.sync()
    if (this.phase === 'answering') {
      this.startTimer()
    } else {
      this.scheduleAdvance(this.phase === 'correct' ? 800 : 1600)
    }
  }

  private sync(): void {
    const ids = PoetryNav.queue()
    this.total = ids.length
    this.index = PoetryNav.index()
    this.selected = PoetryNav.selected()
    this.phase = PoetryNav.phase()
    this.remain = AppStorage.get<number>('quizRemain') ?? 15
    this.combo = AppStorage.get<number>('quizCombo') ?? 0
    this.score = AppStorage.get<number>('quizScore') ?? 0
    this.fillText = ''
    if (this.index >= 0 && this.index < ids.length) {
      const found = PoetryBizService.findQuestion(this.questions, ids[this.index])
      if (found !== undefined) {
        this.current = found
      }
    }
  }

  private startTimer(): void {
    this.clearTimer()
    this.timerId = setInterval(() => {
      if (this.phase !== 'answering') {
        return
      }
      if (this.remain <= 1) {
        this.remain = 0
        AppStorage.setOrCreate('quizRemain', 0)
        void this.judge(-1)
        return
      }
      this.remain = this.remain - 1
      AppStorage.setOrCreate('quizRemain', this.remain)
    }, 1000)
  }

  private clearTimer(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  private clearAdvance(): void {
    if (this.advanceId >= 0) {
      clearTimeout(this.advanceId)
      this.advanceId = -1
    }
  }

  private scheduleAdvance(ms: number): void {
    this.clearAdvance()
    this.advanceId = setTimeout(() => {
      this.advanceId = -1
      this.next()
    }, ms)
  }

  private pick(i: number): void {
    if (this.phase !== 'answering') {
      return
    }
    this.selected = i
    PoetryNav.setSelected(i)
    if (this.current.questionType !== 'fill') {
      void this.judge(i)
    }
  }

  private isCorrect(choice: number): boolean {
    if (this.current.questionType === 'fill' && this.fillText.trim().length > 0) {
      return this.fillText.trim() === this.current.answerText.trim()
    }
    return choice === this.current.answerIndex
  }

  private submitFill(): void {
    if (this.phase !== 'answering') {
      return
    }
    void this.judge(this.selected)
  }

  private async judge(choice: number): Promise<void> {
    if (this.phase !== 'answering') {
      return
    }
    this.clearTimer()
    const ok = this.isCorrect(choice)
    let add = 0
    if (ok) {
      const nextCombo = this.combo + 1
      add = Math.floor(10 * (10 + nextCombo) / 10)
      this.combo = nextCombo
      this.score = this.score + add
      AppStorage.setOrCreate('quizCombo', this.combo)
      AppStorage.setOrCreate('quizScore', this.score)
      const prevMax = AppStorage.get<number>('quizMaxCombo') ?? 0
      if (this.combo > prevMax) {
        AppStorage.setOrCreate('quizMaxCombo', this.combo)
      }
      const prevCorrect = AppStorage.get<number>('quizCorrect') ?? 0
      AppStorage.setOrCreate('quizCorrect', prevCorrect + 1)
      this.phase = 'correct'
      this.toast = '答对'
    } else {
      this.combo = 0
      AppStorage.setOrCreate('quizCombo', 0)
      this.phase = 'wrong'
      this.toast = choice < 0 ? '时间到' : '再想想'
    }
    PoetryNav.setPhase(this.phase)
    await ProgressStore.recordAnswer(ok, add)
    this.scheduleAdvance(ok ? 800 : 1600)
    setTimeout(() => { this.toast = '' }, 700)
  }

  private next(): void {
    this.clearAdvance()
    this.clearTimer()
    if (this.index + 1 >= this.total) {
      void this.finish()
      return
    }
    PoetryNav.setIndex(this.index + 1)
    this.sync()
    this.startTimer()
  }

  private async finish(): Promise<void> {
    this.clearTimer()
    this.clearAdvance()
    const maxCombo = AppStorage.get<number>('quizMaxCombo') ?? 0
    const correct = AppStorage.get<number>('quizCorrect') ?? 0
    await ProgressStore.finishDaily(this.score, maxCombo, correct, this.total)
    PoetryNav.openScore()
  }

  private tone(i: number): string {
    if (this.phase === 'correct' || this.phase === 'wrong') {
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

  private promptExtra(): string {
    if (this.current.questionType === 'match' && this.current.matchLeft.length > 0) {
      return this.current.matchLeft
    }
    return ''
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('退出')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => {
              this.clearTimer()
              this.clearAdvance()
              PoetryNav.close()
            })
          Blank()
          Text(`${this.index + 1} / ${this.total}  ·  ${PoetryBizService.typeLabel(this.current.questionType)}`)
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Blank()
          Text(`${this.remain}s`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.remain <= 5 ? Theme.colors().danger : Theme.colors().brandPrimary)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 8 })

        Scroll() {
          Column({ space: 12 }) {
            Text(`得分 ${this.score}  ·  连击 ${this.combo}`)
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            Text(this.current.prompt)
              .fontSize(22 * ProgressStore.snapshot().fontScale)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(32)

            if (this.promptExtra().length > 0) {
              Text(this.promptExtra())
                .fontSize(16)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            if (this.current.questionType === 'fill') {
              TextInput({ text: this.fillText, placeholder: '填写空缺字句' })
                .onChange((v: string) => { this.fillText = v })
            }

            QuizOptionRow({ label: 'A', text: this.current.optionA, tone: this.tone(0), onPick: (): void => this.pick(0) })
            QuizOptionRow({ label: 'B', text: this.current.optionB, tone: this.tone(1), onPick: (): void => this.pick(1) })
            QuizOptionRow({ label: 'C', text: this.current.optionC, tone: this.tone(2), onPick: (): void => this.pick(2) })
            QuizOptionRow({ label: 'D', text: this.current.optionD, tone: this.tone(3), onPick: (): void => this.pick(3) })

            if (this.current.questionType === 'fill') {
              AppButton({
                label: '提交答案',
                disabled: this.fillText.trim().length === 0,
                onTap: (): void => this.submitFill()
              })
            }

            if (this.phase !== 'answering') {
              Text(this.current.explanation)
                .fontSize(14)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
                .padding(12)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.sm)
              AppButton({
                label: this.index + 1 >= this.total ? '查看成绩' : '下一题',
                onTap: (): void => this.next()
              })
            }
          }
          .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(14)
          .fontColor('#F8F4ED')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(28,40,51,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
