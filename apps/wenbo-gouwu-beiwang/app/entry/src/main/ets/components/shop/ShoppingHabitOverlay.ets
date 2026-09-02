import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import {
  HabitAnswer,
  HabitOption,
  HabitQuestion,
  HabitReport,
  ShoppingHabitService
} from '../../services/ShoppingHabitService'

@Component
export struct ShoppingHabitOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: string = 'intro'
  @State questionIndex: number = 0
  @State answers: HabitAnswer[] = []
  @State report: HabitReport = new HabitReport()
  @State selectedOptionId: string = ''
  private questions: HabitQuestion[] = ShoppingHabitService.questions()
  onClose: () => void = () => {}

  private currentQuestion(): HabitQuestion {
    if (this.questionIndex >= 0 && this.questionIndex < this.questions.length) {
      return this.questions[this.questionIndex]
    }
    return this.questions[0]
  }

  private startQuiz(): void {
    this.answers = []
    this.questionIndex = 0
    this.selectedOptionId = ''
    this.step = 'quiz'
  }

  private selectOption(optionId: string, optionLabel: string): void {
    this.selectedOptionId = optionId
    const q = this.currentQuestion()
    const next: HabitAnswer[] = []
    for (const a of this.answers) {
      if (a.questionId !== q.id) {
        next.push(a)
      }
    }
    next.push(HabitAnswer.of(q.id, optionId, optionLabel))
    this.answers = next
  }

  private goNext(): void {
    if (this.selectedOptionId.length === 0) {
      return
    }
    if (this.questionIndex + 1 >= this.questions.length) {
      this.report = ShoppingHabitService.buildReport(this.answers)
      this.step = 'report'
      return
    }
    this.questionIndex = this.questionIndex + 1
    this.selectedOptionId = ''
    const q = this.currentQuestion()
    for (const a of this.answers) {
      if (a.questionId === q.id) {
        this.selectedOptionId = a.optionId
        break
      }
    }
  }

  build() {
    Column() {
      Row() {
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('采购习惯诊断')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.step === 'intro') {
            Text('3 分钟了解你的采购节奏')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            Text('根据你的购物频率、场景与偏好，生成一份可执行的清单整理建议（规则模板，非 AI 对话）。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
            AppButton({ label: '开始诊断', onTap: (): void => { this.startQuiz() } })
          } else if (this.step === 'quiz') {
            Text(`${this.questionIndex + 1} / ${this.questions.length}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
            Text(this.currentQuestion().title)
              .fontSize(Theme.type.subtitleL)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            ForEach(this.currentQuestion().options, (opt: HabitOption) => {
              Text(opt.label)
                .fontSize(Theme.type.subhead)
                .fontColor(this.selectedOptionId === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .width('100%')
                .padding(14)
                .backgroundColor(this.selectedOptionId === opt.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => { this.selectOption(opt.id, opt.label) })
            }, (opt: HabitOption) => opt.id)
            AppButton({ label: '下一题', onTap: (): void => { this.goNext() } })
          } else {
            Text('你的采购建议')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            Text(this.report.summary)
              .fontSize(Theme.type.body)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
            Column({ space: 8 }) {
              ForEach(this.report.tips, (tip: string) => {
                Text(`· ${tip}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                  .width('100%')
              }, (tip: string) => tip)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.xl)
            AppButton({ label: '完成', onTap: (): void => { this.onClose() } })
          }
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
