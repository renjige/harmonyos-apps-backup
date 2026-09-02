import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { EmotionStat, InsightReport, KindOption, MilestoneItem, SceneStat, TrendPoint } from '../models/ObserveModels'
import { InsightService } from '../services/InsightService'
import { ObserveMedia } from '../services/ObserveMedia'
import { DateHelper } from '../services/DateHelper'
import { AchievementService } from '../services/AchievementService'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct InsightPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpenAchievements: () => void = () => {}
  onOpenTimeline: () => void = () => {}
  onOpenReview: (mode: string) => void = () => {}
  @State weekly: boolean = true
  @State report: InsightReport = new InsightReport()
  @State moodBars: BarChartItem[] = []
  @State sceneBars: BarChartItem[] = []
  @State trendBars: BarChartItem[] = []
  @State milestones: MilestoneItem[] = []
  @State kindTotals: number[] = [0, 0, 0, 0]
  @State weeklyReview: string[] = []
  @State achievementUnlocked: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.report = await InsightService.buildReport(this.weekly)
    const endKey = DateHelper.todayKey()
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - (this.weekly ? 6 : 29))
    const startKey = DateHelper.keyFromDate(startDate)
    const moods = await InsightService.moodStats(startKey, endKey)
    this.moodBars = InsightPage.toBars(moods)
    const scenes = await InsightService.sceneStats(startKey, endKey)
    this.sceneBars = InsightPage.sceneToBars(scenes)
    const trend = await InsightService.trendPoints(this.weekly ? 7 : 30)
    this.trendBars = InsightPage.trendToBars(trend)
    this.milestones = await InsightService.milestones()
    this.kindTotals = await InsightService.kindTotals()
    this.weeklyReview = await InsightService.buildWeeklyReview()
    this.achievementUnlocked = await AchievementService.unlockedCount()
  }

  private static toBars(stats: EmotionStat[]): BarChartItem[] {
    const out: BarChartItem[] = []
    for (const s of stats) {
      if (s.count > 0) {
        const b = new BarChartItem()
        b.label = s.label
        b.value = s.count
        out.push(b)
      }
    }
    return out
  }

  private static sceneToBars(stats: SceneStat[]): BarChartItem[] {
    const out: BarChartItem[] = []
    for (const s of stats) {
      if (s.count > 0) {
        const b = new BarChartItem()
        b.label = s.label
        b.value = s.count
        out.push(b)
      }
    }
    return out
  }

  private static trendToBars(points: TrendPoint[]): BarChartItem[] {
    const out: BarChartItem[] = []
    for (const p of points) {
      if (p.label.length > 0) {
        const b = new BarChartItem()
        b.label = p.label
        b.value = Math.round(p.score * 20)
        out.push(b)
      }
    }
    return out
  }

  private static kindTotal(kind: string, totals: number[]): number {
    const kinds = ['mood', 'scene', 'thought', 'environment']
    for (let i = 0; i < kinds.length; i++) {
      if (kinds[i] === kind) {
        return totals[i]
      }
    }
    return 0
  }

  private async handleShare(): Promise<void> {
    const lines: string[] = []
    lines.push('观物 · 智慧分析报告')
    lines.push(this.report.periodLabel)
    lines.push(`记录 ${this.report.recordCount} 条 · 连续 ${this.report.streakDays} 天`)
    lines.push(`心情主旋律：${this.report.mainMood}`)
    lines.push(`高频场景：${this.report.topScene}`)
    lines.push(this.report.wisdomMessage)
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, lines.join('\n'))
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('报告摘要已复制')
    } catch {
      this.showToast('复制失败')
    }
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(ObserveMedia.banner())
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(120)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0.1)', 0], ['rgba(26,26,46,0.85)', 1]]
              })
            Text('成长洞察')
              .fontSize(Theme.type.title2)
              .fontColor('#FFFFFF')
              .padding(Theme.space.s4)
          }
          .width('100%')
          .borderRadius(Theme.radius.md)
          .clip(true)

          Row({ space: Theme.space.s2 }) {
            Column() {
              AppButton({ label: '成就墙', variant: 'secondary', onTap: (): void => this.onOpenAchievements() })
            }.layoutWeight(1)
            Column() {
              AppButton({ label: '我的轨迹', variant: 'secondary', onTap: (): void => this.onOpenTimeline() })
            }.layoutWeight(1)
          }
          .width('100%')

          Text(`已解锁 ${this.achievementUnlocked} 项成就`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Row({ space: Theme.space.s2 }) {
            Text('今日回顾')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => this.onOpenReview('today'))
            Text('本周回顾')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => this.onOpenReview('week'))
            Text('本月回顾')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => this.onOpenReview('month'))
            Text('年度回顾')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => this.onOpenReview('year'))
          }
          .width('100%')

          Row({ space: Theme.space.s2 }) {
            Text('周报')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.weekly ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.weekly ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.weekly = true; void this.reload() })
            Text('月报')
              .fontSize(Theme.type.bodyS)
              .fontColor(!this.weekly ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(!this.weekly ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.weekly = false; void this.reload() })
          }

          Column({ space: Theme.space.s3 }) {
            Text(this.report.periodLabel)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Text(`共 ${this.report.recordCount} 条 · 连续观察 ${this.report.streakDays} 天`)
              .fontSize(Theme.type.title3)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.report.wisdomMessage)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(22)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          if (this.weekly && this.weeklyReview.length > 0) {
            Text('本周回顾')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Column({ space: Theme.space.s2 }) {
              ForEach(this.weeklyReview, (line: string, idx: number) => {
                Row({ space: Theme.space.s2 }) {
                  Text('·')
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().brandPrimary)
                  Text(line)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textSecondary)
                    .lineHeight(20)
                    .layoutWeight(1)
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)
              }, (line: string, idx: number) => `wr-${idx}-${line.substring(0, 8)}`)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }

          Text('四象图鉴')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          ForEach(KindOption.all(), (k: KindOption) => {
            Row({ space: Theme.space.s3 }) {
              Image(ObserveMedia.kindCover(k.key))
                .width(56)
                .height(56)
                .borderRadius(Theme.radius.sm)
                .objectFit(ImageFit.Cover)
              Column({ space: 4 }) {
                Text(k.label)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(k.hint)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Text(`${InsightPage.kindTotal(k.key, this.kindTotals)}`)
                .fontSize(Theme.type.title3)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (k: KindOption) => k.key)

          if (this.moodBars.length > 0) {
            AppBarChart({ title: '心情分布', items: this.moodBars })
          }
          if (this.sceneBars.length > 0) {
            AppBarChart({ title: '场景热力', items: this.sceneBars })
          }
          if (this.trendBars.length > 0) {
            AppBarChart({ title: '心情趋势', items: this.trendBars })
          }

          Text('里程碑')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          ForEach(this.milestones, (m: MilestoneItem) => {
            Row() {
              Text(m.title)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              Text(m.reached ? '已达成' : `目标 ${m.threshold}`)
                .fontSize(Theme.type.caption)
                .fontColor(m.reached ? Theme.colors().success : Theme.colors().textTertiary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (m: MilestoneItem) => m.title)

          AppButton({
            label: '复制报告摘要',
            variant: 'secondary',
            onTap: (): void => { void this.handleShare() }
          })
        }
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4, bottom: this.bottomInset })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '12%', y: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
