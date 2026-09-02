import { Theme } from '../components/design-system/Theme'
import { AppBarChart, AppRingChart } from '../components/design-system/AppChart'
import { BarChartItem } from '../components/design-system/AppChart'
import { CategoryStat, DashboardStats } from '../models/UserKnowledgeModels'
import { StatsService } from '../services/StatsService'

@Component
export struct StatsOverlayPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onClose: () => void = () => {}
  @State stats: DashboardStats = new DashboardStats()
  @State weekBars: BarChartItem[] = []
  @State categories: CategoryStat[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await StatsService.dashboard()
    this.weekBars = await StatsService.weekReadBars()
    this.categories = await StatsService.categoryBreakdown()
  }

  build() {
    Column() {
      Row() {
        Text('数据统计')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('返回')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => this.onClose())
      }
      .width('100%')
      .padding(Theme.space.pageX)

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppRingChart({
            title: '本周阅读计划',
            percent: this.stats.planTarget > 0 ? this.stats.planDone / this.stats.planTarget : 0
          })

          Row({ space: Theme.space.s2 }) {
            this.numCard('累计阅读', `${this.stats.readCount}`)
            this.numCard('自建知识', `${this.stats.knowledgeCount}`)
          }
          .width('100%')

          Row({ space: Theme.space.s2 }) {
            this.numCard('灵感', `${this.stats.sparkCount}`)
            this.numCard('连续打卡', `${this.stats.streakDays}天`)
          }
          .width('100%')

          AppBarChart({ title: '本周打卡', items: this.weekBars })

          if (this.categories.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('知识分类')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.categories, (c: CategoryStat) => {
                Row() {
                  Text(c.label)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Text(`${c.count} 条`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textSecondary)
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
              }, (c: CategoryStat) => c.label)
            }
            .width('100%')
          }
        }
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(22)
  }

  @Builder
  numCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }
}
