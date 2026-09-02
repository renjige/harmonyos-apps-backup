import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DayDetailOverlay } from '../components/vitality/DayDetailOverlay'
import {
  DimensionStat, MicroAction, TrendPoint, VitalityRecord,   WeekCompare, YearReport
} from '../models/VitalityModels'
import { DateHelper } from '../services/DateHelper'
import { VitalityStore } from '../services/VitalityStore'
import { AchievementService, StatsService } from '../services/StatsService'
import { PrescriptionService } from '../services/PrescriptionService'
import { VitalityInsightsCard, BreathingGuideOverlay } from '../components/vitality/VitalityExtras'

enum ReviewMode {
  Week = 0,
  Month = 1,
  Year = 2
}

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onChanged: () => void = () => {}
  @State mode: ReviewMode = ReviewMode.Week
  @State trends: TrendPoint[] = []
  @State moodStats: DimensionStat[] = []
  @State monthCheckIns: number = 0
  @State monthRate: number = 0
  @State compare: WeekCompare = new WeekCompare()
  @State trail: VitalityRecord[] = []
  @State weeklyText: string = ''
  @State weekKey: string = ''
  @State showDetail: boolean = false
  @State detailRecord: VitalityRecord = new VitalityRecord()
  @State detailActions: MicroAction[] = []
  @State detailPinned: boolean = false
  @State toastText: string = ''
  @State insightText: string = ''
  @State showBreathing: boolean = false
  @State yearReport: YearReport | undefined = undefined

  aboutToAppear(): void {
    this.weekKey = DateHelper.weekKey(DateHelper.todayKey())
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.monthCheckIns = await StatsService.monthCheckInCount()
    this.monthRate = await StatsService.monthCheckInRate()
    this.insightText = await StatsService.currentMonthInsight()
    this.yearReport = await StatsService.yearReport()
    this.compare = await StatsService.weekCompare()
    this.weeklyText = await VitalityStore.loadWeekly(this.weekKey)
    let days = 30
    if (this.mode === ReviewMode.Week) {
      days = 7
    } else if (this.mode === ReviewMode.Year) {
      days = 365
    }
    this.trends = await StatsService.trendPoints(days)
    const keys = DateHelper.lastNDays(days)
    keys.reverse()
    this.moodStats = await StatsService.dimensionStats(keys[0], keys[keys.length - 1])
    const all = await VitalityStore.loadAll()
    const t: VitalityRecord[] = []
    for (const r of all) {
      if (r.isComplete() && t.length < 14) {
        t.push(r)
      }
    }
    this.trail = t
  }

  private maxTrend(): number {
    let m = 1
    for (const p of this.trends) {
      if (p.score > m) {
        m = p.score
      }
    }
    return m
  }

  private heatColor(score: number): string {
    if (score <= 0) {
      return Theme.colors().surfaceSubtle
    }
    if (score >= 80) {
      return '#FF6B35'
    }
    if (score >= 50) {
      return '#FF9F76'
    }
    return '#FFD4C2'
  }

  private async openDetail(key: string): Promise<void> {
    const r = await VitalityStore.recordForDate(key)
    if (r === undefined || !r.isComplete()) {
      this.toastText = '这一天还没有记录'
      setTimeout((): void => { this.toastText = '' }, 2000)
      return
    }
    this.detailRecord = r
    this.detailActions = await PrescriptionService.ensureFor(r)
    this.detailPinned = await VitalityStore.isPinned(key)
    this.showDetail = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeDetail(): void {
    this.showDetail = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async saveDetail(ex: string, mood: string, energy: string, note: string): Promise<void> {
    const rec = this.detailRecord
    rec.exerciseKey = ex
    rec.moodKey = mood
    rec.energyKey = energy
    rec.note = note.trim()
    await VitalityStore.saveRecord(rec)
    this.detailRecord = rec
    await AchievementService.evaluateAndUnlock()
    this.onChanged()
    await this.reload()
  }

  private async deleteDetail(): Promise<void> {
    await VitalityStore.deleteRecord(this.detailRecord.dateKey)
    this.closeDetail()
    this.onChanged()
    await this.reload()
  }

  private async saveWeekly(): Promise<void> {
    const t = this.weeklyText.trim()
    if (t.length === 0) {
      this.toastText = '请先写一句本周纪行'
      setTimeout((): void => { this.toastText = '' }, 2000)
      return
    }
    await VitalityStore.saveWeekly(this.weekKey, t)
    await AchievementService.evaluateAndUnlock()
    this.toastText = '本周纪行已保存'
    setTimeout((): void => { this.toastText = '' }, 2000)
    this.onChanged()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Text('活力回顾')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s2 }) {
            this.ModeChip('周', ReviewMode.Week)
            this.ModeChip('月', ReviewMode.Month)
            this.ModeChip('年', ReviewMode.Year)
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            this.StatBox(`${this.monthCheckIns}`, '本月打卡', Theme.colors().brandPrimary)
            this.StatBox(`${this.monthRate}%`, '本月打卡率', Theme.colors().success)
          }
          .width('100%')

          VitalityInsightsCard({
            insightText: this.insightText,
            onBreathing: (): void => {
              this.showBreathing = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          })

          Column({ space: Theme.space.s2 }) {
            Text('近 7 天 vs 上 7 天')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.compare.lastDays === 0 && this.compare.thisDays === 0 ?
              '记录几天后，这里会对比两周平均活力值。' :
              `本周均分 ${this.compare.thisAvg}（${this.compare.thisDays} 天），上周 ${this.compare.lastAvg}，差值 ${this.compare.delta >= 0 ? '+' : ''}${this.compare.delta}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          if (this.mode === ReviewMode.Week) {
            Column({ space: Theme.space.s2 }) {
              Text('本周纪行（一句）')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              TextArea({ text: this.weeklyText, placeholder: '这周最想记住的一件事…' })
                .height(72)
                .onChange((v: string): void => { this.weeklyText = v })
              AppButton({
                label: '保存本周纪行',
                variant: 'primary',
                onTap: (): void => { void this.saveWeekly() }
              })
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            this.WeekChart()
          } else if (this.mode === ReviewMode.Month) {
            this.MonthHeatmap()
          } else if (this.yearReport !== undefined) {
            Column({ space: Theme.space.s2 }) {
              Text(`${this.yearReport.year} 年度回顾`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
              Text(this.yearReport.summary)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .lineHeight(22)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .alignItems(HorizontalAlign.Start)
          } else {
            Text('今年还没有足够记录，完成打卡后会生成年回顾')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }

          if (this.moodStats.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('所选周期心情分布')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              ForEach(this.moodStats, (e: DimensionStat) => {
                Row({ space: Theme.space.s2 }) {
                  Text(e.label)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width(48)
                  Stack({ alignContent: Alignment.Start }) {
                    Row().width('100%').height(10)
                      .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.pill)
                    Row().width(`${Math.round(e.ratio * 100)}%`).height(10)
                      .backgroundColor(Theme.colors().brandPrimary).borderRadius(Theme.radius.pill)
                  }
                  .layoutWeight(1)
                  Text(`${Math.round(e.ratio * 100)}%`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                    .width(36)
                }
                .width('100%')
              }, (e: DimensionStat) => e.key)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          }

          Text('足迹 · 点进详情可编辑或删除')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.trail.length === 0) {
            Column() {
              Image($r('app.media.empty_calm'))
                .width('100%')
                .height(100)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Text('还没有足迹。去今日页用 3 秒记下状态，再完成一条处方。')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .padding({ top: Theme.space.s3 })
            }
            .width('100%')
          } else {
            ForEach(this.trail, (r: VitalityRecord) => {
              Row() {
                Column({ space: 4 }) {
                  Text(DateHelper.displayDate(r.dateKey))
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(`活力 ${r.vitalityScore()} · ${r.note.length > 0 ? r.note : '无备注'}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { void this.openDetail(r.dateKey) })
            }, (r: VitalityRecord) => r.dateKey)
          }

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.showDetail) {
        DayDetailOverlay({
          dateLabel: DateHelper.displayDate(this.detailRecord.dateKey),
          record: this.detailRecord,
          actions: this.detailActions,
          pinned: this.detailPinned,
          onClose: (): void => this.closeDetail(),
          onToggleAction: (id: string): void => { void this.toggleDetailAction(id) },
          onTogglePin: (): void => { void this.toggleDetailPin() },
          onSave: (ex: string, mood: string, energy: string, note: string): void => {
            void this.saveDetail(ex, mood, energy, note)
          },
          onDelete: (): void => { void this.deleteDetail() }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,42,58,0.88)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 56 })
          .markAnchor({ x: '50%', y: 0 })
          .zIndex(50)
      }

      if (this.showBreathing) {
        BreathingGuideOverlay({
          onClose: (): void => {
            this.showBreathing = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  private async toggleDetailAction(id: string): Promise<void> {
    await VitalityStore.toggleAction(id)
    this.detailActions = await VitalityStore.actionsForDate(this.detailRecord.dateKey)
    await AchievementService.evaluateAndUnlock()
    this.onChanged()
  }

  private async toggleDetailPin(): Promise<void> {
    this.detailPinned = await VitalityStore.togglePin(this.detailRecord.dateKey)
    await AchievementService.evaluateAndUnlock()
    this.onChanged()
  }

  @Builder
  StatBox(value: string, label: string, color: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  ModeChip(label: string, m: ReviewMode) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.mode === m ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 20, right: 20, top: 8, bottom: 8 })
      .backgroundColor(this.mode === m ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.mode = m; void this.reload() })
  }

  @Builder
  WeekChart() {
    Column({ space: Theme.space.s3 }) {
      Text('近 7 天活力趋势 · 点柱看详情')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      if (this.trends.every((p: TrendPoint) => p.score === 0)) {
        AppEmpty({
          title: '暂无数据',
          description: '完成今日打卡后，趋势会在这里呈现',
          actionLabel: '',
          onAction: (): void => {}
        })
      } else {
        Row({ space: Theme.space.s1 }) {
          ForEach(this.trends, (p: TrendPoint) => {
            Column({ space: 4 }) {
              Column()
                .width('100%')
                .height(p.score > 0 ? 100 * (p.score / this.maxTrend()) : 4)
                .backgroundColor(p.score > 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.xs)
              Text(p.label)
                .fontSize(10)
                .fontColor(Theme.colors().textTertiary)
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.End)
            .height(120)
            .onClick((): void => { void this.openDetail(p.dateKey) })
          }, (p: TrendPoint) => p.dateKey)
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  MonthHeatmap() {
    Column({ space: Theme.space.s3 }) {
      Text(`${DateHelper.currentMonthLabel()} 活力日历 · 点格子看详情`)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.trends, (p: TrendPoint) => {
          Column()
            .width('12%')
            .height(28)
            .margin({ right: '1%', bottom: 6 })
            .backgroundColor(this.heatColor(p.score))
            .borderRadius(Theme.radius.xs)
            .onClick((): void => { void this.openDetail(p.dateKey) })
        }, (p: TrendPoint) => p.dateKey)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
