import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'
import { DiagnoseService } from '../services/DiagnoseService'
import { DiagnoseReportPane } from '../components/diagnose/DiagnoseReportPane'
import { PoetryNav } from '../services/PoetryNav'

@Component
export struct MatchOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: string = 'intro'
  @State questionIndex: number = 0
  @State answers: DiagnoseAnswer[] = []
  @State report: DiagnoseReport = new DiagnoseReport()
  @State selectedOptionId: string = ''
  private questions: DiagnoseQuestion[] = DiagnoseService.questions()

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
    const q = this.currentQuestion()
    for (const a of this.answers) {
      if (a.questionId === q.id) {
        this.selectedOptionId = a.optionId
        break
      }
    }
  }

  private openHunt(): void {
    PoetryNav.openHunt(this.report.matchHint)
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => PoetryNav.close())
        Blank()
        Text('学诗匹配')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      if (this.step === 'intro') {
        Column({ space: 14 }) {
          Text('按兴趣匹配关卡')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('六题问卷，按规则推荐最合适的寻宝关卡与诗库方向。不调用云端大模型。')
            .fontSize(15)
            .lineHeight(24)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Blank()
          AppButton({ label: '开始匹配', onTap: () => this.startQuiz() })
        }
        .padding({ left: 20, right: 20, bottom: 28 })
        .layoutWeight(1)
      } else if (this.step === 'quiz') {
        Column({ space: 14 }) {
          Text(`${this.questionIndex + 1} / ${this.questions.length}`)
            .fontSize(13)
            .fontColor(Theme.colors().brandAccent)
            .width('100%')
          Text(this.currentQuestion().title)
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.currentQuestion().options, (op: DiagnoseOption) => {
            Text(op.label)
              .fontSize(16)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding(14)
              .backgroundColor(this.selectedOptionId === op.id ?
                Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
              .borderRadius(16)
              .border({
                width: 1.5,
                color: this.selectedOptionId === op.id ?
                  Theme.colors().brandAccent : Theme.colors().strokeHairline
              })
              .onClick(() => this.selectOption(op.id, op.label))
          }, (op: DiagnoseOption) => op.id)
          Blank()
          AppButton({
            label: '下一步',
            disabled: this.selectedOptionId.length === 0,
            onTap: () => this.goNext()
          })
        }
        .padding({ left: 20, right: 20, bottom: 28 })
        .layoutWeight(1)
      } else {
        DiagnoseReportPane({
          report: this.report,
          onBook: () => this.openHunt(),
          onRetry: () => this.startQuiz()
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
