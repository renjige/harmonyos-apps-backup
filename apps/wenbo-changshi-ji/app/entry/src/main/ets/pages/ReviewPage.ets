import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { LearningHubService } from '../services/LearningHubService'
import { WeekReviewSummary } from '../models/LearningHubModels'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State summary: WeekReviewSummary = new WeekReviewSummary()

  aboutToAppear(): void {
    this.summary = LearningHubService.weekReview()
  }

  @Builder
  StatRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .layoutWeight(1)
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44).height(44).justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { CommonSenseDetailNav.close() })
        Text('本周回顾')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Column({ space: Theme.space.s1 }) {
        Text(`统计周期 ${this.summary.weekKey}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        this.StatRow('阅读记录', `${this.summary.readCount} 次`)
        this.StatRow('常识小测', `${this.summary.quizCount} 次`)
        this.StatRow('新增收藏', `${this.summary.favoriteCount} 次`)
        this.StatRow('深度掌握', `${this.summary.masterCount} 次`)
        this.StatRow('清单掌握', `${this.summary.listLearnCount} 次`)
        this.StatRow('打卡天数', `${this.summary.checkInDays} 天`)
      }
      .padding(Theme.space.s5)
      .width('100%')
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.card)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

      AppButton({
        label: '查看详细统计',
        variant: 'secondary',
        onTap: (): void => { CommonSenseDetailNav.openGrowth() }
      })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

      AppButton({
        label: '继续本周计划',
        onTap: (): void => { CommonSenseDetailNav.openPlan() }
      })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(18)
  }
}
