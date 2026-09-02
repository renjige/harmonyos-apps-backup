import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { OverlayShell } from './OverlayShell'
import { ReadingDiagnosisReport } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

class DiagnosisQuestion {
  title: string = ''
  opt0: string = ''
  opt1: string = ''
  opt2: string = ''
  opt3: string = ''
}

@Component
export struct ReadingDiagnosisPane {
  @State step: number = 0
  @State answers: number[] = []
  @State report: ReadingDiagnosisReport = new ReadingDiagnosisReport()
  @State hasReport: boolean = false
  onClose: () => void = () => {}
  private questions: DiagnosisQuestion[] = ReadingDiagnosisPane.buildQuestions()

  private static buildQuestions(): DiagnosisQuestion[] {
    const out: DiagnosisQuestion[] = []
    const q0 = new DiagnosisQuestion()
    q0.title = '你读书时更常？'
    q0.opt0 = '逐章细读并做笔记'
    q0.opt1 = '跳跃式捕捉金句'
    q0.opt2 = '按书单计划推进'
    q0.opt3 = '随兴趣换书浏览'
    out.push(q0)
    const q1 = new DiagnosisQuestion()
    q1.title = '摘录后你通常会？'
    q1.opt0 = '写一段自己的理解'
    q1.opt1 = '先收藏以后再看'
    q1.opt2 = '对照计划检查进度'
    q1.opt3 = '随手保存灵感'
    out.push(q1)
    const q2 = new DiagnosisQuestion()
    q2.title = '你更在意？'
    q2.opt0 = '完成阅读目标'
    q2.opt1 = '积累优质句子'
    q2.opt2 = '建立知识体系'
    q2.opt3 = '保持阅读乐趣'
    out.push(q2)
    const q3 = new DiagnosisQuestion()
    q3.title = '回顾书摘时你希望？'
    q3.opt0 = '深度复习并联想'
    q3.opt1 = '快速浏览金句'
    q3.opt2 = '看统计与进度'
    q3.opt3 = '发现意外关联'
    out.push(q3)
    const q4 = new DiagnosisQuestion()
    q4.title = '你的阅读节奏？'
    q4.opt0 = '每天固定时段'
    q4.opt1 = '碎片时间随手读'
    q4.opt2 = '周末集中阅读'
    q4.opt3 = '有灵感就读'
    out.push(q4)
    return out
  }

  private pickOption(index: number): void {
    const next: number[] = []
    for (const a of this.answers) {
      next.push(a)
    }
    next.push(index)
    this.answers = next
    if (this.step >= this.questions.length - 1) {
      this.report = StudyStore.buildDiagnosisReport(this.answers)
      this.hasReport = true
      this.step = this.questions.length
      return
    }
    this.step = this.step + 1
  }

  build() {
    OverlayShell({
      title: this.hasReport ? '诊断报告' : '阅读风格诊断',
      onClose: (): void => { this.onClose() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      if (this.hasReport) {
        Column({ space: 10 }) {
          Text(this.report.readerType)
            .fontSize(Theme.type.titleM)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
          Text(this.report.summary)
            .fontSize(Theme.type.bodyM)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('你的优势')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.report.strengths, (s: string) => {
            Text(`· ${s}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }, (s: string) => s)
          Text('改进建议')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.report.suggestions, (s: string) => {
            Text(`· ${s}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }, (s: string) => `sg_${s}`)
          Text('推荐使用的功能')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.report.featureTips, (s: string) => {
            Text(`· ${s}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
          }, (s: string) => `ft_${s}`)
        }
        .width('100%')
        AppButton({
          label: '完成',
          onTap: (): void => { this.onClose() }
        })
      } else {
        Text(`第 ${this.step + 1}/${this.questions.length} 题`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text(this.questions[this.step].title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        this.OptionRow(this.questions[this.step].opt0, 0)
        this.OptionRow(this.questions[this.step].opt1, 1)
        this.OptionRow(this.questions[this.step].opt2, 2)
        this.OptionRow(this.questions[this.step].opt3, 3)
      }
    }
    .width('100%')
  }

  @Builder
  OptionRow(opt: string, idx: number) {
    Text(opt)
      .fontSize(Theme.type.bodyM)
      .fontColor(Theme.colors().textPrimary)
      .width('100%')
      .padding(14)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(12)
      .onClick((): void => { this.pickOption(idx) })
  }
}
