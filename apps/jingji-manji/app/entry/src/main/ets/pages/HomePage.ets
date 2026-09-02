import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppCard } from '../components/design-system/AppCard'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { AppIcon } from '../components/design-system/AppIcon'
import { SectionHeader } from '../components/design-system/SectionHeader'
import { StatTile } from '../components/design-system/StatTile'
import { GlassPanel } from '../components/design-system/GlassPanel'
import { FeatureActionCard } from '../components/home/FeatureActionCard'
import { MixProgressBar } from '../components/sport/MixProgressBar'
import { ChallengeListCard } from '../components/sport/ChallengeListCard'
import { SportListCard } from '../components/sport/SportListCard'
import { SportRecord, SportSummary, TypeMixItem, WeekCompare, PersonalBestItem, SportChallenge } from '../models/SportModels'
import { SportAnalytics } from '../services/SportAnalytics'
import { ProfileStore } from '../services/ProfileStore'
import { SportStore } from '../services/SportStore'
import { SportDetailNav } from '../services/SportDetailNav'
import { ChallengeStore } from '../services/ChallengeStore'
import { WorkbenchService } from '../services/WorkbenchService'
import { WorkbenchStats } from '../models/SportModels'
import { SportModelClone } from '../services/SportModelClone'
import { DiagnoseReportStore } from '../services/DiagnoseReportStore'
import { AppButton } from '../components/design-system/AppButton'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '竞技漫记'
  @State summary: SportSummary = new SportSummary()
  @State progressPct: number = 0
  @State nickname: string = '运动者'
  @State recentItems: SportRecord[] = []
  @State mixItems: TypeMixItem[] = []
  @State activeChallenge: string = ''
  @State weekCompare: WeekCompare = new WeekCompare()
  @State personalBests: PersonalBestItem[] = []
  @State insightTip: string = ''
  @State activeChallenges: SportChallenge[] = []
  @State workbench: WorkbenchStats = new WorkbenchStats()
  @State recentRev: number = 0
  @State lastDiagnoseCategory: string = ''
  @State lastDiagnoseScore: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop @Watch('onSportEpochChange') sportEpoch: number = 0
  @StorageLink('diagnoseReportEpoch') @Watch('onDiagnoseEpochChange') diagnoseReportEpoch: number = 0
  onSwitchTab: (index: number) => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  onSportEpochChange(): void {
    this.reload()
  }

  onDiagnoseEpochChange(): void {
    this.reloadDiagnoseHint()
  }

  private reloadDiagnoseHint(): void {
    const latest = DiagnoseReportStore.latest()
    if (latest !== null) {
      this.lastDiagnoseCategory = latest.matchCategory
      this.lastDiagnoseScore = latest.scoreLabel
    } else {
      this.lastDiagnoseCategory = ''
      this.lastDiagnoseScore = ''
    }
  }

  private reload(): void {
    this.summary = SportAnalytics.summarize()
    this.progressPct = SportAnalytics.monthProgressPercent()
    this.nickname = ProfileStore.get().nickname
    this.recentItems = SportStore.recent(3)
    this.recentRev += 1
    this.mixItems = this.summary.typeMix
    const chs = ChallengeStore.active()
    this.activeChallenge = chs.length > 0 ? `${chs[0].title} · ${SportAnalytics.challengeProgress(chs[0]).sessionPct}%` : ''
    this.weekCompare = SportAnalytics.weekCompare()
    this.personalBests = SportAnalytics.personalBestList(3)
    this.insightTip = SportAnalytics.insightTip()
    this.activeChallenges = ChallengeStore.active()
    this.workbench = WorkbenchService.stats()
    this.reloadDiagnoseHint()
  }

  private chartItems(): BarChartItem[] {
    const items: BarChartItem[] = []
    const labels = ['一', '二', '三', '四', '五', '六', '日']
    for (let i = 0; i < this.summary.weekTrend.length; i++) {
      const item = new BarChartItem()
      item.value = this.summary.weekTrend[i]
      item.label = labels[i] ?? `${i}`
      items.push(item)
    }
    return items
  }

  build() {
    Scroll() {
      Column({ space: 0 }) {
        this.HeroSection()
        Column({ space: Theme.space.s6 }) {
          this.TodayWorkbench()
          this.QuickActions()
          this.InsightCard()
          this.DiagnoseHintCard()
          this.WeekCompareCard()
          this.ProgressRingCard()
          this.MixRow()
          this.PersonalBestSection()
          this.ActiveChallengeSection()
          this.RecentSection()
          this.StreakBanner()
        }
        .padding(Theme.space.pageX)
        .margin({ top: -52 })
        .padding({ bottom: Theme.space.s10 + 96 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .linearGradient({
      angle: 180,
      colors: Theme.isDark() ?
        [['#070B14', 0.0], ['#0D1528', 0.35], ['#070B14', 1.0]] :
        [['#F8FAFC', 0.0], ['#EEF2FF', 0.4], ['#F8FAFC', 1.0]]
    })
    .edgeEffect(EdgeEffect.Spring)
    .onAppear(() => {
      this.reload()
    })
  }

  @Builder
  HeroSection() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_sport_bg'))
        .width('100%')
        .height(300)
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height(300)
        .linearGradient({
          angle: 180,
          colors: Theme.heroScrim()
        })
      Column({ space: 10 }) {
        Row({ space: Theme.space.s2 }) {
          Text('TRAINING DESK')
            .fontSize(Theme.type.overline)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textOnScrimMuted)
          Blank().layoutWeight(1)
          Text(`${this.summary.streakDays} 天连续`)
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor('rgba(255,255,255,0.14)')
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        Text(`你好，${this.nickname}`)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnScrimMuted)
        Text(this.appName)
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnScrim)
        Text(`本月 ${this.summary.monthSessions} 次 · ${this.summary.monthDurationMin} 分钟 · ${this.summary.monthDistanceKm.toFixed(1)} km`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnScrimMuted)
        Row({ space: Theme.space.s2 }) {
          Text('月度报告')
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick(() => {
              SportDetailNav.openMonthlyReport()
            })
          Text('开始训练')
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textOnScrim)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('rgba(7,11,20,0.58)')
            .borderRadius(Theme.radius.pill)
            .border({ width: 1, color: 'rgba(255,255,255,0.32)' })
            .onClick(() => {
              this.onSwitchTab(1)
            })
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
  }

  @Builder
  TodayWorkbench() {
    GlassPanel() {
      Column({ space: Theme.space.s4 }) {
        SectionHeader({
          title: '今日工作台',
          subtitle: this.workbench.todayHasRecord ?
            `已完成 ${this.workbench.todaySessions} 次训练` :
            '今天还没有记录，点「开始训练」录入'
        })
        Row({ space: Theme.space.s3 }) {
          Column() {
            StatTile({ label: '累计', value: `${this.workbench.totalRecords}`, accent: true })
          }
          .layoutWeight(1)
          Column() {
            StatTile({ label: '连续', value: `${this.workbench.streakDays} 天` })
          }
          .layoutWeight(1)
        }
        .width('100%')
        Row({ space: Theme.space.s3 }) {
          Column() {
            StatTile({ label: '本月次数', value: `${this.summary.monthSessions}` })
          }
          .layoutWeight(1)
          Column() {
            StatTile({ label: '收藏', value: `${this.workbench.favoriteCount}` })
          }
          .layoutWeight(1)
        }
        .width('100%')
        if (this.workbench.activePlanTasksTotal > 0) {
          Column({ space: Theme.space.s2 }) {
            Row() {
              Text('周计划进度')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .layoutWeight(1)
              Text(`${this.workbench.planProgressPct}%`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
            }
            .width('100%')
            Stack({ alignContent: Alignment.Start }) {
              Column()
                .width('100%')
                .height(8)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
              Column()
                .width(`${Math.max(4, this.workbench.planProgressPct)}%`)
                .height(8)
                .linearGradient({ angle: 90, colors: Theme.brandGradient() })
                .borderRadius(Theme.radius.pill)
            }
            .width('100%')
          }
        }
      }
    }
  }

  @Builder
  StatsRow() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppStatCard({ label: '本月次数', value: `${this.summary.monthSessions}`, accent: true })
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .backdropBlur(12)

      Column() {
        AppStatCard({ label: '本月时长', value: `${this.summary.monthDurationMin} 分` })
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .backdropBlur(12)

      Column() {
        AppStatCard({ label: '本月里程', value: `${this.summary.monthDistanceKm.toFixed(1)} km` })
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .backdropBlur(12)
    }
    .width('100%')
  }

  @Builder
  QuickActions() {
    Column({ space: Theme.space.s3 }) {
      SectionHeader({ title: '快捷入口', subtitle: '问卷 · 日历 · 成长 · 计划' })
      FeatureActionCard({
        title: '训练配比问卷',
        subtitle: '6 题生成下一笔训练建议',
        iconName: 'ai',
        image: $r('app.media.ambient_data_bg'),
        onTap: (): void => {
          SportDetailNav.openDiagnose()
        }
      })
      Row({ space: Theme.space.s3 }) {
        Column() {
          FeatureActionCard({
            title: '训练日历',
            subtitle: '点日期看复盘',
            iconName: 'calendar',
            image: $r('app.media.hero_sport_bg'),
            compact: true,
            onTap: (): void => {
              SportDetailNav.openCalendar()
            }
          })
        }
        .layoutWeight(1)
        Column() {
          FeatureActionCard({
            title: '成长中心',
            subtitle: '回顾与图表',
            iconName: 'chart',
            image: $r('app.media.ambient_data_bg'),
            compact: true,
            onTap: (): void => {
              this.onSwitchTab(3)
            }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      FeatureActionCard({
        title: '计划中心',
        subtitle: '周计划与赛季挑战',
        iconName: 'biz',
        image: $r('app.media.hero_sport_bg'),
        compact: true,
        onTap: (): void => {
          this.onSwitchTab(2)
        }
      })
    }
    .width('100%')
  }

  @Builder
  ActiveChallengeSection() {
    if (this.activeChallenges.length === 0) {
      Column() {
      }
    } else {
      Column({ space: Theme.space.s3 }) {
        SectionHeader({
          title: '进行中挑战',
          subtitle: '训练记录自动计入进度',
          actionLabel: '全部',
          onAction: (): void => {
            this.onSwitchTab(2)
          }
        })
        ForEach(this.activeChallenges, (c: SportChallenge) => {
          ChallengeListCard({
            item: c,
            onTap: (): void => {
              SportDetailNav.openChallenge(c.id)
            }
          })
        }, (c: SportChallenge) => c.id)
      }
      .width('100%')
    }
  }

  @Builder
  MixRow() {
    Column({ space: Theme.space.s3 }) {
      Text(this.activeChallenge.length > 0 ? `进行中挑战：${this.activeChallenge}` : '项目配比（按记录次数）')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.mixItems.length === 0) {
        Text('完成记录后，这里会显示跑步/力量等占比，避免只刷一种项目。')
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
  ProgressRingCard() {
    GlassPanel() {
      Row({ space: Theme.space.s5 }) {
        Stack() {
          Progress({ value: this.progressPct, total: 100, type: ProgressType.Ring })
            .width(96)
            .height(96)
            .color(Theme.colors().brandPrimary)
            .style({ strokeWidth: 10 })
          Text(`${this.progressPct}%`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
        }
        Column({ space: 8 }) {
          Text('月度目标完成度')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text(`目标 ${ProfileStore.get().monthlyGoalSessions} 次 · 已完成 ${this.summary.monthSessions} 次`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
          Text(`最高单次里程 ${this.summary.bestDistanceKm.toFixed(1)} km`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
  }

  @Builder
  RecentSection() {
    Column({ space: Theme.space.s3 }) {
      SectionHeader({
        title: '最近训练',
        subtitle: '点击进入详情与复盘',
        actionLabel: '去训练',
        onAction: (): void => {
          this.onSwitchTab(1)
        }
      })
      if (this.recentItems.length === 0) {
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.ambient_data_bg'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
            .opacity(Theme.isDark() ? 0.42 : 0.85)
          Column()
            .width('100%')
            .height(120)
            .borderRadius(Theme.radius.lg)
            .linearGradient({
              angle: 180,
              colors: Theme.heroScrim()
            })
          Text('暂无记录，去「记录」页开始第一次运动吧')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textOnScrim)
            .padding(Theme.space.s4)
        }
        .width('100%')
        .height(120)
      } else {
        ForEach(this.recentItems, (item: SportRecord) => {
          SportListCard({
            record: item,
            onTap: (): void => {
              SportDetailNav.open(item.id)
            }
          })
        }, (item: SportRecord) => `${this.recentRev}_${SportModelClone.recordKey(item)}`)
      }
    }
    .width('100%')
  }

  @Builder
  DiagnoseHintCard() {
    if (this.lastDiagnoseCategory.length === 0) {
      Column() {
      }
    } else {
      GlassPanel() {
        Column({ space: Theme.space.s3 }) {
          SectionHeader({
            title: '问卷建议',
            subtitle: `${this.lastDiagnoseScore} · 可一键套用开练`,
            actionLabel: '再看报告',
            onAction: (): void => {
              SportDetailNav.openDiagnose()
            }
          })
          Text(`建议下一笔：${this.lastDiagnoseCategory}`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          AppButton({
            label: '按建议开练',
            onTap: (): void => {
              SportDetailNav.queueRecordFromDiagnose(this.lastDiagnoseCategory)
              this.onSwitchTab(1)
            }
          })
        }
      }
    }
  }

  @Builder
  WeekCompareCard() {
    GlassPanel() {
      Column({ space: Theme.space.s4 }) {
        SectionHeader({ title: '周对比', subtitle: '近 7 天 vs 上一周' })
        Row({ space: Theme.space.s3 }) {
          Column() {
            StatTile({
              label: '本周次数',
              value: `${this.weekCompare.thisWeekSessions}`,
              accent: true
            })
          }
          .layoutWeight(1)
          Column() {
            StatTile({ label: '上周次数', value: `${this.weekCompare.lastWeekSessions}` })
          }
          .layoutWeight(1)
        }
        .width('100%')
        Text(this.weekCompare.deltaSessions > 0 ?
          `比上周多 ${this.weekCompare.deltaSessions} 次，节奏向上 ↑` :
          (this.weekCompare.deltaSessions < 0 ?
            `比上周少 ${Math.abs(this.weekCompare.deltaSessions)} 次，可设小挑战拉回 →` :
            '与上周持平，保持稳定也是进步'))
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        AppBarChart({ items: this.chartItems() })
      }
    }
  }

  @Builder
  PersonalBestSection() {
    if (this.personalBests.length === 0) {
      Column() {
      }
    } else {
      Column({ space: Theme.space.s3 }) {
        SectionHeader({
          title: '个人最佳',
          subtitle: '距离 · 时长 · 配速',
          actionLabel: '成长中心',
          onAction: (): void => {
            this.onSwitchTab(3)
          }
        })
        ForEach(this.personalBests, (pb: PersonalBestItem) => {
          Row({ space: Theme.space.s3 }) {
            Text(pb.sportType)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width(72)
            Text(pb.metricLabel)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width(64)
            Text(pb.metricValue)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
              .layoutWeight(1)
            Text(pb.recordDate)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }, (pb: PersonalBestItem) => `${pb.sportType}_${pb.metricLabel}_${pb.recordDate}`)
      }
      .width('100%')
    }
  }

  @Builder
  InsightCard() {
    Row({ space: Theme.space.s3 }) {
      AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      Text(this.insightTip)
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
  StreakBanner() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.ambient_data_bg'))
        .width('100%')
        .height(120)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
        .opacity(0.55)
      Column()
        .width('100%')
        .height(120)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(7,11,20,0.15)', 0.0],
            ['rgba(7,11,20,0.88)', 1.0]
          ]
        })
      Row({ space: Theme.space.s3 }) {
        AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: '#FFFFFF' })
        Column({ space: 4 }) {
          Text('成长轨迹总览')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text(`累计 ${this.summary.totalSessions} 次 · ${this.summary.totalDurationMin} 分钟 · ${this.summary.totalDistanceKm.toFixed(1)} km`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textOnScrimMuted)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(Theme.space.s5)
    }
    .width('100%')
    .height(120)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeStrong })
  }
}
