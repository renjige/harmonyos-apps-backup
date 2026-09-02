import { Theme } from '../components/design-system/Theme'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { MatchListCard } from '../components/sports/MatchListCard'
import { LeagueListCard } from '../components/sports/LeagueListCard'
import { TeamListCard } from '../components/sports/TeamListCard'
import { LeagueItem, MatchItem, TeamItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { DetailNav } from '../services/DetailNav'
import { AuthService } from '../services/AuthService'
import { ActivityFeedItem, UserStatsPayload, ViewingPlanItem } from '../models/ViewingModels'
import { ViewingGuideSection } from '../components/sports/ViewingGuideSection'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '赛事纵览'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('themeColorMode') themeColorMode: string = 'light'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  onOpenMessages: () => void = () => {}
  onOpenCalendar: () => void = () => {}
  onOpenStandings: () => void = () => {}
  onOpenFollow: () => void = () => {}
  onOpenSearch: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onOpenPlanEditor: () => void = () => {}
  @State todayCount: number = 0
  @State liveCount: number = 0
  @State userStats: UserStatsPayload = new UserStatsPayload()
  @State activePlan: ViewingPlanItem | undefined = undefined
  @State todayWatch: MatchItem[] = []
  @State recentActivity: ActivityFeedItem[] = []
  @State hotMatches: MatchItem[] = []
  @State liveMatches: MatchItem[] = []
  @State recentResults: MatchItem[] = []
  @State leagues: LeagueItem[] = []
  @State featuredTeams: TeamItem[] = []
  @State weekendPlan: MatchItem[] = []
  @State loading: boolean = true
  @State loadError: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.loadError = ''
    this.todayCount = await SportsBizService.countTodayMatches()
    const all = await SportsBizService.loadMatches('', false, '')
    this.liveMatches = []
    this.recentResults = []
    this.liveCount = 0
    for (const m of all) {
      if (m.status === 'live') {
        this.liveMatches.push(m)
        this.liveCount += 1
      }
      if (m.status === 'finished') {
        this.recentResults.push(m)
      }
    }
    this.recentResults = this.recentResults.slice(0, 4)
    this.hotMatches = await SportsBizService.loadMatches('', true, '')
    if (this.hotMatches.length === 0) {
      this.hotMatches = all.filter((m: MatchItem) => m.status === 'upcoming').slice(0, 6)
    }
    this.leagues = await SportsBizService.loadLeagues('')
    this.featuredTeams = await SportsBizService.loadTeams('')
    this.featuredTeams = this.featuredTeams.filter((t: TeamItem) => t.featured).slice(0, 4)
    this.weekendPlan = SportsBizService.weekendMatches(all)
    if (AuthService.isLoggedIn()) {
      const stats = await SportsBizService.loadUserStats('')
      if (stats !== undefined) {
        this.userStats = stats
      }
      const plans = await SportsBizService.loadViewingPlans('')
      this.activePlan = undefined
      for (const p of plans) {
        if (p.status === 'active') {
          this.activePlan = p
          break
        }
      }
      this.todayWatch = await SportsBizService.loadTodayWatchList()
      this.recentActivity = await SportsBizService.loadActivityFeed('', 3)
    } else {
      this.userStats = new UserStatsPayload()
      this.activePlan = undefined
      this.todayWatch = []
      this.recentActivity = []
    }
    if (this.hotMatches.length === 0 && SportsBizService.lastError.length > 0) {
      this.loadError = SportsBizService.lastError
    }
    this.loading = false
  }

  @Builder
  ToolChip(label: string, hint: string, onTap: () => void) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.palette(this.themeColorMode === 'dark').textPrimary)
        .width('100%')
        .textAlign(TextAlign.Center)
      Text(hint)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.palette(this.themeColorMode === 'dark').textSecondary)
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
    .padding({ left: Theme.space.s3, right: Theme.space.s3, top: Theme.space.s4, bottom: Theme.space.s4 })
    .backgroundColor(Theme.palette(this.themeColorMode === 'dark').surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.palette(this.themeColorMode === 'dark').strokeHairline })
    .alignItems(HorizontalAlign.Center)
    .onClick(onTap)
  }

  @Builder
  StatChip(value: string, label: string, onTap: () => void) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.palette(this.themeColorMode === 'dark').textPrimary)
        .width('100%')
        .textAlign(TextAlign.Center)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.palette(this.themeColorMode === 'dark').textSecondary)
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
    .padding({ left: Theme.space.s3, right: Theme.space.s3, top: Theme.space.s4, bottom: Theme.space.s4 })
    .backgroundColor(Theme.palette(this.themeColorMode === 'dark').surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.palette(this.themeColorMode === 'dark').strokeHairline })
    .alignItems(HorizontalAlign.Center)
    .onClick(onTap)
  }

  @Builder
  SectionTitle(title: string, subtitle: string) {
    Column({ space: 2 }) {
      Text(title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(subtitle)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
  }

  build() {
    Column() {
      if (this.loading) {
        AppLoading({ label: '加载赛事…' }).layoutWeight(1)
      } else if (this.loadError.length > 0 && this.hotMatches.length === 0 && this.liveMatches.length === 0) {
        AppError({
          message: this.loadError,
          retryLabel: '重试',
          onRetry: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_stadium'))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Column()
                .width('100%')
                .height(180)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.78)', 1]]
                })
                .borderRadius(Theme.radius.xl)
              Column({ space: 6 }) {
                Text(this.appName)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textOnInverse)
                Text(this.tagline)
                  .fontSize(Theme.type.callout)
                  .fontColor(Theme.colors().textOnInverse)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              this.SectionTitle('观赛工作台', AuthService.isLoggedIn() ?
                `${this.currentUsername} 的专属观赛助手` : '登录后解锁计划、打卡与成长数据')
              if (AuthService.isLoggedIn() && this.activePlan !== undefined) {
                Column({ space: 8 }) {
                  Text(this.activePlan.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.palette(this.themeColorMode === 'dark').textPrimary)
                    .width('100%')
                  Text(`计划进度 ${this.activePlan.progressLabel()}（${this.activePlan.progressPercent()}%）`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.palette(this.themeColorMode === 'dark').textSecondary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.palette(this.themeColorMode === 'dark').surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.palette(this.themeColorMode === 'dark').strokeHairline })
                .onClick((): void => { this.onOpenFollow() })
              } else if (AuthService.isLoggedIn()) {
                Column({ space: 8 }) {
                  Text('还没有观赛计划')
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.palette(this.themeColorMode === 'dark').textPrimary)
                  Text('创建计划，把想看的比赛收进个人赛程')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.palette(this.themeColorMode === 'dark').textSecondary)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .alignItems(HorizontalAlign.Start)
                .backgroundColor(Theme.palette(this.themeColorMode === 'dark').surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.palette(this.themeColorMode === 'dark').strokeHairline })
                .onClick((): void => { this.onOpenPlanEditor() })
              }

              Column({ space: Theme.space.s2 }) {
                Row({ space: Theme.space.s2 }) {
                  this.StatChip(`${this.userStats.watchedCount}`, '已观看', (): void => { this.onOpenGrowth() })
                  this.StatChip(`${this.userStats.noteCount}`, '笔记', (): void => { this.onOpenFollow() })
                }
                .width('100%')
                Row({ space: Theme.space.s2 }) {
                  this.StatChip(`${this.userStats.watchStreakDays}`, '连续天', (): void => { this.onOpenGrowth() })
                  this.StatChip(`${this.userStats.favoriteCount}`, '关注', (): void => { this.onOpenFollow() })
                }
                .width('100%')
              }
              .width('100%')

              Row({ space: Theme.space.s2 }) {
                this.ToolChip('搜索', '比赛/球队', (): void => { this.onOpenSearch() })
                this.ToolChip('新建计划', '个人赛程', (): void => { this.onOpenPlanEditor() })
                this.ToolChip('数据中心', '成就回顾', (): void => { this.onOpenGrowth() })
              }
              .width('100%')

              if (this.todayWatch.length > 0) {
                Column({ space: Theme.space.s3 }) {
                  Text('今日待看')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.palette(this.themeColorMode === 'dark').textPrimary)
                    .width('100%')
                  ForEach(this.todayWatch.slice(0, 4), (row: MatchItem) => {
                    MatchListCard({
                      item: row,
                      compact: true,
                      onTap: (): void => { DetailNav.openMatch(row.id) }
                    })
                  }, (row: MatchItem) => `tw_${row.id}`)
                }
                .width('100%')
              }

              if (this.recentActivity.length > 0) {
                Column({ space: Theme.space.s2 }) {
                  Text('最近动态')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.palette(this.themeColorMode === 'dark').textPrimary)
                    .width('100%')
                  ForEach(this.recentActivity, (row: ActivityFeedItem) => {
                    Text(`${row.typeLabel()} · ${row.title}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.palette(this.themeColorMode === 'dark').textSecondary)
                      .width('100%')
                  }, (row: ActivityFeedItem) => row.id)
                }
                .width('100%')
              }
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              Column({ space: 4 }) {
                Text(`${this.todayCount}`)
                  .fontSize(Theme.type.display)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                Text('今日比赛')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s5)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .alignItems(HorizontalAlign.Start)

              Column({ space: 4 }) {
                Text(`${this.liveCount}`)
                  .fontSize(Theme.type.display)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().danger)
                Text('进行中')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s5)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .alignItems(HorizontalAlign.Start)

              Column() {
                AppCard({
                  title: '消息',
                  variant: 'outlined',
                  onTap: (): void => { this.onOpenMessages() }
                }) {
                  Row({ space: 8 }) {
                    Text('通知与提醒')
                      .fontSize(Theme.type.callout)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .layoutWeight(1)
                    AppIcon({ name: 'message', iconSize: Theme.icon.sm })
                  }
                  .width('100%')
                }
              }
              .layoutWeight(1)
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              this.SectionTitle('观赛工具', '积分榜 · 日历 · 计划 · 提醒')
              Row({ space: Theme.space.s2 }) {
                this.ToolChip('积分榜', '联赛排名', (): void => { this.onOpenStandings() })
                this.ToolChip('赛事日历', '按月查赛程', (): void => { this.onOpenCalendar() })
              }
              .width('100%')
              Row({ space: Theme.space.s2 }) {
                this.ToolChip('我的观赛', '关注与提醒', (): void => { this.onOpenFollow() })
                this.ToolChip('消息中心', '通知速递', (): void => { this.onOpenMessages() })
              }
              .width('100%')
            }
            .width('100%')

            if (this.weekendPlan.length > 0) {
              Column({ space: Theme.space.s3 }) {
                Stack({ alignContent: Alignment.BottomStart }) {
                  Image($r('app.media.match_football_1'))
                    .width('100%')
                    .height(100)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Theme.radius.xl)
                  Column()
                    .width('100%')
                    .height(100)
                    .linearGradient({
                      angle: 180,
                      colors: [['rgba(15,23,42,0.1)', 0], ['rgba(15,23,42,0.75)', 1]]
                    })
                    .borderRadius(Theme.radius.xl)
                  Text('周末观赛计划')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textOnInverse)
                    .padding(Theme.space.s4)
                }
                .width('100%')
                ForEach(this.weekendPlan.slice(0, 5), (row: MatchItem) => {
                  MatchListCard({
                    item: row,
                    onTap: (): void => { DetailNav.openMatch(row.id) }
                  })
                }, (row: MatchItem) => `wk_${row.id}`)
              }
              .width('100%')
            }

            if (this.liveMatches.length > 0) {
              Column({ space: Theme.space.s3 }) {
                this.SectionTitle('进行中', '实时比分与赛况')
                ForEach(this.liveMatches, (row: MatchItem) => {
                  MatchListCard({
                    item: row,
                    onTap: (): void => { DetailNav.openMatch(row.id) }
                  })
                }, (row: MatchItem) => row.id)
              }
              .width('100%')
            }

            Column({ space: Theme.space.s3 }) {
              this.SectionTitle('热门赛事', '精选焦点比赛')
              if (this.hotMatches.length === 0) {
                AppEmpty({
                  title: '暂无热门比赛',
                  description: '可在赛事页浏览全部赛程'
                })
              } else {
                ForEach(this.hotMatches.slice(0, 6), (row: MatchItem) => {
                  MatchListCard({
                    item: row,
                    onTap: (): void => { DetailNav.openMatch(row.id) }
                  })
                }, (row: MatchItem) => row.id)
              }
            }
            .width('100%')

            if (this.recentResults.length > 0) {
              Column({ space: Theme.space.s3 }) {
                this.SectionTitle('最新赛果', '近期已结束比赛')
                ForEach(this.recentResults, (row: MatchItem) => {
                  MatchListCard({
                    item: row,
                    compact: true,
                    onTap: (): void => { DetailNav.openMatch(row.id) }
                  })
                }, (row: MatchItem) => row.id)
              }
              .width('100%')
            }

            if (this.leagues.length > 0) {
              Column({ space: Theme.space.s3 }) {
                this.SectionTitle('联赛纵览', '按赛事系列浏览')
                ForEach(this.leagues, (row: LeagueItem) => {
                  LeagueListCard({
                    item: row,
                    onTap: (): void => { DetailNav.openLeague(row.id) }
                  })
                }, (row: LeagueItem) => row.id)
              }
              .width('100%')
            }

            if (this.featuredTeams.length > 0) {
              Column({ space: Theme.space.s3 }) {
                this.SectionTitle('球队聚焦', '热门参赛队伍')
                ForEach(this.featuredTeams, (row: TeamItem) => {
                  TeamListCard({
                    item: row,
                    onTap: (): void => { DetailNav.openTeam(row.id) }
                  })
                }, (row: TeamItem) => row.id)
              }
              .width('100%')
            }

            ViewingGuideSection()
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
    .backgroundColor(Theme.palette(this.themeColorMode === 'dark').surfacePage)
  }
}
