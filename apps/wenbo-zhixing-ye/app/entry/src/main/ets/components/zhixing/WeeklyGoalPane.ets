import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { WeeklyGoalProgress } from '../../models/ZhixingModels'
import { ZhixingStore } from '../../services/ZhixingStore'

@Component
export struct WeeklyGoalPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTok') reloadToken: number = 0
  @State goal: WeeklyGoalProgress = new WeeklyGoalProgress()
  @State knowTarget: string = '3'
  @State checkTarget: string = '5'
  @State reviewTarget: string = '2'
  @State toastText: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onTok(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.goal = await ZhixingStore.loadWeeklyGoalProgress()
    this.knowTarget = `${this.goal.targetKnowledge}`
    this.checkTarget = `${this.goal.targetChecks}`
    this.reviewTarget = `${this.goal.targetReviews}`
  }

  private parseInt(v: string): number {
    const n = Number.parseInt(v, 10)
    return Number.isNaN(n) ? 0 : n
  }

  private async save(): Promise<void> {
    const k = this.parseInt(this.knowTarget)
    const c = this.parseInt(this.checkTarget)
    const r = this.parseInt(this.reviewTarget)
    await ZhixingStore.saveWeeklyGoalTargets(k, c, r)
    await this.load()
    this.toastText = '本周目标已保存'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  build() {
    Stack() {
      Column() {
        AppNavBar({ title: '本周学习目标', onBack: (): void => { this.onClose() } })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('目标会随你的实际操作自动累计，可在下方调整期望值')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            this.GoalRow('新增知识', this.goal.doneKnowledge, this.goal.targetKnowledge,
              this.goal.knowledgePercent())
            this.GoalRow('习惯打卡', this.goal.doneChecks, this.goal.targetChecks,
              this.goal.checksPercent())
            this.GoalRow('完成复习', this.goal.doneReviews, this.goal.targetReviews,
              this.goal.reviewsPercent())
            Text('调整本周目标')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            TextInput({ text: this.knowTarget, placeholder: '新增知识条数' })
              .onChange((v: string) => { this.knowTarget = v })
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
            TextInput({ text: this.checkTarget, placeholder: '习惯打卡次数' })
              .onChange((v: string) => { this.checkTarget = v })
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
            TextInput({ text: this.reviewTarget, placeholder: '完成复习次数' })
              .onChange((v: string) => { this.reviewTarget = v })
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
            AppButton({ label: '保存目标', onTap: (): void => { void this.save() } })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 16 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  GoalRow(label: string, done: number, target: number, percent: number) {
    Column({ space: 6 }) {
      Row() {
        Text(label)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text(`${done} / ${target}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .width('100%')
      Progress({ value: percent, total: 100, type: ProgressType.Linear })
        .width('100%')
        .color(Theme.colors().brandPrimary)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
