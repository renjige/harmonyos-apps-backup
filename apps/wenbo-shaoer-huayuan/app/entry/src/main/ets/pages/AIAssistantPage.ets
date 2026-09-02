import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { FeatureFlags } from '../config/FeatureFlags'
import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'
import { DiagnoseService } from '../services/DiagnoseService'
import { DiagnoseReportPane } from '../components/diagnose/DiagnoseReportPane'
import { KagNav } from '../services/KagNav'
import { KagMedia } from '../services/KagMedia'

/**
 * 方案 B：智慧策展 = 问卷 + 规则模板方案。
 * 不调用大模型（无安全评估报告时上架合规）。
 */
@Component
export struct AIAssistantPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: string = 'intro'
  @State questionIndex: number = 0
  @State answers: DiagnoseAnswer[] = []
  @State report: DiagnoseReport = new DiagnoseReport()
  @State selectedOptionId: string = ''
  private questions: DiagnoseQuestion[] = DiagnoseService.questions()
  onRequireAuth: () => void = () => {}
  onBookFromAi: (category: string) => void = (_c: string) => {}

  private currentQuestion(): DiagnoseQuestion {
    let i = 0
    for (const q of this.questions) {
      if (i === this.questionIndex) {
        return q
      }
      i++
    }
    return DiagnoseQuestion.of('', '', [])
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
        AppIcon({ name: 'chart', iconSize: Theme.icon.md, active: true })
        Text('智慧策展')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('关闭')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .height(44)
          .onClick(() => KagNav.close())
        Text(FeatureFlags.llmEnabled() ? '' : '模板方案')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
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
          onBook: () => this.onBookFromAi(this.report.matchCategory),
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
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(KagMedia.cover('banner_timeline'))
            .width('100%')
            .height(148)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Column()
            .width('100%')
            .height(148)
            .borderRadius(Theme.radius.lg)
            .linearGradient({
              angle: 180,
              colors: [[0x00000000, 0.15], [0xE64A2A1C, 1.0]]
            })
          Column({ space: 4 }) {
            Text('问卷策展 · 模板方案')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFF8F3')
            Text('约 2 分钟 · 规则建议画册与展厅 · 不含生成式对话')
              .fontSize(Theme.type.caption)
              .fontColor('#FFF8F3')
          }
          .padding(Theme.space.s4)
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height(148)

        Text('用几道选择题，得到画册主题与展厅风格建议。结论为固定模板拼装，仅供参考，不是评画。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')

        Column({ space: Theme.space.s2 }) {
          Text('流程')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('1. 回答关于年龄、数量、材料和分享对象的选择题')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text('2. 生成智慧策展方案（规则模板）')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text('3. 按建议去建画册或切换展厅')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.card)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

        AppButton({
          label: '开始策展问卷',
          onTap: () => this.startQuiz()
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
              if (this.selectedOptionId === opt.id) {
                AppIcon({
                  name: 'check',
                  iconSize: Theme.icon.sm,
                  color: Theme.colors().brandOnPrimary
                })
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .borderRadius(Theme.radius.xl)
            .backgroundColor(this.selectedOptionId === opt.id ?
              Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .border({
              width: 1,
              color: this.selectedOptionId === opt.id ?
                Theme.colors().brandPrimary : Theme.colors().strokeHairline
            })
            .onClick(() => this.selectOption(opt.id, opt.label))
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
            onTap: () => this.goPrev()
          })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: this.questionIndex + 1 >= this.questions.length ? '生成方案' : '下一题',
            disabled: this.selectedOptionId.length === 0,
            onTap: () => this.goNext()
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
