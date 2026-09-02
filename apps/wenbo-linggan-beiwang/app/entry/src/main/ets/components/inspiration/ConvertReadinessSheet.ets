import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { PipelineSnapshot } from '../../services/ConversionPipelineService'
import { ConvertReadinessService, ReadinessAnswers, ReadinessReport } from '../../services/ConvertReadinessService'

class ChoiceOption {
  label: string = ''
  value: number = 0
}

/** 创意转化就绪度问卷 → 规则模板报告（非大模型） */
@Component
export struct ConvertReadinessSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop pipeline: PipelineSnapshot = PipelineSnapshot.empty()
  onClose: () => void = () => {}
  @State step: number = 0
  @State answers: ReadinessAnswers = new ReadinessAnswers()
  @State report: ReadinessReport | undefined = undefined

  private q1(): ChoiceOption[] {
    const list: ChoiceOption[] = []
    const o0 = new ChoiceOption()
    o0.label = '0 条'
    o0.value = 0
    list.push(o0)
    const o1 = new ChoiceOption()
    o1.label = '1–2 条'
    o1.value = 1
    list.push(o1)
    const o2 = new ChoiceOption()
    o2.label = '3 条以上'
    o2.value = 2
    list.push(o2)
    return list
  }

  private q2(): ChoiceOption[] {
    const list: ChoiceOption[] = []
    const o0 = new ChoiceOption()
    o0.label = '还没有'
    o0.value = 0
    list.push(o0)
    const o1 = new ChoiceOption()
    o1.label = '部分已钉板'
    o1.value = 1
    list.push(o1)
    const o2 = new ChoiceOption()
    o2.label = '大部分已对照'
    o2.value = 2
    list.push(o2)
    return list
  }

  private q3(): ChoiceOption[] {
    const list: ChoiceOption[] = []
    const o0 = new ChoiceOption()
    o0.label = '还没有计划'
    o0.value = 0
    list.push(o0)
    const o1 = new ChoiceOption()
    o1.label = '有计划推进中'
    o1.value = 1
    list.push(o1)
    const o2 = new ChoiceOption()
    o2.label = '已有完成项'
    o2.value = 2
    list.push(o2)
    return list
  }

  private q4(): ChoiceOption[] {
    const list: ChoiceOption[] = []
    const o0 = new ChoiceOption()
    o0.label = '少（<2h/周）'
    o0.value = 0
    list.push(o0)
    const o1 = new ChoiceOption()
    o1.label = '中（2–5h/周）'
    o1.value = 1
    list.push(o1)
    const o2 = new ChoiceOption()
    o2.label = '多（>5h/周）'
    o2.value = 2
    list.push(o2)
    return list
  }

  private q5(): ChoiceOption[] {
    const list: ChoiceOption[] = []
    const o0 = new ChoiceOption()
    o0.label = '缺参考对照'
    o0.value = 0
    list.push(o0)
    const o1 = new ChoiceOption()
    o1.label = '缺拆解步骤'
    o1.value = 1
    list.push(o1)
    const o2 = new ChoiceOption()
    o2.label = '缺推进时间'
    o2.value = 2
    list.push(o2)
    const o3 = new ChoiceOption()
    o3.label = '其他'
    o3.value = 3
    list.push(o3)
    return list
  }

  private questionTitle(): string {
    if (this.step === 0) {
      return '本周新捕捉了几条灵感？'
    }
    if (this.step === 1) {
      return '是否已钉入画板对照构图/文案？'
    }
    if (this.step === 2) {
      return '是否拆成带三步的创意计划？'
    }
    if (this.step === 3) {
      return '本周可投入转化时间？'
    }
    return '当前最大阻塞是什么？'
  }

  private optionsForStep(): ChoiceOption[] {
    if (this.step === 0) {
      return this.q1()
    }
    if (this.step === 1) {
      return this.q2()
    }
    if (this.step === 2) {
      return this.q3()
    }
    if (this.step === 3) {
      return this.q4()
    }
    return this.q5()
  }

  private selectedValue(): number {
    if (this.step === 0) {
      return this.answers.captureVolume
    }
    if (this.step === 1) {
      return this.answers.boardStatus
    }
    if (this.step === 2) {
      return this.answers.planStatus
    }
    if (this.step === 3) {
      return this.answers.timeBudget
    }
    return this.answers.blocker
  }

  private pickOption(value: number): void {
    if (this.step === 0) {
      this.answers.captureVolume = value
    } else if (this.step === 1) {
      this.answers.boardStatus = value
    } else if (this.step === 2) {
      this.answers.planStatus = value
    } else if (this.step === 3) {
      this.answers.timeBudget = value
    } else {
      this.answers.blocker = value
    }
  }

  private submitReport(): void {
    this.report = ConvertReadinessService.buildReport(this.answers, this.pipeline)
  }

  @Builder
  ChoiceRow(opt: ChoiceOption) {
    Row({ space: Theme.space.s2 }) {
      Text(opt.label)
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
      if (this.selectedValue() === opt.value) {
        AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.selectedValue() === opt.value
      ? Theme.colors().brandPrimaryContainer
      : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({
      width: 1,
      color: this.selectedValue() === opt.value ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
    })
    .onClick((): void => { this.pickOption(opt.value) })
  }

  @Builder
  QuestionFooter() {
    Row({ space: Theme.space.s3 }) {
      if (this.step > 0) {
        Column() {
          AppButton({
            label: '上一题',
            variant: 'secondary',
            onTap: (): void => { this.step -= 1 }
          })
        }
        .layoutWeight(1)
      }
      Column() {
        AppButton({
          label: this.step >= 4 ? '生成报告' : '下一题',
          variant: 'primary',
          onTap: (): void => {
            if (this.step >= 4) {
              this.submitReport()
            } else {
              this.step += 1
            }
          }
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      top: Theme.space.s3,
      bottom: Theme.space.s8
    })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  ReportFooter() {
    Column() {
      AppButton({ label: '完成', variant: 'primary', onTap: (): void => { this.onClose() } })
    }
    .width('100%')
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      top: Theme.space.s3,
      bottom: Theme.space.s8
    })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
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
        .onClick((): void => { this.onClose() })
        Text('转化就绪度评估')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.report === undefined) {
            Text(`问题 ${this.step + 1} / 5`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Text(this.questionTitle())
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.optionsForStep(), (opt: ChoiceOption) => {
              this.ChoiceRow(opt)
            }, (opt: ChoiceOption) => `${this.step}_${opt.value}`)
          } else {
            Text(`就绪度 ${this.report.score} · ${this.report.level}`)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
            Text(this.report.headline)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.report.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .lineHeight(22)
            Column({ space: Theme.space.s2 }) {
              Text('建议下一步')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(`1. ${this.report.action1}`)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
                .lineHeight(20)
              Text(`2. ${this.report.action2}`)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
                .lineHeight(20)
              Text(`3. ${this.report.action3}`)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
                .lineHeight(20)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.lg)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s4
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.report === undefined) {
        this.QuestionFooter()
      } else {
        this.ReportFooter()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
