import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../../models/DiagnoseModels'
import { DiagnoseService } from '../../services/DiagnoseService'
import { DiagnoseReportPane } from '../diagnose/DiagnoseReportPane'

/** 个人效率自诊全屏 Overlay（问卷 + 模板报告，非大模型） */
@Component
export struct EfficiencyDiagnoseOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
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

  private progressText(): string {
    return `${this.questionIndex + 1} / ${this.questions.length}`
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

  private goPrev(): void {
    if (this.questionIndex <= 0) {
      this.step = 'intro'
      return
    }
    this.questionIndex = this.questionIndex - 1
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
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => this.onClose())
        Row({ space: 8 }) {
          AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text('效率自诊')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .layoutWeight(1)
        Text('模板报告')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.step === 'intro') {
        this.IntroPane()
      } else if (this.step === 'quiz') {
        this.QuizPane()
      } else {
        DiagnoseReportPane({
          report: this.report,
          showBookAction: false,
          onRetry: (): void => { this.startQuiz() }
        })
          .layoutWeight(1)
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
        Text('5 题快速自诊')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('基于你的待办负荷、习惯坚持与整理方式，生成可执行效率报告。' +
          '本功能为规则模板输出，不调用生成式 AI。')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .lineHeight(24)
        AppButton({
          label: '开始自诊',
          onTap: (): void => { this.startQuiz() }
        })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  QuizPane() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text(this.progressText())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        Text(this.currentQuestion().title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.currentQuestion().options, (opt: DiagnoseOption) => {
          Row() {
            Text(opt.label)
              .fontSize(Theme.type.body)
              .fontColor(this.selectedOptionId === opt.id ?
                Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.selectedOptionId === opt.id ?
            Theme.colors().brandPrimary : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .onClick((): void => { this.selectOption(opt.id, opt.label) })
        }, (opt: DiagnoseOption) => opt.id)
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '上一题',
            variant: 'secondary',
            onTap: (): void => { this.goPrev() }
          })
            .layoutWeight(1)
          AppButton({
            label: this.questionIndex + 1 >= this.questions.length ? '生成报告' : '下一题',
            disabled: this.selectedOptionId.length === 0,
            onTap: (): void => { this.goNext() }
          })
            .layoutWeight(1)
        }
        .width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}
