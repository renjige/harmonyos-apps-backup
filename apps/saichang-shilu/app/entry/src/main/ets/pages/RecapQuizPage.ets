import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'
import { DiagnoseService } from '../services/DiagnoseService'
import { RecordStore } from '../services/RecordStore'

@Component
export struct RecapQuizPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop seedId: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State step: string = 'intro'
  @State questionIndex: number = 0
  @State answers: DiagnoseAnswer[] = []
  @State report: DiagnoseReport = new DiagnoseReport()
  @State selectedOptionId: string = ''
  @State toastText: string = ''
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
  }

  private async saveToRecord(): Promise<void> {
    const found = await RecordStore.findById(this.seedId)
    if (found === undefined) {
      this.toastText = '未找到本场记录'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    found.recapSummary = `${this.report.scoreLabel}｜${this.report.summary}`
    found.recapScore = this.report.scoreLabel
    await RecordStore.saveRecord(found)
    this.onSaved()
    this.onClose()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('赛后复盘')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        if (this.step === 'intro') {
          this.IntroPane()
        } else if (this.step === 'quiz') {
          this.QuizPane()
        } else {
          this.ReportPane()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(10)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '16%', y: 48 })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(75)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }

  @Builder
  IntroPane() {
    Column({ space: Theme.space.s4 }) {
      Text('6 道选择题，按规则拼出本场优势、短板和下场训练锚点。不含生成式对话。')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .lineHeight(22)
      AppButton({
        label: '开始复盘',
        variant: 'primary',
        onTap: (): void => { this.startQuiz() }
      })
    }
    .width('100%')
    .padding(Theme.space.pageX)
    .layoutWeight(1)
  }

  @Builder
  QuizPane() {
    Column({ space: Theme.space.s4 }) {
      Text(`${this.questionIndex + 1} / ${this.questions.length}`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(this.currentQuestion().title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.currentQuestion().options, (opt: DiagnoseOption) => {
            Text(opt.label)
              .fontSize(Theme.type.body)
              .fontColor(this.selectedOptionId === opt.id ?
                Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding(Theme.space.s4)
              .borderRadius(Theme.radius.lg)
              .backgroundColor(this.selectedOptionId === opt.id ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .onClick((): void => { this.selectOption(opt.id, opt.label) })
          }, (opt: DiagnoseOption) => opt.id)
        }
        .width('100%')
      }
      .layoutWeight(1)
      AppButton({
        label: this.questionIndex + 1 >= this.questions.length ? '生成复盘卡' : '下一题',
        disabled: this.selectedOptionId.length === 0,
        onTap: (): void => { this.goNext() }
      })
    }
    .width('100%')
    .padding(Theme.space.pageX)
    .layoutWeight(1)
  }

  @Builder
  ReportPane() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        Text(this.report.scoreLabel)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Text(this.report.summary)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(`优势：${this.report.strength}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(`短板：${this.report.weakness}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(`下场：${this.report.opportunity}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        ForEach(this.report.actions, (line: string, idx: number) => {
          Text(`${idx + 1}. ${line}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }, (line: string, idx: number) => `a-${idx}`)
        AppButton({
          label: '写入本场档案',
          variant: 'primary',
          onTap: (): void => { void this.saveToRecord() }
        })
        AppButton({
          label: '重做问卷',
          variant: 'secondary',
          onTap: (): void => { this.startQuiz() }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .padding({ bottom: Theme.space.s10 })
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring)
  }
}
