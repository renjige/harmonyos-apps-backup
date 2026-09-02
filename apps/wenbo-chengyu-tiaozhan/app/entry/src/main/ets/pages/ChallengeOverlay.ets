import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { IdiomQuestion, OptionIndex } from '../models/IdiomModels'
import { IdiomBizService } from '../services/IdiomBizService'
import { IdiomNav } from '../services/IdiomNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct ChallengeOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State questions: IdiomQuestion[] = []
  @State current: IdiomQuestion = new IdiomQuestion()
  @State index: number = 0
  @State total: number = 0
  @State selected: number = -1
  @State phase: string = 'answering'
  @State remain: number = 15
  @State combo: number = 0
  @State score: number = 0
  @State toast: string = ''
  @State options: OptionIndex[] = OptionIndex.four()
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
    this.questions = await IdiomBizService.resolveQueue(IdiomNav.queue())
    this.sync()
    if (this.phase === 'answering') {
      this.startTimer()
    } else {
      this.scheduleAdvance(this.phase === 'correct' ? 800 : 1600)
    }
  }

  private sync(): void {
    const ids = IdiomNav.queue()
    this.total = ids.length
    this.index = IdiomNav.index()
    this.selected = IdiomNav.selected()
    this.phase = IdiomNav.phase()
    this.remain = AppStorage.get<number>('quizRemain') ?? 15
    this.combo = AppStorage.get<number>('quizCombo') ?? 0
    this.score = AppStorage.get<number>('quizScore') ?? 0
    if (this.index >= 0 && this.index < ids.length) {
      const found = IdiomBizService.findQuestion(this.questions, ids[this.index])
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
    IdiomNav.setSelected(i)
    void this.judge(i)
  }

  private async judge(choice: number): Promise<void> {
    if (this.phase !== 'answering') {
      return
    }
    this.clearTimer()
    const ok = choice === this.current.answerIndex
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
    IdiomNav.setPhase(this.phase)
    await ProgressStore.recordAnswer(this.current.theme, ok, add)
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
    IdiomNav.setIndex(this.index + 1)
    this.sync()
    this.startTimer()
  }

  private async finish(): Promise<void> {
    this.clearTimer()
    this.clearAdvance()
    const source = AppStorage.get<string>('quizSource') ?? 'daily'
    const maxCombo = AppStorage.get<number>('quizMaxCombo') ?? 0
    const correct = AppStorage.get<number>('quizCorrect') ?? 0
    if (source === 'daily') {
      await ProgressStore.finishDaily(this.score, maxCombo)
    } else if (source === 'campaign') {
      const need = Math.ceil(this.total * 0.8)
      if (correct >= need) {
        const ch = AppStorage.get<number>('quizChapter') ?? 1
        const lv = AppStorage.get<number>('quizLevel') ?? 1
        await ProgressStore.passGate(ch, lv, maxCombo)
      }
    }
    IdiomNav.openScore()
  }

  private tone(i: number): string {
    if (this.phase === 'correct' || this.phase === 'wrong') {
      if (i === this.current.answerIndex) {
        return Theme.colors().success
      }
      if (i === this.selected && i !== this.current.answerIndex) {
        return Theme.colors().danger
      }
    }
    if (this.selected === i) {
      return Theme.colors().brandPrimary
    }
    return Theme.colors().strokeStrong
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('退出')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => {
              this.clearTimer()
              this.clearAdvance()
              IdiomNav.close()
            })
          Blank()
          Text(`${this.index + 1} / ${this.total}`)
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

            Text(this.current.question)
              .fontSize(22 * ProgressStore.snapshot().fontScale)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(32)

            if (this.current.pinyin.length > 0) {
              Text(this.current.pinyin)
                .fontSize(13)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            Row({ space: 10 }) {
              this.OptionCard(0)
              this.OptionCard(1)
            }
            .width('100%')
            Row({ space: 10 }) {
              this.OptionCard(2)
              this.OptionCard(3)
            }
            .width('100%')

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
                onTap: () => this.next()
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
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,26,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  OptionCard(i: number) {
    Text(IdiomBizService.optionAt(this.current, i))
      .fontSize(15)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .padding(16)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .borderRadius(Theme.radius.md)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .border({ width: 1.5, color: this.tone(i) })
      .onClick(() => this.pick(i))
  }
}
