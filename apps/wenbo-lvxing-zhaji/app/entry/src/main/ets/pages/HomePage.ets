import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { JournalListCard } from '../components/journal/JournalListCard'
import { AnnualStatsData, JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { JournalMedia } from '../services/JournalMedia'
import { PlanCodec } from '../services/PlanCodec'
import { AchievementBadge, AchievementService } from '../services/AchievementService'
import { AuthService } from '../services/AuthService'

/** 首页工作台：进度 · 统计 · 快捷操作 · 最近动态 */
@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '旅行札记'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onCreateJourney: () => void = () => {}
  onCreatePlan: () => void = () => {}
  onOpenExplore: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onOpenPlan: () => void = () => {}
  @State stats: AnnualStatsData = new AnnualStatsData()
  @State recentJourneys: JournalItem[] = []
  @State activePlans: JournalItem[] = []
  @State timeline: JournalItem[] = []
  @State checkinStreak: number = 0
  @State planProgress: number = 0
  @State badgeUnlocked: number = 0
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private greeting(): string {
    const hour = new Date().getHours()
    if (hour < 11) {
      return '早安，今天想去哪里'
    }
    if (hour < 17) {
      return '午安，记录旅途风景'
    }
    return '晚安，把今天写进札记'
  }

  private async reload(): Promise<void> {
    this.loading = true
    const year = new Date().getFullYear()
    if (!AuthService.isLoggedIn()) {
      this.stats = new AnnualStatsData()
      this.stats.year = year
      this.recentJourneys = []
      this.activePlans = []
      this.timeline = []
      this.checkinStreak = 0
      this.planProgress = 0
      this.badgeUnlocked = 0
      this.loading = false
      return
    }
    this.stats = await JournalBizService.loadAnnualStats(this.currentUsername, year)
    const all = await JournalBizService.loadAllDiaries(this.currentUsername)
    this.recentJourneys = JournalBizService.filterJourneys(all).slice(0, 6)
    this.activePlans = JournalBizService.filterPlans(all).slice(0, 3)
    this.timeline = await JournalBizService.loadTimeline(this.currentUsername, 4)
    const checkins = JournalBizService.filterCheckins(all)
    this.checkinStreak = JournalBizService.computeCheckinStreak(checkins)
    let totalPct = 0
    let planCount = 0
    for (const p of this.activePlans) {
      totalPct += PlanCodec.progressPercent(PlanCodec.decodeTasks(p.body))
      planCount += 1
    }
    this.planProgress = planCount > 0 ? Math.round(totalPct / planCount) : 0
    const fp = await JournalBizService.loadFootprints(this.currentUsername)
    const badges: AchievementBadge[] = AchievementService.buildBadges(
      this.stats, this.checkinStreak, fp.routeCount
    )
    this.badgeUnlocked = AchievementService.unlockedCount(badges)
    this.loading = false
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row({ space: 12 }) {
          Image($r('app.media.app_icon'))
            .width(48)
            .height(48)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
          Column({ space: 4 }) {
            Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.greeting())
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_travel_home'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(168)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,58,82,0.08)', 0], ['rgba(26,58,82,0.78)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Column({ space: Theme.space.s2 }) {
            Text(AuthService.isLoggedIn() ? '本月计划进度' : '旅行记忆工作台')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(AuthService.isLoggedIn() ?
              `${this.planProgress}% · 连续打卡 ${this.checkinStreak} 天` :
              '登录后同步你的旅程与计划')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textOnInverse)
            Progress({
              value: AuthService.isLoggedIn() ? this.planProgress : 0,
              total: 100,
              type: ProgressType.Linear
            })
              .width('100%')
              .color(Theme.colors().brandAccent)
            AppButton({
              label: AuthService.isLoggedIn() ? '继续完成计划' : '登录开始记录',
              onTap: (): void => {
                if (AuthService.isLoggedIn()) {
                  this.onOpenPlan()
                } else {
                  this.onCreateJourney()
                }
              }
            })
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .width('100%')

        if (this.loading) {
          AppLoading({ variant: 'skeleton' })
        } else if (AuthService.isLoggedIn()) {
          Row({ space: Theme.space.s2 }) {
            AppStatCard({ label: '旅程', value: `${this.stats.diaryCount}`, hint: '篇' })
              .layoutWeight(1)
            AppStatCard({ label: '图片', value: `${this.stats.imageCount}`, hint: '张' })
              .layoutWeight(1)
          }
          .width('100%')
          Row({ space: Theme.space.s2 }) {
            AppStatCard({ label: '相册', value: `${this.stats.albumCount}`, hint: '册' })
              .layoutWeight(1)
            AppStatCard({ label: '成就', value: `${this.badgeUnlocked}`, hint: '枚' })
              .layoutWeight(1)
          }
          .width('100%')

          Row({ space: Theme.space.s2 }) {
            this.QuickAction('新建旅程', (): void => { this.onCreateJourney() })
            this.QuickAction('出行计划', (): void => { this.onCreatePlan() })
            this.QuickAction('探索', (): void => { this.onOpenExplore() })
            this.QuickAction('成长', (): void => { this.onOpenGrowth() })
          }
          .width('100%')

          if (this.activePlans.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Text('进行中的计划')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.activePlans.slice(0, 2), (plan: JournalItem) => {
                Row({ space: Theme.space.s3 }) {
                  Image(JournalMedia.resolveImage(
                    plan.coverKey.length > 0 ? plan.coverKey : 'hero_coastal_sunset'
                  ))
                    .width(72)
                    .height(72)
                    .borderRadius(Theme.radius.lg)
                    .objectFit(ImageFit.Cover)
                  Column({ space: 4 }) {
                    Text(plan.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.colors().textPrimary)
                      .width('100%')
                    Text(`${PlanCodec.progressPercent(PlanCodec.decodeTasks(plan.body))}% 完成`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .onClick((): void => { this.onOpenPlan() })
              }, (plan: JournalItem) => plan.id)
            }
            .width('100%')
          }

          if (this.timeline.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Row() {
                Text('最近动态')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text('查看全部')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => { this.onOpenGrowth() })
              }
              .width('100%')
              ForEach(this.timeline.slice(0, 3), (item: JournalItem) => {
                JournalListCard({
                  item: item,
                  compact: true,
                  onTap: (): void => {
                    if (item.kind === 'album') {
                      JournalDetailNav.openAlbum(item.id)
                    } else {
                      JournalDetailNav.openDiary(item.id)
                    }
                  }
                })
              }, (item: JournalItem) => item.id)
            }
            .width('100%')
          }

          Column({ space: Theme.space.s3 }) {
            Text('最近旅行')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            if (this.recentJourneys.length === 0) {
              AppEmpty({
                title: '还没有旅程',
                description: '从第一条旅行札记开始，建立你的记忆空间',
                actionLabel: '创建旅程',
                onAction: (): void => { this.onCreateJourney() }
              })
            } else {
              ForEach(this.recentJourneys.slice(0, 4), (item: JournalItem) => {
                JournalListCard({
                  item: item,
                  compact: false,
                  onTap: (): void => { JournalDetailNav.openDiary(item.id) }
                })
              }, (item: JournalItem) => item.id)
            }
          }
          .width('100%')
        } else {
          Column({ space: Theme.space.s5 }) {
            Text('旅行全流程工作台')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text('计划 · 日记 · 本机相册策展 · 成长回顾')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')

            Row({ space: Theme.space.s2 }) {
              this.GuestFeatureCard('探索', '搜索灵感')
              this.GuestFeatureCard('计划', '清单打卡')
            }
            .width('100%')
            Row({ space: Theme.space.s2 }) {
              this.GuestFeatureCard('相册', '本机选图')
              this.GuestFeatureCard('成长', '统计成就')
            }
            .width('100%')

            AppButton({
              label: '登录开始记录',
              onTap: (): void => { this.onCreateJourney() }
            })
            AppButton({
              label: '先去探索旅行灵感',
              variant: 'secondary',
              onTap: (): void => { this.onOpenExplore() }
            })
          }
          .width('100%')
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  GuestFeatureCard(title: string, hint: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(hint)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  QuickAction(label: string, action: () => void) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandPrimary)
        .textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.lg)
    .onClick(action)
  }
}
