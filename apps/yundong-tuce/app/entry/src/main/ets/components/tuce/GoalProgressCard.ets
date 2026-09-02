import { Theme } from '../design-system/Theme'
import { GoalProgress } from '../../models/TuceModels'

@Component
export struct GoalProgressCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop progress: GoalProgress = new GoalProgress()

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('运动目标')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text(`${Math.round(this.progress.weeklyPct * 100)}% 周完成`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')

      Column({ space: 6 }) {
        Row() {
          Text('本周打卡')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .layoutWeight(1)
          Text(`${this.progress.weeklyDone}/${this.progress.weeklyTarget} 天`)
            .fontSize(Theme.type.bodyS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .width('100%')
        Progress({ value: this.progress.weeklyPct * 100, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(8)
          .color(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .style({ strokeWidth: 8 })
      }
      .width('100%')

      Column({ space: 6 }) {
        Row() {
          Text('本月训练')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .layoutWeight(1)
          Text(`${this.progress.monthlyDone}/${this.progress.monthlyTarget} 次`)
            .fontSize(Theme.type.bodyS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .width('100%')
        Progress({ value: this.progress.monthlyPct * 100, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(8)
          .color('#FF6B35')
          .backgroundColor(Theme.colors().surfaceSubtle)
          .style({ strokeWidth: 8 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
