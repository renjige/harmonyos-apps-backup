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

/** 表达诊断：问卷 + 规则模板报告（方案 B，不调用生成式模型） */
@Component
export struct AIAssistantPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State step: string = 'intro'
  @State questionIndex: number = 0
  @State answers: DiagnoseAnswer[] = []
  @State report: DiagnoseReport = new DiagnoseReport()
  @State selectedOptionId: string = ''
  private questions: DiagnoseQuestion[] = DiagnoseService.questions()
  onClose: () => void = () => {}

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
    for (let a of this.answers) {
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
    for (let a of this.answers) {
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
    for (let a of this.answers) {
      if (a.questionId === q.id) {
        this.selectedOptionId = a.optionId
        break
      }
    }
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })
        Text('表达诊断')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.of(this.darkModeOn).textPrimary)
        Blank()
        Text('模板报告')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.of(this.darkModeOn).textTertiary)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX - 8,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s2
      })

      if (this.step === 'intro') {
        this.IntroPane()
      } else if (this.step === 'quiz') {
        this.QuizPane()
      } else {
        DiagnoseReportPane({
          report: this.report,
          onRetry: (): void => { this.startQuiz() },
          onClose: (): void => { this.onClose() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
  }

  @Builder
  IntroPane() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Column()
            .width('100%')
            .height(148)
            .borderRadius(Theme.radius.lg)
            .linearGradient({
              angle: 135,
              colors: [[Theme.of(this.darkModeOn).brandDeep, 0], [Theme.of(this.darkModeOn).brandPrimary, 1]]
            })
          Column({ space: 4 }) {
            Text('表达习惯问卷')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.of(this.darkModeOn).textOnInverse)
            Text('约 2 分钟 · 规则模板 · 本机生成')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).brandAccent)
          }
          .padding(Theme.space.s4)
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height(148)

        Text('通过 7 道选择题了解你的写作场景与卡点，生成本机模板报告与练习建议。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.of(this.darkModeOn).textSecondary)
          .width('100%')

        Column({ space: Theme.space.s2 }) {
          Text('你将得到')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
            .width('100%')
          Text('1. 表达优势与待改进点')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .width('100%')
          Text('2. 可执行的本周练习清单')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .width('100%')
          Text('3. 匹配的灵感分类与润色风格建议')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.lg)
        .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)

        AppButton({
          label: '开始问卷',
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
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  QuizPane() {
    Column({ space: Theme.space.s4 }) {
      Text(`进度 ${this.progressText()}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.of(this.darkModeOn).textTertiary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Text(this.currentQuestion().title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.of(this.darkModeOn).textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.currentQuestion().options, (opt: DiagnoseOption) => {
            Row() {
              Text(opt.label)
                .fontSize(Theme.type.subhead)
                .fontColor(this.selectedOptionId === opt.id ?
                  Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
                .layoutWeight(1)
              if (this.selectedOptionId === opt.id) {
                AppIcon({
                  name: 'check',
                  iconSize: Theme.icon.sm,
                  color: Theme.of(this.darkModeOn).brandOnPrimary
                })
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .borderRadius(Theme.radius.xl)
            .backgroundColor(this.selectedOptionId === opt.id ?
              Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceCard)
            .border({
              width: 1,
              color: this.selectedOptionId === opt.id ?
                Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).strokeHairline
            })
            .onClick((): void => { this.selectOption(opt.id, opt.label) })
          }, (opt: DiagnoseOption) => opt.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Row({ space: Theme.space.s3 }) {
        Column() {
          AppButton({
            label: '上一步',
            variant: 'secondary',
            onTap: (): void => { this.goPrev() }
          })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: this.questionIndex + 1 >= this.questions.length ? '生成报告' : '下一题',
            disabled: this.selectedOptionId.length === 0,
            onTap: (): void => { this.goNext() }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.pageY
      })
    }
    .width('100%')
    .layoutWeight(1)
  }
}
