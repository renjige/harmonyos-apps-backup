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
import { DiagnoseReportStore } from '../services/DiagnoseReportStore'
import { DiagnoseReportPane } from '../components/diagnose/DiagnoseReportPane'
import { SportDetailNav } from '../services/SportDetailNav'

@Component
export struct ReviewQuizPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: string = 'intro'
  @State questionIndex: number = 0
  @State answers: DiagnoseAnswer[] = []
  @State report: DiagnoseReport = new DiagnoseReport()
  @State selectedOptionId: string = ''
  private questions: DiagnoseQuestion[] = DiagnoseService.questions()
  onGoRecord: () => void = () => {}

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
    for (let a of this.answers) {
      if (a.questionId !== q.id) {
        next.push(a)
      }
    }
    next.push(DiagnoseAnswer.of(q.id, optionId, optionLabel))
    this.answers = next
  }

  private async finishReport(): Promise<void> {
    this.report = DiagnoseService.buildReport(this.answers)
    await DiagnoseReportStore.save(this.report)
    this.step = 'report'
  }

  private goNext(): void {
    if (this.selectedOptionId.length === 0) {
      return
    }
    if (this.questionIndex + 1 >= this.questions.length) {
      void this.finishReport()
      return
    }
    this.questionIndex = this.questionIndex + 1
    this.selectedOptionId = ''
  }

  private goPrev(): void {
    if (this.questionIndex <= 0) {
      this.step = 'intro'
      return
    }
    this.questionIndex = this.questionIndex - 1
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
        .onClick(() => {
          SportDetailNav.close()
        })
        Text('训练配比复盘')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('规则模板')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4
      })

      if (this.step === 'intro') {
        this.IntroPane()
      } else if (this.step === 'quiz') {
        this.QuizPane()
      } else {
        DiagnoseReportPane({
          report: this.report,
          onBook: () => {
            this.onGoRecord()
          },
          onRetry: () => this.startQuiz()
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  IntroPane() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('用 6 道选择题生成可执行的下一笔训练建议。结论由规则拼装，不含生成式对话。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: '开始问卷',
          onTap: () => this.startQuiz()
        })
      }
      .padding(Theme.space.pageX)
      .width('100%')
    }
    .layoutWeight(1)
  }

  @Builder
  QuizPane() {
    Column({ space: Theme.space.s4 }) {
      Text(`${this.questionIndex + 1} / ${this.questions.length}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      Text(this.currentQuestion().title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.currentQuestion().options, (opt: DiagnoseOption) => {
            Row() {
              Text(opt.label)
                .fontSize(Theme.type.subhead)
                .fontColor(this.selectedOptionId === opt.id ?
                  Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .borderRadius(Theme.radius.xl)
            .backgroundColor(this.selectedOptionId === opt.id ?
              Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .onClick(() => this.selectOption(opt.id, opt.label))
          }, (opt: DiagnoseOption) => opt.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .layoutWeight(1)
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppButton({
            label: '上一步',
            variant: 'secondary',
            onTap: () => this.goPrev()
          })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: this.questionIndex + 1 >= this.questions.length ? '生成建议' : '下一题',
            disabled: this.selectedOptionId.length === 0,
            onTap: () => this.goNext()
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding(Theme.space.pageX)
    }
    .layoutWeight(1)
  }
}
