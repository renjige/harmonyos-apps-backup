import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { AnnualStatsData, JournalItem, MonthlyStatMonth } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { AchievementBadge, AchievementService } from '../services/AchievementService'
import { AuthService } from '../services/AuthService'
import { MapPage } from './MapPage'
import { MinePage } from './MinePage'

/** 成长 Tab：统计 · 成就 · 时间轴 · 足迹 · 我的 */
@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop appName: string = '旅行札记'
  onRequireAuth: () => void = () => {}
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onSwitchTab: (index: number) => void = () => {}
  onOpenFavorites: () => void = () => {}
  @State stats: AnnualStatsData = new AnnualStatsData()
  @State months: MonthlyStatMonth[] = []
  @State timeline: JournalItem[] = []
  @State badges: AchievementBadge[] = []
  @State loading: boolean = true
  @State segment: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.stats = new AnnualStatsData()
      this.stats.year = new Date().getFullYear()
      this.months = []
      this.timeline = []
      this.badges = AchievementService.buildBadges(this.stats, 0, 0)
      this.loading = false
      return
    }
    const year = new Date().getFullYear()
    this.stats = await JournalBizService.loadAnnualStats(this.currentUsername, year)
    const monthly = await JournalBizService.loadMonthlyStats(this.currentUsername, year)
    this.months = monthly.months
    this.timeline = await JournalBizService.loadTimeline(this.currentUsername, 8)
    const fp = await JournalBizService.loadFootprints(this.currentUsername)
    const all = await JournalBizService.loadAllDiaries(this.currentUsername)
    const streak = JournalBizService.computeCheckinStreak(JournalBizService.filterCheckins(all))
    this.badges = AchievementService.buildBadges(this.stats, streak, fp.routeCount)
    this.loading = false
  }

  private monthBarHeight(m: MonthlyStatMonth): number {
    const max = 8
    const h = m.diaryCount + m.imageCount
    if (h <= 0) {
      return 4
    }
    return Math.min(72, 12 + h * 8)
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        this.GrowthChip('数据', 0)
        this.GrowthChip('足迹', 1)
        this.GrowthChip('我的', 2)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s2,
        bottom: Theme.space.s2
      })

      if (this.segment === 1) {
        MapPage({
          onRequireAuth: (): void => { this.onRequireAuth() }
        }).layoutWeight(1)
      } else if (this.segment === 2) {
        MinePage({
          appName: this.appName,
          onOpenLogin: (): void => { this.onOpenLogin() },
          onLogout: (): void => { this.onLogout() },
          onRequireAuth: (): void => { this.onRequireAuth() },
          onSwitchTab: (index: number): void => { this.onSwitchTab(index) },
          onOpenFavorites: (): void => { this.onOpenFavorites() },
          onOpenOrganize: (): void => { this.onSwitchTab(1) },
          onOpenReview: (): void => { this.segment = 0 }
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            AppHeader({ title: '成长回顾', subtitle: '数据统计 · 成就徽章 · 旅行时间轴' })

            if (!AuthService.isLoggedIn()) {
              AppEmpty({
                title: '登录后查看成长数据',
                description: '统计仅来自你的旅程、相册与打卡记录',
                actionLabel: '去登录',
                onAction: (): void => { this.onRequireAuth() }
              })
            } else if (this.loading) {
              AppLoading({ label: '加载数据…' })
            } else {
              Text(`${this.stats.year} 年度数据`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')

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
                AppStatCard({ label: '写作', value: `${this.stats.writingDays}`, hint: '天' })
                  .layoutWeight(1)
              }
              .width('100%')

              Column({ space: Theme.space.s3 }) {
                Text('月度记录趋势')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Row({ space: 4 }) {
                  ForEach(this.months, (m: MonthlyStatMonth) => {
                    Column({ space: 4 }) {
                      Column()
                        .width(16)
                        .height(this.monthBarHeight(m))
                        .backgroundColor(m.diaryCount > 0 ?
                          Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                        .borderRadius(4)
                      Text(`${m.month}`)
                        .fontSize(Theme.type.overline)
                        .fontColor(Theme.colors().textTertiary)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)
                  }, (m: MonthlyStatMonth) => `${m.month}`)
                }
                .width('100%')
                .height(100)
                .alignItems(VerticalAlign.Bottom)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)

              Column({ space: Theme.space.s3 }) {
                Row() {
                  Text('成就墙')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Text(`${AchievementService.unlockedCount(this.badges)}/${this.badges.length}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                }
                .width('100%')
                ForEach(this.badges, (b: AchievementBadge) => {
                  Row({ space: Theme.space.s3 }) {
                    Column() {
                      AppIcon({
                        name: b.unlocked ? 'check' : 'empty',
                        iconSize: Theme.icon.md,
                        color: b.unlocked ? Theme.colors().brandPrimary : Theme.colors().textTertiary
                      })
                    }
                    .width(36)
                    .height(36)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(b.unlocked ?
                      Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    Column({ space: 2 }) {
                      Text(b.title)
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(b.unlocked ?
                          Theme.colors().textPrimary : Theme.colors().textSecondary)
                        .width('100%')
                      Text(b.description)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textTertiary)
                        .width('100%')
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .opacity(b.unlocked ? 1 : 0.72)
                }, (b: AchievementBadge) => b.id)
              }
              .width('100%')

              Column({ space: Theme.space.s3 }) {
                Text('最近动态')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                if (this.timeline.length === 0) {
                  AppEmpty({
                    title: '暂无动态',
                    description: '创建旅程或相册后，时间轴会自动更新',
                    actionLabel: '',
                    onAction: (): void => {}
                  })
                } else {
                  ForEach(this.timeline, (item: JournalItem) => {
                    JournalListCard({
                      item: item,
                      compact: true,
                      onTap: (): void => {
                        if (item.kind === 'album') {
                          JournalDetailNav.openAlbum(item.id)
                        } else if (item.userId.length > 0) {
                          JournalDetailNav.openDiary(item.id)
                        }
                      }
                    })
                  }, (item: JournalItem) => item.id)
                }
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
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  GrowthChip(label: string, index: number) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontWeight(this.segment === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.segment === index ?
        Theme.colors().brandPrimary : Theme.colors().textSecondary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.segment === index ?
        Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.segment = index })
  }
}
