import { Theme } from '../components/design-system/Theme'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { MixProgressBar } from '../components/sport/MixProgressBar'
import { FeelingStat, PersonalBestItem, ReviewSnapshot, SportSummary, TimelineEvent, TypeMixItem } from '../models/SportModels'
import { SportAnalytics } from '../services/SportAnalytics'
import { SportDetailNav } from '../services/SportDetailNav'
import { ProfileStore } from '../services/ProfileStore'
import { ReviewService } from '../services/ReviewService'
import { TimelineService } from '../services/TimelineService'
import { ChallengeStore } from '../services/ChallengeStore'
import { ChallengeListCard } from '../components/sport/ChallengeListCard'
import { SportChallenge } from '../models/SportModels'
import { SelectChip } from '../components/design-system/SelectChip'
import { SectionHeader } from '../components/design-system/SectionHeader'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State summary: SportSummary = new SportSummary()
  @State mixItems: TypeMixItem[] = []
  @State feelings: FeelingStat[] = []
  @State personalBests: PersonalBestItem[] = []
  @State progressPct: number = 0
  @State reviewPeriod: string = 'week'
  @State reviewSnap: ReviewSnapshot = new ReviewSnapshot()
  @State timeline: TimelineEvent[] = []
  @State challenges: SportChallenge[] = []
  @State insightTip: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.summary = SportAnalytics.summarize()
    this.mixItems = SportAnalytics.mixWithPercent()
    this.feelings = SportAnalytics.feelingStats()
    this.personalBests = SportAnalytics.personalBestList(5)
    this.progressPct = SportAnalytics.monthProgressPercent()
    this.reviewSnap = this.loadReview()
    this.timeline = TimelineService.build(12)
    this.challenges = ChallengeStore.list()
    this.insightTip = SportAnalytics.insightTip()
  }

  private loadReview(): ReviewSnapshot {
    if (this.reviewPeriod === 'today') {
      return ReviewService.today()
    }
    if (this.reviewPeriod === 'month') {
      return ReviewService.month()
    }
    return ReviewService.week()
  }

  private monthChartItems(): BarChartItem[] {
    const items: BarChartItem[] = []
    const labels = ['5月前', '4月前', '3月前', '2月前', '上月', '本月']
    const values = SportAnalytics.monthTrendValues()
    for (let i = 0; i < values.length; i++) {
      const item = new BarChartItem()
      item.value = values[i]
      item.label = labels[i] ?? `${i}`
      items.push(item)
    }
    return items
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        this.HeroBanner()
        this.InsightCard()
        this.ReviewSection()
        this.ChallengeSection()
        this.TrainingGuideSection()
        this.TimelineSection()
        this.CoreStatsGrid()
        this.MonthTrendCard()
        this.MixSection()
        this.FeelingSection()
        this.PersonalBestSection()
        this.AppButtonRow()
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s6,
        bottom: Theme.space.s10 + 88
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
    .onAppear(() => {
      this.reload()
    })
  }

  @Builder
  ReviewSection() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        this.ReviewChip('today', '今日')
        this.ReviewChip('week', '本周')
        this.ReviewChip('month', '本月')
      }
      .width('100%')
      Text(this.reviewSnap.periodLabel)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(`${this.reviewSnap.sessions} 次 · ${this.reviewSnap.durationMin} 分钟 · ${this.reviewSnap.distanceKm.toFixed(1)} km`)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      ForEach(this.reviewSnap.highlights, (line: string, idx: number) => {
        Text(`· ${line}`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }, (line: string, idx: number) => `${idx}_${line}`)
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  ReviewChip(period: string, label: string) {
    SelectChip({
      label: label,
      active: this.reviewPeriod === period,
      onTap: (): void => {
        this.reviewPeriod = period
        this.reviewSnap = this.loadReview()
      }
    })
  }

  @Builder
  InsightCard() {
    Row({ space: Theme.space.s3 }) {
      AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      Text(this.insightTip.length > 0 ? this.insightTip : '坚持记录，成长曲线会自动浮现。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
        .lineHeight(20)
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({
      width: { left: 4, top: 1, right: 1, bottom: 1 },
      color: {
        left: Theme.colors().brandPrimary,
        top: Theme.colors().strokeHairline,
        right: Theme.colors().strokeHairline,
        bottom: Theme.colors().strokeHairline
      }
    })
  }

  @Builder
  ChallengeSection() {
    Column({ space: Theme.space.s4 }) {
      SectionHeader({
        title: '赛季挑战',
        subtitle: '训练次数自动计入，点进详情可管理'
      })
      if (this.challenges.length === 0) {
        Text('还没有挑战。去「计划」页创建赛季目标，或在此继续记录训练。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.challenges, (c: SportChallenge) => {
          ChallengeListCard({
            item: c,
            onTap: (): void => {
              SportDetailNav.openChallenge(c.id)
            }
          })
        }, (c: SportChallenge) => `${c.id}_${c.status}`)
      }
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  TrainingGuideSection() {
    Column({ space: Theme.space.s3 }) {
      SectionHeader({
        title: '训练科学小贴士',
        subtitle: '结合记录字段，帮助形成可执行习惯'
      })
      this.GuideRow('赛前', '比赛日体感单独标记，便于与日常训练区分统计。')
      this.GuideRow('恢复', '连续「吃力」后安排「轻松」日，时长减半并写清不适部位。')
      this.GuideRow('复盘', '每场写一句「本场收获 + 下次重点」，比堆数据更有用。')
      this.GuideRow('挑战', '用赛季挑战锁定周频次，进度会随训练记录自动更新。')
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  GuideRow(tag: string, body: string) {
    Row({ space: Theme.space.s3 }) {
      Text(tag)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandOnPrimary)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
      Text(body)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
        .lineHeight(20)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  TimelineSection() {
    Column({ space: Theme.space.s3 }) {
      Text('成长时间轴')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.timeline.length === 0) {
        Text('完成训练、解锁成就后会在此汇总。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.timeline, (e: TimelineEvent) => {
          Row({ space: Theme.space.s3 }) {
            Column({ space: 2 }) {
              Text(e.date)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
              Text(e.title)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              if (e.subtitle.length > 0) {
                Text(e.subtitle)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.lg)
          .onClick(() => {
            if (e.eventType === 'record' && e.refId.length > 0) {
              SportDetailNav.open(e.refId)
            }
          })
        }, (e: TimelineEvent) => `${e.eventType}_${e.refId}_${e.date}`)
      }
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  HeroBanner() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_sport_bg'))
        .width('100%')
        .height(180)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(180)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: Theme.heroScrim()
        })
      Column({ space: 8 }) {
        Text('GROWTH')
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().textOnScrimMuted)
        Text('成长中心')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnScrim)
        Text(`累计 ${this.summary.totalSessions} 次 · ${this.summary.totalDurationMin} 分 · ${this.summary.totalDistanceKm.toFixed(1)} km`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnScrimMuted)
        Row({ space: Theme.space.s2 }) {
          Text(`连续 ${this.summary.streakDays} 天`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
          Text(`月度目标 ${this.progressPct}%`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textOnScrim)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('rgba(7,11,20,0.55)')
            .borderRadius(Theme.radius.pill)
        }
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  CoreStatsGrid() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppStatCard({ label: '本月次数', value: `${this.summary.monthSessions}`, accent: true })
        }
        .layoutWeight(1)
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        Column() {
          AppStatCard({ label: '本月时长', value: `${this.summary.monthDurationMin} 分` })
        }
        .layoutWeight(1)
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
      }
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppStatCard({ label: '本月里程', value: `${this.summary.monthDistanceKm.toFixed(1)} km` })
        }
        .layoutWeight(1)
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        Column() {
          AppStatCard({ label: '月度目标', value: `${ProfileStore.get().monthlyGoalSessions} 次` })
        }
        .layoutWeight(1)
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
      }
    }
    .width('100%')
  }

  @Builder
  MonthTrendCard() {
    Column({ space: Theme.space.s3 }) {
      Text('近 6 个月训练次数')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      AppBarChart({ items: this.monthChartItems() })
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  MixSection() {
    Column({ space: Theme.space.s3 }) {
      Text('项目配比')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.mixItems.length === 0) {
        Text('录入记录后自动生成分项占比与进度条。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.mixItems, (m: TypeMixItem) => {
          MixProgressBar({ sportType: m.sportType, sessions: m.sessions, percent: m.percent })
        }, (m: TypeMixItem) => m.sportType)
      }
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  FeelingSection() {
    Column({ space: Theme.space.s3 }) {
      Text('体感动态分布')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.feelings, (f: FeelingStat) => {
        Row({ space: Theme.space.s3 }) {
          Text(f.label)
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width(56)
          Stack({ alignContent: Alignment.Start }) {
            Column()
              .width('100%')
              .height(8)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
            Column()
              .width(`${Math.max(f.percent, 2)}%`)
              .height(8)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
          }
          .layoutWeight(1)
          Text(`${f.count} · ${f.percent}%`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
      }, (f: FeelingStat) => f.label)
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  PersonalBestSection() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('个人最佳')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('月度报告')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => {
            SportDetailNav.openMonthlyReport()
          })
      }
      .width('100%')
      if (this.personalBests.length === 0) {
        Text('填写距离后可生成各项目最佳成绩。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.personalBests, (pb: PersonalBestItem) => {
          Row() {
            Text(pb.sportType)
              .fontSize(Theme.type.subhead)
              .layoutWeight(1)
              .fontColor(Theme.colors().textPrimary)
            Text(`${pb.metricLabel} ${pb.metricValue}`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandPrimary)
            Text(pb.recordDate)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .margin({ left: 8 })
          }
          .width('100%')
        }, (pb: PersonalBestItem) => `${pb.sportType}_${pb.metricLabel}`)
      }
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  AppButtonRow() {
    Row({ space: Theme.space.s3 }) {
      Row() {
        AppIcon({ name: 'calendar', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        Text('训练日历')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .margin({ left: 8 })
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick(() => {
        SportDetailNav.openCalendar()
      })
      Row() {
        AppIcon({ name: 'ai', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        Text('配比问卷')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .margin({ left: 8 })
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick(() => {
        SportDetailNav.openDiagnose()
      })
    }
    .width('100%')
  }
}
