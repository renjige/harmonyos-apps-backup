import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'
import { DiagnoseService } from '../services/DiagnoseService'
import { DiagnoseReportPane } from '../components/diagnose/DiagnoseReportPane'
import { TrainingDetailNav } from '../services/TrainingDetailNav'

@Component
export struct RecapQuizPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: string = 'intro'
  @State questionIndex: number = 0
  @State answers: DiagnoseAnswer[] = []
  @State report: DiagnoseReport = new DiagnoseReport()
  @State selectedOptionId: string = ''
  private questions: DiagnoseQuestion[] = DiagnoseService.questions()
  onGoAction: () => void = () => {}

  private currentQuestion(): DiagnoseQuestion {
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
    const next: DiagnoseAnswer[] = []
    for (const a of this.answers) {
      if (a.questionId !== q.id) {
        next.push(a)
      }
    }
    next.push(DiagnoseAnswer.of(q.id, optionId, optionLabel))
    this.answers = next
  }

  private goNext(): void {
    if (this.selectedOptionId.length === 0) {
      return
    }
    if (this.questionIndex + 1 >= this.questions.length) {
      this.report = DiagnoseService.buildReport(this.answers)
      this.step = 'report'
      return
    }
    this.questionIndex = this.questionIndex + 1
    this.selectedOptionId = ''
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { TrainingDetailNav.closeRecap() })
        Text('本周训练复盘')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('规则模板')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      if (this.step === 'intro') {
        this.IntroPane()
      } else if (this.step === 'quiz') {
        this.QuizPane()
      } else {
        DiagnoseReportPane({
          report: this.report,
          onBook: (): void => { this.onGoAction() },
          onRetry: (): void => { this.startQuiz() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  IntroPane() {
    Column({ space: Theme.space.s5 }) {
      Text('用 8 道选择题回顾本周体感与趣味，生成固定模板建议。不是生成式对话，也不会上传答案。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
        .width('100%')
      AppButton({
        label: '开始复盘',
        variant: 'primary',
        onTap: (): void => { this.startQuiz() }
      })
    }
    .padding(Theme.space.pageX)
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  QuizPane() {
    Column({ space: Theme.space.s4 }) {
      Text(`第 ${this.questionIndex + 1} / ${this.questions.length} 题`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')
      Text(this.currentQuestion().title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.currentQuestion().options, (op: DiagnoseOption) => {
        Text(op.label)
          .fontSize(Theme.type.body)
          .fontColor(this.selectedOptionId === op.id ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.selectedOptionId === op.id ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .onClick((): void => { this.selectOption(op.id, op.label) })
      }, (op: DiagnoseOption) => op.id)
      AppButton({
        label: this.questionIndex + 1 >= this.questions.length ? '生成复盘' : '下一题',
        variant: 'primary',
        disabled: this.selectedOptionId.length === 0,
        onTap: (): void => { this.goNext() }
      })
    }
    .padding(Theme.space.pageX)
    .width('100%')
    .layoutWeight(1)
  }
}
