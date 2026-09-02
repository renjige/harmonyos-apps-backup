import { Theme } from '../design-system/Theme'
import { AppStatCard } from '../design-system/AppStatCard'
import { AppBarChart, AppRingChart, BarChartItem } from '../design-system/AppChart'
import { ArchiveStats } from '../../models/ArchiveModels'
import { WeeklyActivityBar } from '../../models/LifeModels'
import { ArchiveStatsService } from '../../services/ArchiveStatsService'
import { LifeStorePhase3 } from '../../services/LifeStorePhase3'

@Component
export struct DataCenterSection {
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State stats: ArchiveStats = new ArchiveStats()
  @State weeklyBars: WeeklyActivityBar[] = []
  @State barItems: BarChartItem[] = []
  @State albumCount: number = 0
  @State checklistDone: number = 0
  @State experienceCount: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await ArchiveStatsService.computeStats()
    this.weeklyBars = await ArchiveStatsService.buildWeeklyActivityBars()
    const items: BarChartItem[] = []
    for (const w of this.weeklyBars) {
      const item = new BarChartItem()
      item.label = w.label
      item.value = w.count
      items.push(item)
    }
    this.barItems = items
    const albums = await LifeStorePhase3.loadThemeAlbums()
    this.albumCount = albums.length
    this.checklistDone = await LifeStorePhase3.countChecklistDone()
    const exps = await LifeStorePhase3.loadExperiences()
    this.experienceCount = exps.length
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        AppStatCard({ label: '档案', value: `${this.stats.totalArchives}` }).layoutWeight(1)
        AppStatCard({ label: '节点', value: `${this.stats.totalNodes}` }).layoutWeight(1)
      }
      .width('100%')
      Row({ space: Theme.space.s2 }) {
        AppStatCard({ label: '主题册', value: `${this.albumCount}` }).layoutWeight(1)
        AppStatCard({ label: '经验', value: `${this.experienceCount}` }).layoutWeight(1)
      }
      .width('100%')

      AppBarChart({
        title: '近 7 日活跃（节点+习惯+计划）',
        items: this.barItems
      })

      AppRingChart({
        title: '档案完成度',
        percent: this.stats.completionAvg / 100
      })

      if (this.stats.topCategoryLabel.length > 0) {
        Column({ space: Theme.space.s2 }) {
          Text('分类分布')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`最多记录 · ${this.stats.topCategoryLabel}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
          if (this.stats.richestYear.length > 0) {
            Text(`${this.stats.richestYear} 年 · ${this.stats.richestYearCount} 节点`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
          Text(`人生清单已完成 ${this.checklistDone} 项`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
  }
}
