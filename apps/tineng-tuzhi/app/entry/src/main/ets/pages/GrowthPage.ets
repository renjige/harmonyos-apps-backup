import { Theme } from '../components/design-system/Theme'
import { HeatmapGrid } from '../components/fitness/HeatmapGrid'
import { MiniLineChart } from '../components/fitness/MiniLineChart'
import { MixBarChart } from '../components/fitness/MixBarChart'
import { PersonalBestGrid } from '../components/fitness/PersonalBestGrid'
import { WeekCompareCard } from '../components/fitness/WeekCompareCard'
import { AchievementState, CoachingReport, HeatmapCell, MixBar, PersonalBest, TrendPoint, WeekCompareSnapshot } from '../models/WorkoutModels'
import { Milestone } from '../models/TrainingModels'
import { AchievementService } from '../services/AchievementService'
import { DateHelper } from '../services/DateHelper'
import { ReportService } from '../services/ReportService'
import { StatsService } from '../services/StatsService'
import { WisdomService } from '../services/WisdomService'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('fitDataEpoch') @Watch('onDataEpochChange') fitDataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpenDay: (dateKey: string) => void = () => {}
  onOpenWeekReport: () => void = () => {}
  @State monthCount: number = 0
  @State mix: MixBar[] = []
  @State trend: TrendPoint[] = []
  @State heatmap: HeatmapCell[] = []
  @State marks: Milestone[] = []
  @State badges: AchievementState[] = []
  @State advice: string = ''
  @State unlocked: number = 0
  @State weekSnap: WeekCompareSnapshot = new WeekCompareSnapshot()
  @State bests: PersonalBest[] = []
  @State coaching: CoachingReport = new CoachingReport()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataEpochChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await AchievementService.evaluateAndUnlock()
    this.monthCount = await WisdomService.monthCount()
    this.mix = await WisdomService.weekMix()
    this.trend = await StatsService.trendPoints('month')
    this.heatmap = await StatsService.heatmapData()
    this.marks = await WisdomService.milestones()
    this.badges = await AchievementService.allStates()
    this.advice = await WisdomService.adviceLine()
    this.weekSnap = await StatsService.weekCompareSnapshot()
    this.bests = await StatsService.personalBests()
    this.coaching = await ReportService.weeklyCoaching()
    let n = 0
    for (const b of this.badges) {
      if (b.unlocked) {
        n++
      }
    }
    this.unlocked = n
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('体能成长')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Column({ space: Theme.space.s2 }) {
          Image($r('app.media.ambient_chart'))
            .width('100%')
            .height(64)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          Text('月度报告')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`本月训练 ${this.monthCount} 次 · 配比来自你的手动日志`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        WeekCompareCard({
          thisMinutes: this.weekSnap.thisMinutes,
          lastMinutes: this.weekSnap.lastMinutes,
          thisDays: this.weekSnap.thisDays
        })
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

        PersonalBestGrid({ items: this.bests })
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

        Column({ space: Theme.space.s2 }) {
          Text(this.coaching.title)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.coaching.paragraphs, (line: string, idx: number) => {
            Text(line)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .lineHeight(20)
              .width('100%')
          }, (line: string, idx: number) => `coach-${idx}`)
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.lg)

        MixBarChart({ items: this.mix })
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

        Column({ space: Theme.space.s2 }) {
          Text('本月趋势（按周 · 分钟）')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          MiniLineChart({ points: this.trend, chartHeight: 110 })
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        HeatmapGrid({
          cells: this.heatmap,
          monthLabel: `${DateHelper.currentMonthLabel()} · 点格子看当天日志`,
          onCellTap: (dateKey: string): void => { this.onOpenDay(dateKey) }
        })
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

        Column({ space: Theme.space.s2 }) {
          Text('智慧训练助手')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.advice)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.lg)

        Text('成长时间轴')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.marks, (m: Milestone) => {
          Column({ space: 4 }) {
            Text(m.whenKey)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
            Text(m.title)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
            Text(m.detail)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }, (m: Milestone) => m.id)

        Text(`训练成就  ${this.unlocked} / ${this.badges.length}`)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.badges, (b: AchievementState) => {
          Row() {
            Text(b.unlocked ? b.title : '未点亮')
              .fontSize(Theme.type.bodyS)
              .fontColor(b.unlocked ? Theme.colors().textPrimary : Theme.colors().textTertiary)
              .layoutWeight(1)
            Text(b.description)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .maxLines(1)
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
        }, (b: AchievementState) => b.id)

        Text('周图志报告')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => this.onOpenWeekReport())
          .width('100%')

        Row().height(this.bottomInset)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
