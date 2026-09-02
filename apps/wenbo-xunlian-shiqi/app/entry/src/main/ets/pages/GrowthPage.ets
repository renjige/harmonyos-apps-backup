import { Theme } from '../components/design-system/Theme'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { HeatmapGrid } from '../components/training/HeatmapGrid'
import { AchievementItem, HeatmapCell, MonthReport, StoryBeat, TypeCount } from '../models/TrainingModels'
import { TrainingAnalytics } from '../services/TrainingAnalytics'
import { AchievementEngine } from '../services/AchievementEngine'
import { StoryService } from '../services/StoryService'
import { VitalityStore } from '../services/VitalityStore'
import { DateHelper } from '../services/DateHelper'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpoch') dataEpoch: number = 0
  @Prop refreshToken: number = 0
  @State report: MonthReport = new MonthReport()
  @State heatCells: HeatmapCell[] = []
  @State heatYear: number = 2026
  @State heatMonth: number = 8
  @State typeRows: TypeCount[] = []
  @State beats: StoryBeat[] = []
  @State badges: AchievementItem[] = []
  @State points: number = 0
  @State longest: number = 0
  @State weekItems: BarChartItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onDataEpoch(): void {
    this.reload()
  }

  private reload(): void {
    const now = new Date()
    this.heatYear = now.getFullYear()
    this.heatMonth = now.getMonth() + 1
    this.report = TrainingAnalytics.monthReport(this.heatYear, this.heatMonth)
    this.heatCells = TrainingAnalytics.monthHeatmap(this.heatYear, this.heatMonth)
    this.typeRows = TrainingAnalytics.typeCounts()
    this.beats = StoryService.beats()
    this.badges = AchievementEngine.evaluate()
    this.points = VitalityStore.get().points
    this.longest = TrainingAnalytics.longestStreak()
    this.weekItems = this.chartItems()
  }

  private chartItems(): BarChartItem[] {
    const items: BarChartItem[] = []
    const labels = ['一', '二', '三', '四', '五', '六', '日']
    const trend = TrainingAnalytics.weekTrend()
    for (let i = 0; i < trend.length; i++) {
      const item = new BarChartItem()
      item.value = trend[i]
      item.label = labels[i] ?? `${i}`
      items.push(item)
    }
    return items
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('成长')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding({ top: Theme.space.s4 })

        Column({ space: Theme.space.s2 }) {
          Text(`${DateHelper.monthLabel(this.heatYear, this.heatMonth)} 报告`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`本月训练 ${this.report.sessions} 次 · ${this.report.minutes} 分钟`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`最常训练：${this.report.topType}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text(`完成比例 ${this.report.completeRate}% · 最长坚持 ${this.longest} 天`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text(`活力积分 ${this.points}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.accentOnSurface())
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        Column({ space: Theme.space.s3 }) {
          Text('近 7 日时长（分钟）')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          AppBarChart({ items: this.weekItems })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        if (this.typeRows.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Text('分类统计')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.typeRows, (row: TypeCount) => {
              Row() {
                Text(row.name)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(`${row.count} 次`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
            }, (row: TypeCount) => row.name)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }

        Text('活力日历')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        HeatmapGrid({ cells: this.heatCells, year: this.heatYear, month: this.heatMonth })

        Text('训练成长时间轴')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.beats.length === 0) {
          Text('记下第一次训练后，这里会展开你的运动故事。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        } else {
          ForEach(this.beats, (b: StoryBeat) => {
            Column({ space: 4 }) {
              Text(b.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(`${b.dateKey}  ${b.detail}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({ width: 1, color: Theme.colors().strokeHairline })
          }, (b: StoryBeat) => `${b.title}_${b.dateKey}`)
        }

        Text('成就徽章墙')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Grid() {
          ForEach(this.badges, (item: AchievementItem) => {
            GridItem() {
              Column({ space: 6 }) {
                Text(item.emoji)
                  .fontSize(28)
                  .opacity(item.unlocked ? 1 : 0.35)
                Text(item.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(item.unlocked ? Theme.colors().textPrimary : Theme.colors().textTertiary)
                  .maxLines(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }
          }, (item: AchievementItem) => item.id)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(Theme.space.s3)
        .rowsGap(Theme.space.s3)
        .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 + 88 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }
}
