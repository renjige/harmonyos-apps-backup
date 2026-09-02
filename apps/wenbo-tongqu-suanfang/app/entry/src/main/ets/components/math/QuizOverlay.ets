import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MathNumPad } from './MathNumPad'
import { MathChoicePad } from './MathChoicePad'
import { MathQuestion } from '../../models/MathModels'
import { MathEngine } from '../../services/MathEngine'
import { MathFeedbackService } from '../../services/MathFeedbackService'

@Component
export struct QuizOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '今日挑战'
  @Prop total: number = 10
  @Prop @Watch('onQuizKeyChange') quizKey: string = ''
  @Prop index: number = 0
  @Prop question: MathQuestion = new MathQuestion()
  @Prop expression: string = ''
  @Prop story: string = ''
  @Prop hint: string = ''
  @Prop qType: string = 'fill'
  @Prop choiceA: string = ''
  @Prop choiceB: string = ''
  @Prop choiceC: string = ''
  @Prop favOn: boolean = false
  @Prop motion: boolean = true
  @Prop sound: boolean = true
  @Prop limitSec: number = 0
  @State inputText: string = ''
  @State feedback: string = ''
  @State feedbackOk: boolean = false
  @State starScale: number = 1
  @State exprScale: number = 1
  @State shakeX: number = 0
  @State progressPct: number = 0
  @State busy: boolean = false
  @State remain: number = 0
  @State padSeq: number = 0
  onClose: () => void = () => {}
  onAnswer: (ok: boolean, typed: string) => void = (_ok: boolean, _typed: string) => {}
  onToggleFav: () => void = () => {}
  private timerOn: boolean = false

  aboutToAppear(): void {
    this.remain = this.limitSec
    this.syncProgress()
    if (this.limitSec > 0 && !this.timerOn) {
      this.timerOn = true
      this.tickLoop()
    }
  }

  aboutToDisappear(): void {
    this.timerOn = false
  }

  onQuizKeyChange(): void {
    this.inputText = ''
    this.feedback = ''
    this.busy = false
    this.padSeq = this.padSeq + 1
    this.syncProgress()
  }

  private tickLoop(): void {
    setTimeout(() => {
      if (!this.timerOn) {
        return
      }
      if (this.remain > 0 && !this.busy) {
        this.remain = this.remain - 1
        if (this.remain <= 0) {
          this.finish(false, '超时')
          return
        }
      }
      this.tickLoop()
    }, 1000)
  }

  private syncProgress(): void {
    const pct = this.progress()
    if (this.motion) {
      animateTo({ duration: 280, curve: Curve.EaseOut }, () => {
        this.progressPct = pct
      })
    } else {
      this.progressPct = pct
    }
  }

  private progress(): number {
    if (this.total <= 0) {
      return 0
    }
    return (this.index + 1) / this.total
  }

  private useChoicePad(): boolean {
    return this.choiceA.length > 0 && this.choiceB.length > 0
  }

  private appendDigit(v: string): void {
    if (this.busy || this.inputText.length >= 4) {
      return
    }
    MathFeedbackService.playTap(this.sound)
    this.inputText = `${this.inputText}${v}`
  }

  private submitFill(): void {
    if (this.busy || this.inputText.length === 0) {
      return
    }
    const typed = Number.parseInt(this.inputText)
    this.finish(typed === this.question.answer, this.inputText)
  }

  private submitPick(value: number): void {
    if (this.busy) {
      return
    }
    this.finish(value === this.question.answer, `${value}`)
  }

  private finish(ok: boolean, typed: string): void {
    if (this.busy) {
      return
    }
    this.busy = true
    this.feedbackOk = ok
    if (ok) {
      this.feedback = '答对啦！'
      MathFeedbackService.playCorrect(this.sound)
      if (this.motion) {
        this.starScale = 0.65
        this.exprScale = 1.04
        animateTo({ duration: 240, curve: Curve.EaseOut }, () => {
          this.starScale = 1.2
          this.exprScale = 1
        })
      }
    } else {
      this.feedback = `再想一想，答案是 ${MathEngine.displayAnswer(this.question)}`
      MathFeedbackService.playGentle(this.sound)
      if (this.motion) {
        this.shakeX = -8
        animateTo({ duration: 70, curve: Curve.EaseInOut }, () => { this.shakeX = 8 })
        setTimeout(() => {
          animateTo({ duration: 70, curve: Curve.EaseInOut }, () => { this.shakeX = 0 })
        }, 80)
      }
    }
    setTimeout(() => {
      this.onAnswer(ok, typed)
      this.inputText = ''
      this.feedback = ''
      this.starScale = 1
      this.shakeX = 0
      this.busy = false
      this.syncProgress()
    }, this.motion ? 950 : 520)
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        if (this.limitSec > 0) {
          Text(`${this.remain}s`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width(44)
            .textAlign(TextAlign.Center)
        } else {
          Blank().width(44)
        }
      }
      .width('100%')
      .padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })

      Column({ space: Theme.space.s2 }) {
        Text(`第 ${this.index + 1} / ${this.total} 题`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Stack({ alignContent: Alignment.Start }) {
          Row().width('100%').height(8).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.pill)
          Row()
            .width(`${Math.floor(this.progressPct * 100)}%`)
            .height(8)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .height(8)
      }
      .padding({ left: Theme.space.s6, right: Theme.space.s6, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.story.length > 0) {
            Text(this.story)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .textAlign(TextAlign.Center)
          }
          if (this.hint.length > 0) {
            Text(this.hint)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textTertiary : Theme.colors().textTertiary)
              .width('100%')
              .textAlign(TextAlign.Center)
          }
          Text(this.expression)
            .fontSize(this.story.length > 0 ? 28 : 36)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .textAlign(TextAlign.Center)
            .width('100%')
            .scale({ x: this.exprScale, y: this.exprScale })
            .translate({ x: this.shakeX })
          if (!this.useChoicePad()) {
            Text(this.inputText.length > 0 ? this.inputText : ' ')
              .fontSize(32)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .textAlign(TextAlign.Center)
              .width('100%')
              .height(44)
          }
          if (this.feedback.length > 0) {
            Row({ space: Theme.space.s2 }) {
              if (this.feedbackOk) {
                Text('⭐').fontSize(22).scale({ x: this.starScale, y: this.starScale })
              }
              Text(this.feedback)
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.feedbackOk ? Theme.colors().success : Theme.colors().textSecondary)
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          Text(this.favOn ? '已收藏，可在练习页复习' : '收藏本题')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
            .onClick((): void => { this.onToggleFav() })
        }
        .width('100%')
        .padding({ left: Theme.space.s6, right: Theme.space.s6, top: Theme.space.s4, bottom: Theme.space.s3 })
        .justifyContent(FlexAlign.Center)
        .constraintSize({ minHeight: '100%' })
      }
      .scrollBar(BarState.Off)
      .align(Alignment.Center)
      .layoutWeight(1)
      .width('100%')

      Column() {
        if (this.useChoicePad()) {
          if (this.padSeq % 2 === 0) {
            MathChoicePad({
              qType: this.qType,
              quizKey: `${this.quizKey}_e`,
              choiceA: this.choiceA,
              choiceB: this.choiceB,
              choiceC: this.choiceC,
              onPick: (v: number) => this.submitPick(v)
            })
          } else {
            MathChoicePad({
              qType: this.qType,
              quizKey: `${this.quizKey}_o`,
              choiceA: this.choiceA,
              choiceB: this.choiceB,
              choiceC: this.choiceC,
              onPick: (v: number) => this.submitPick(v)
            })
          }
        } else {
          MathNumPad({
            motion: this.motion,
            onDigit: (v: string) => this.appendDigit(v),
            onDelete: () => { this.inputText = '' },
            onSubmit: () => this.submitFill()
          })
        }
      }
      .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s5 })
      .constraintSize({ maxWidth: 720 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: Theme.space.s4 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
