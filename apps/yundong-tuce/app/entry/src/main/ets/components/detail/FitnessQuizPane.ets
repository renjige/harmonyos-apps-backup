import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { QuizResult } from '../../models/TuceModels'
import { TuceEngine } from '../../services/TuceEngine'
import { TuceNav } from '../../services/TuceNav'

class QuizOption {
  label: string = ''
  value: number = 0
}

@Component
export struct FitnessQuizPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: number = 0
  @State goal: number = 0
  @State scene: number = 0
  @State level: number = 0
  @State freq: number = 1
  @State result: QuizResult = new QuizResult()
  @State showResult: boolean = false

  private optionsOf(step: number): QuizOption[] {
    const out: QuizOption[] = []
    if (step === 0) {
      const labels: string[] = ['减脂燃脂', '力量塑形', '柔韧恢复', '习惯养成']
      for (let i = 0; i < labels.length; i++) {
        const o = new QuizOption()
        o.label = labels[i]
        o.value = i
        out.push(o)
      }
    } else if (step === 1) {
      const labels: string[] = ['居家', '办公室', '户外', '跑后恢复']
      for (let i = 0; i < labels.length; i++) {
        const o = new QuizOption()
        o.label = labels[i]
        o.value = i
        out.push(o)
      }
    } else if (step === 2) {
      const o1 = new QuizOption()
      o1.label = '入门（刚开始练）'
      o1.value = 0
      out.push(o1)
      const o2 = new QuizOption()
      o2.label = '进阶（有基础）'
      o2.value = 1
      out.push(o2)
    } else {
      const labels: string[] = ['每周 2 次', '每周 3 次', '每周 4 次', '每周 5+ 次']
      for (let i = 0; i < labels.length; i++) {
        const o = new QuizOption()
        o.label = labels[i]
        o.value = i
        out.push(o)
      }
    }
    return out
  }

  private questionOf(): string {
    if (this.step === 0) {
      return '你的主要训练目标？'
    }
    if (this.step === 1) {
      return '常在什么场景训练？'
    }
    if (this.step === 2) {
      return '当前体能水平？'
    }
    return '计划每周训练几次？'
  }

  private pick(value: number): void {
    if (this.step === 0) {
      this.goal = value
    } else if (this.step === 1) {
      this.scene = value
    } else if (this.step === 2) {
      this.level = value
    } else {
      this.freq = value
    }
    if (this.step >= 3) {
      this.result = TuceEngine.buildQuizResult(this.goal, this.scene, this.level, this.freq)
      this.showResult = true
      return
    }
    this.step++
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('体能自测')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('4 个问题生成个性化课表推荐（规则模板，非 AI 对话）。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')

        if (this.showResult) {
          Column({ space: Theme.space.s3 }) {
            Text('你的训练画像')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.result.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.result.tips)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: '查看推荐精选课',
              variant: 'primary',
              onTap: (): void => { TuceNav.open('presets', this.result.presetIds) }
            })
            AppButton({
              label: '重新测评',
              variant: 'ghost',
              onTap: (): void => {
                this.step = 0
                this.showResult = false
              }
            })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        } else {
          Text(`第 ${this.step + 1}/4 题 · ${this.questionOf()}`)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.optionsOf(this.step), (o: QuizOption) => {
            Text(o.label)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.pick(o.value) })
          }, (o: QuizOption) => `${this.step}_${o.value}`)
        }
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s2,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
  }
}
