import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { ScienceScenario, ScenarioBank, ScenarioStep } from '../data/ScenarioBank'
import { ElementNav } from '../services/ElementNav'
import { ProgressStore } from '../services/ProgressStore'
import { DetailShell } from '../components/detail/DetailShell'

@Component
export struct ScenarioOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop scenarioId: string = ''
  @Prop elementSymbol: string = ''
  @State scenario: ScienceScenario = new ScienceScenario()
  @State stepIndex: number = 0
  @State finished: boolean = false

  aboutToAppear(): void {
    this.load()
  }

  private load(): void {
    if (this.scenarioId.length > 0) {
      const found = ScenarioBank.find(this.scenarioId)
      if (found !== undefined) {
        this.scenario = found
      }
    } else if (this.elementSymbol.length > 0) {
      const list = ScenarioBank.byElement(this.elementSymbol)
      if (list.length > 0) {
        this.scenario = list[0]
      }
    }
    this.stepIndex = 0
    this.finished = false
  }

  private currentStep(): ScenarioStep {
    if (this.stepIndex >= 0 && this.stepIndex < this.scenario.steps.length) {
      return this.scenario.steps[this.stepIndex]
    }
    return new ScenarioStep()
  }

  private nextStep(): void {
    if (this.stepIndex + 1 >= this.scenario.steps.length) {
      this.finished = true
      void ProgressStore.completeScenario(this.scenario.id, this.scenario.title)
      return
    }
    this.stepIndex = this.stepIndex + 1
  }

  private stepNumber(step: ScenarioStep): number {
    let i = 0
    for (const s of this.scenario.steps) {
      if (s.label === step.label) {
        return i
      }
      i++
    }
    return 0
  }

  @Builder
  StepCard(step: ScenarioStep) {
    Column({ space: 6 }) {
      Text(step.label)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.stepNumber(step) === this.stepIndex ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.stepNumber(step) <= this.stepIndex) {
        Text(step.detail)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(22)
          .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.stepNumber(step) === this.stepIndex ?
      Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({
      width: this.stepNumber(step) === this.stepIndex ? 2 : 1,
      color: this.stepNumber(step) === this.stepIndex ? Theme.colors().brandAccent : Theme.colors().strokeHairline
    })
  }

  build() {
    DetailShell({
      title: '科学推演',
      onClose: (): void => { ElementNav.closeScenario() }
    }) {
      if (this.scenario.steps.length === 0) {
        Column() {
          Text('暂无推演场景')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.finished) {
        Column({ space: Theme.space.s4 }) {
          Text('推演完成')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.scenario.title)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Blank()
          AppButton({
            label: '返回',
            onTap: (): void => { ElementNav.closeScenario() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10,
          top: Theme.space.s4
        })
        .width('100%')
        .height('100%')
      } else {
        Column({ space: Theme.space.s4 }) {
          Text(this.scenario.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Text(`步骤 ${this.stepIndex + 1} / ${this.scenario.steps.length}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Column({ space: Theme.space.s3 }) {
            ForEach(this.scenario.steps, (step: ScenarioStep) => {
              this.StepCard(step)
            }, (step: ScenarioStep) => step.label)
          }
          .width('100%')

          Blank()

          AppButton({
            label: this.stepIndex + 1 >= this.scenario.steps.length ? '完成推演' : '下一步',
            onTap: (): void => { this.nextStep() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10,
          top: Theme.space.s2
        })
        .width('100%')
        .height('100%')
      }
    }
  }
}
