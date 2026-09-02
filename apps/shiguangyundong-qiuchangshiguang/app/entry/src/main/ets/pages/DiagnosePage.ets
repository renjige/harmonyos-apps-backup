import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { DiagnoseReportPane } from '../components/diagnose/DiagnoseReportPane'
import { DiagnoseAnswer, DiagnoseOption, DiagnoseQuestion, DiagnoseReport } from '../models/DiagnoseModels'
import { DiagnoseService } from '../services/DiagnoseService'
import { CourtDetailNav } from '../services/CourtDetailNav'

@Component
export struct DiagnosePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: number = 0
  @State answers: DiagnoseAnswer[] = []
  @State report: DiagnoseReport | null = null
  onGoDiscover: (category: string) => void = () => {}

  private questions(): DiagnoseQuestion[] {
    return DiagnoseService.questions()
  }

  private currentQuestion(): DiagnoseQuestion {
    const qs = this.questions()
    if (this.step >= 0 && this.step < qs.length) {
      return qs[this.step]
    }
    return qs[0]
  }

  private selectOption(optionId: string, optionLabel: string): void {
    const q = this.currentQuestion()
    const filtered: DiagnoseAnswer[] = []
    for (let a of this.answers) {
      if (a.questionId !== q.id) {
        filtered.push(a)
      }
    }
    filtered.push(DiagnoseAnswer.of(q.id, optionId, optionLabel))
    this.answers = filtered
    if (this.step < this.questions().length - 1) {
      this.step++
      return
    }
    this.report = DiagnoseService.buildReport(this.answers)
  }

  private retry(): void {
    this.step = 0
    this.answers = []
    this.report = null
  }

  build() {
    Column() {
      Row({ space: Theme.space.s3 }) {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .rotate({ angle: 180 })
        .onClick(() => {
          CourtDetailNav.close()
        })

        Column({ space: 2 }) {
          Text('智慧选场')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text(this.report !== null ? '选场报告' : `第 ${this.step + 1} / ${this.questions().length} 题`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

      if (this.report !== null) {
        DiagnoseReportPane({
          report: this.report,
          onBook: (): void => {
            CourtDetailNav.close()
            this.onGoDiscover(this.report !== null ? this.report.matchCategory : '全部')
          },
          onRetry: (): void => {
            this.retry()
          }
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(this.currentQuestion().title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')

            ForEach(this.currentQuestion().options, (opt: DiagnoseOption) => {
              Row({ space: Theme.space.s3 }) {
                Text(opt.label)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick(() => {
                this.selectOption(opt.id, opt.label)
              })
            }, (opt: DiagnoseOption) => opt.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)

        if (this.step > 0) {
          AppButton({
            label: '上一题',
            variant: 'secondary',
            onTap: (): void => {
              if (this.step > 0) {
                this.step--
              }
            }
          }).margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
