import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MathQuestion } from '../../models/MathModels'

@Component
export struct QuizOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '今日智慧挑战'
  @Prop total: number = 10
  @Prop index: number = 0
  @Prop question: MathQuestion = new MathQuestion()
  @Prop motion: boolean = true
  @Prop timedMode: boolean = false
  @State feedback: string = ''
  @State feedbackOk: boolean = false
  @State starScale: number = 1
  @State busy: boolean = false
  @State pickedIndex: number = -1
  @State elapsedSec: number = 0
  onClose: () => void = () => {}
  onAnswer: (ok: boolean, typed: string) => void = (_ok: boolean, _typed: string) => {}
  private timerId: number = -1

  aboutToAppear(): void {
    this.startTimer()
  }

  aboutToDisappear(): void {
    this.stopTimer()
  }

  private startTimer(): void {
    this.stopTimer()
    this.elapsedSec = 0
    if (!this.timedMode) {
      return
    }
    this.timerId = setInterval(() => {
      this.elapsedSec += 1
    }, 1000)
  }

  private stopTimer(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  private progress(): number {
    if (this.total <= 0) {
      return 0
    }
    return (this.index + 1) / this.total
  }

  private optionBg(i: number): string {
    if (this.pickedIndex < 0) {
      return Theme.colors().surfaceCard
    }
    if (i === this.question.correctIndex) {
      return Theme.colors().successContainer
    }
    if (i === this.pickedIndex) {
      return Theme.colors().dangerContainer
    }
    return Theme.colors().surfaceCard
  }

  private optionBorder(i: number): string {
    if (this.pickedIndex < 0) {
      return Theme.colors().strokeHairline
    }
    if (i === this.question.correctIndex) {
      return Theme.colors().success
    }
    if (i === this.pickedIndex) {
      return Theme.colors().danger
    }
    return Theme.colors().strokeHairline
  }

  private pickOption(i: number): void {
    if (this.busy || this.pickedIndex >= 0) {
      return
    }
    this.pickedIndex = i
    const ok = i === this.question.correctIndex
    const typed = `${this.question.options[i]}`
    this.busy = true
    this.feedbackOk = ok
    if (ok) {
      this.feedback = '太棒了，答对啦！'
      this.starScale = 0.7
      animateTo({ duration: this.motion ? 220 : 80, curve: Curve.EaseOut }, () => {
        this.starScale = 1.12
      })
    } else {
      this.feedback = `再想想，正确答案是 ${this.question.answer}`
    }
    setTimeout(() => {
      this.onAnswer(ok, typed)
      this.pickedIndex = -1
      this.feedback = ''
      this.starScale = 1
      this.busy = false
    }, this.motion ? 900 : 500)
  }

  private timerLabel(): string {
    const m = Math.floor(this.elapsedSec / 60)
    const s = this.elapsedSec % 60
    const ss: string = s < 10 ? `0${s}` : `${s}`
    return `${m}:${ss}`
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
        if (this.timedMode) {
          Text(this.timerLabel())
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandAccent)
            .width(44)
            .textAlign(TextAlign.End)
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
          Row()
            .width('100%')
            .height(8)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
          Row()
            .width(`${Math.floor(this.progress() * 100)}%`)
            .height(8)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .height(8)
      }
      .padding({ left: Theme.space.s6, right: Theme.space.s6, top: Theme.space.s3 })

      Blank().layoutWeight(1)

      Column({ space: Theme.space.s5 }) {
        Text(this.question.expression)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .textAlign(TextAlign.Center)
          .width('100%')
        if (this.feedback.length > 0) {
          Row({ space: Theme.space.s2 }) {
            if (this.feedbackOk) {
              Text('⭐')
                .fontSize(22)
                .scale({ x: this.starScale, y: this.starScale })
            }
            Text(this.feedback)
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.feedbackOk ? Theme.colors().success : Theme.colors().textSecondary)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
        }
      }
      .padding({ left: Theme.space.s6, right: Theme.space.s6 })

      GridRow({ columns: 2, gutter: Theme.space.s4 }) {
        ForEach(this.question.options, (opt: number, idx: number) => {
          GridCol() {
            Column() {
              Text(`${opt}`)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            }
            .width('100%')
            .height(72)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.optionBg(idx))
            .borderRadius(Theme.radius.lg)
            .border({ width: 2, color: this.optionBorder(idx) })
            .onClick(() => this.pickOption(idx))
          }
        }, (opt: number, idx: number) => `${this.question.id}_${idx}_${opt}`)
      }
      .padding({ left: Theme.space.s6, right: Theme.space.s6, top: Theme.space.s6 })
      .constraintSize({ maxWidth: 480 })
      .width('100%')

      Blank().layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
