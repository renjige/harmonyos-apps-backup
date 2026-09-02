import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { LearningHubService } from '../services/LearningHubService'
import { LearningPlan } from '../models/LearningHubModels'

@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State plan: LearningPlan = new LearningPlan()
  @State targetDraft: string = '7'
  @State toastText: string = ''

  aboutToAppear(): void {
    this.plan = LearningHubService.plan()
    this.targetDraft = `${this.plan.targetCount}`
  }

  private async saveTarget(): Promise<void> {
    const n = parseInt(this.targetDraft, 10)
    if (isNaN(n) || n < 1) {
      this.toastText = '请输入 1–21 的目标条数'
      setTimeout((): void => { this.toastText = '' }, 1800)
      return
    }
    await LearningHubService.setPlanTarget(n)
    this.plan = LearningHubService.plan()
    this.toastText = '本周计划已更新'
    setTimeout((): void => { this.toastText = '' }, 1800)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44).height(44).justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { CommonSenseDetailNav.close() })
          Text('学习计划')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Column({ space: Theme.space.s3 }) {
          Text(`本周 ${this.plan.weekKey}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text(`已完成 ${this.plan.completedCount} / ${this.plan.targetCount} 条`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Progress({ value: this.plan.progressPercent(), total: 100, type: ProgressType.Linear })
            .width('100%')
            .color(Theme.colors().brandPrimary)
          Text('每周阅读目标（条）')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
            .margin({ top: Theme.space.s2 })
          TextInput({ text: this.targetDraft, placeholder: '7' })
            .type(InputType.Number)
            .onChange((v: string): void => { this.targetDraft = v })
          AppButton({ label: '保存计划', onTap: (): void => { void this.saveTarget() } })
          Text('阅读常识详情会自动计入本周进度；完成目标可解锁「计划达成」成就。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .padding(Theme.space.s5)
        .width('100%')
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%').height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%').height('100%').zIndex(18)
  }
}
