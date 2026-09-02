import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../../models/DiagnoseModels'
import { DiagnoseService } from '../../services/DiagnoseService'
import { DiagnoseReportPane } from '../diagnose/DiagnoseReportPane'

@Component
export struct RhythmOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: string = 'intro'
  @State questionIndex: number = 0
  @State answers: DiagnoseAnswer[] = []
  @State report: DiagnoseReport = new DiagnoseReport()
  @State selectedOptionId: string = ''
  private questions: DiagnoseQuestion[] = DiagnoseService.questions()
  onClose: () => void = () => {}
  onApply: (category: string) => void = () => {}

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
    this.questionIndex += 1
    this.selectedOptionId = ''
  }

  build() {
    Column() {
      Row() {
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('智能整理')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('')
          .fontSize(Theme.type.subhead)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      if (this.step === 'intro') {
        Column({ space: Theme.space.s4 }) {
          Image($r('app.media.banner_schedule'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Text('用 8 道选择题看清本周节奏')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('根据负荷、缓冲和提醒习惯生成整理建议，并可一键创建对应约定。不调用生成式模型。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({ label: '开始整理', onTap: (): void => { this.startQuiz() } })
        }
        .padding({ left: 20, right: 20 })
        .width('100%')
      } else if (this.step === 'quiz') {
        Column({ space: Theme.space.s4 }) {
          Text(`${this.questionIndex + 1} / ${this.questions.length}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text(this.currentQuestion().title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.currentQuestion().options, (opt: DiagnoseOption) => {
            Text(opt.label)
              .fontSize(Theme.type.subhead)
              .fontColor(this.selectedOptionId === opt.id ?
                Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding(14)
              .width('100%')
              .backgroundColor(this.selectedOptionId === opt.id ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .onClick((): void => { this.selectOption(opt.id, opt.label) })
          }, (opt: DiagnoseOption) => opt.id)
          AppButton({
            label: this.questionIndex + 1 >= this.questions.length ? '生成整理建议' : '下一题',
            onTap: (): void => { this.goNext() }
          })
        }
        .padding({ left: 20, right: 20 })
        .width('100%')
      } else {
        DiagnoseReportPane({
          report: this.report,
          onBook: (): void => { this.onApply(this.report.matchCategory) },
          onRetry: (): void => { this.startQuiz() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
