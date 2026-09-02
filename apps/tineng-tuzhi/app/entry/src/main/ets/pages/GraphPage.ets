import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { HeatmapGrid } from '../components/fitness/HeatmapGrid'
import { MiniLineChart } from '../components/fitness/MiniLineChart'
import { MixBarChart } from '../components/fitness/MixBarChart'
import { WeekCompareCard } from '../components/fitness/WeekCompareCard'
import { HeatmapCell, MixBar, TrendPoint } from '../models/WorkoutModels'
import { DateHelper } from '../services/DateHelper'
import { StatsService } from '../services/StatsService'

class TimeModeOption {
  key: string = 'week'
  label: string = '周'

  static all(): TimeModeOption[] {
    const out: TimeModeOption[] = []
    const rows: string[][] = [['week', '周'], ['month', '月'], ['year', '年']]
    for (const row of rows) {
      const o = new TimeModeOption()
      o.key = row[0]
      o.label = row[1]
      out.push(o)
    }
    return out
  }
}

@Component
export struct GraphPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpenDay: (dateKey: string) => void = () => {}
  onOpenAtlas: () => void = () => {}
  onOpenPlan: () => void = () => {}
  @State timeMode: string = 'week'
  @State trend: TrendPoint[] = []
  @State heatmap: HeatmapCell[] = []
  @State mix: MixBar[] = []
  @State thisMinutes: number = 0
  @State lastMinutes: number = 0
  @State thisDays: number = 0
  @State totalWorkouts: number = 0
  @State totalMinutes: number = 0
  @State totalCalories: number = 0
  @State totalDistanceText: string = '0'

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.trend = await StatsService.trendPoints(this.timeMode)
    this.heatmap = await StatsService.heatmapData()
    const stats = await StatsService.totals()
    this.totalWorkouts = stats.totalWorkouts
    this.totalMinutes = stats.totalMinutes
    this.totalCalories = stats.totalCalories
    this.totalDistanceText = `${stats.totalDistanceKm}`
    const snap = await StatsService.weekCompareSnapshot()
    this.thisMinutes = snap.thisMinutes
    this.lastMinutes = snap.lastMinutes
    this.thisDays = snap.thisDays
    const keys = DateHelper.weekDateKeys(DateHelper.todayKey())
    if (keys.length >= 7) {
      this.mix = await StatsService.sportMix(keys[0], keys[6])
    }
  }

  private async switchMode(key: string): Promise<void> {
    this.timeMode = key
    await this.reload()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('体能图志')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s2 }) {
          Column() {
            AppButton({
              label: '周图志报告',
              variant: 'primary',
              onTap: (): void => this.onOpenAtlas()
            })
          }
          .layoutWeight(1)
          Column() {
            AppButton({
              label: '编排周训',
              variant: 'secondary',
              onTap: (): void => this.onOpenPlan()
            })
          }
          .layoutWeight(1)
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          ForEach(TimeModeOption.all(), (opt: TimeModeOption) => {
            Text(opt.label)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.timeMode === opt.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.timeMode === opt.key ?
                Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { void this.switchMode(opt.key) })
          }, (opt: TimeModeOption) => opt.key)
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('运动趋势（分钟）')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          MiniLineChart({ points: this.trend, chartHeight: 120 })
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Column({ space: Theme.space.s3 }) {
          HeatmapGrid({
            cells: this.heatmap,
            monthLabel: `${DateHelper.currentMonthLabel()} · 点格子看当天`,
            onCellTap: (dateKey: string): void => { this.onOpenDay(dateKey) }
          })
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        WeekCompareCard({
          thisMinutes: this.thisMinutes,
          lastMinutes: this.lastMinutes,
          thisDays: this.thisDays
        })
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

        MixBarChart({ items: this.mix })
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

        Row({ space: Theme.space.s3 }) {
          this.StatCard(`${this.totalWorkouts}`, '累计次数')
          this.StatCard(`${this.totalMinutes}`, '累计分钟')
        }
        .width('100%')
        Row({ space: Theme.space.s3 }) {
          this.StatCard(`${this.totalCalories}`, '累计千卡')
          this.StatCard(this.totalDistanceText, '累计公里')
        }
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

  @Builder
  StatCard(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }
}
