import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { FamilyGoal } from '../../models/JujiaModels'

@Component
export struct HomeGoalsBlock {
  @Prop goals: FamilyGoal[] = []
  onCreate: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Text('家庭目标')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.goals.length === 0) {
        Column({ space: 8 }) {
          Text('设定一个小目标，比如「本月整理 3 个房间」。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Row() {
            AppButton({ label: '创建目标', variant: 'secondary', onTap: (): void => { this.onCreate() } })
          }
          .width('100%')
          .onClick((): void => { this.onCreate() })
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      } else {
        ForEach(this.goals, (g: FamilyGoal) => {
          Column({ space: 6 }) {
            Text(g.title)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Progress({ value: g.progressPercent(), total: 100, type: ProgressType.Linear })
              .width('100%')
              .height(8)
              .color(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
            Text(g.progressLabel())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }, (g: FamilyGoal) => `${g.id}_${g.currentCount}`)
      }
    }
    .width('100%')
  }
}
