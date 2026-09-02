import { Theme } from '../components/design-system/Theme'
import { AppBarChart, AppRingChart, BarChartItem } from '../components/design-system/AppChart'
import { AppIcon } from '../components/design-system/AppIcon'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CommonSenseStore } from '../services/CommonSenseStore'
import { LearningHubService } from '../services/LearningHubService'
import { CommonSenseStats } from '../models/CommonSenseModels'
import { CategoryStat, DayStat } from '../models/LearningHubModels'

@Component
export struct GrowthDashboardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State stats: CommonSenseStats = new CommonSenseStats()
  @State dayStats: DayStat[] = []
  @State catStats: CategoryStat[] = []
  @State barItems: BarChartItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.stats = CommonSenseStore.stats()
    this.dayStats = LearningHubService.dailyStats(7)
    this.catStats = LearningHubService.categoryStats()
    const bars: BarChartItem[] = []
    for (const row of this.dayStats) {
      const item = new BarChartItem()
      item.label = row.label
      item.value = row.count
      bars.push(item)
    }
    this.barItems = bars
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44).height(44).justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { CommonSenseDetailNav.close() })
          Text('成长看板')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Row({ space: Theme.space.s2 }) {
          Column({ space: 4 }) {
            Text(`${this.stats.readCount}`)
              .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Theme.colors().brandPrimary)
            Text('已阅读').fontSize(12).fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1).padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.card)
          Column({ space: 4 }) {
            Text(`${this.stats.mastered}`)
              .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Theme.colors().brandPrimary)
            Text('已掌握').fontSize(12).fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1).padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.card)
          Column({ space: 4 }) {
            Text(`${this.stats.checkInStreak}`)
              .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Theme.colors().brandPrimary)
            Text('连续打卡').fontSize(12).fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1).padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.card)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        AppRingChart({
          title: '本周计划完成率',
          percent: LearningHubService.plan().progressPercent() / 100
        })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        AppBarChart({ title: '近 7 日学习次数', items: this.barItems })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.catStats.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('阅读分类分布')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.catStats, (row: CategoryStat) => {
              Row() {
                Text(row.label)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
                  .layoutWeight(1)
                Text(`${row.count}`)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
            }, (row: CategoryStat) => row.category)
          }
          .padding(Theme.space.s5)
          .width('100%')
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
      }
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .zIndex(18)
  }
}
