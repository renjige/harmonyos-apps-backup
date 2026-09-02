import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { GrowthListCard } from '../components/growth/GrowthListCard'
import { HomeWorkbench } from '../components/growth/HomeWorkbench'
import { HomeToolkitRow } from '../components/growth/HomeToolkitRow'
import { CreatePlanRequest, GoalStepItem, GrowthRecordItem, StatsData, UpdatePlanRequest } from '../models/GrowthModels'
import { WeeklyChallengeItem } from '../models/WeeklyChallenge'
import { MonthThemeUtil } from '../models/StuckWorkshop'
import { GrowthBizService } from '../services/GrowthBizService'
import { GrowthDetailNav } from '../services/GrowthDetailNav'
import { GrowthMedia } from '../services/GrowthMedia'
import { AuthService } from '../services/AuthService'
import { AchievementService } from '../services/AchievementService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '成长手册'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onWriteRecord: () => void = () => {}
  onSwitchTab: (index: number) => void = () => {}
  onOpenAnnualReport: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenOrganize: () => void = () => {}
  onOpenMessages: () => void = () => {}
  onOpenHabits: () => void = () => {}
  onOpenReviews: () => void = () => {}
  onOpenDiagnose: () => void = () => {}
  onOpenRitual: () => void = () => {}
  onOpenStuck: () => void = () => {}
  onOpenContrast: () => void = () => {}
  onOpenTheme: () => void = () => {}
  onOpenTools: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State featured: GrowthRecordItem[] = []
  @State recentRecords: GrowthRecordItem[] = []
  @State latestFeatured: GrowthRecordItem | undefined = undefined
  @State activeGoals: GrowthRecordItem[] = []
  @State achievements: GrowthRecordItem[] = []
  @State stats: StatsData = new StatsData()
  @State statsLoading: boolean = true
  @State messageCount: number = 0
  @State loading: boolean = true
  @State ritualDone: boolean = false
  @State joiningChallenge: boolean = false
  @State listEpoch: number = 0
  @State bumpingGoalId: string = ''
  @State monthTheme: string = ''
  @State todayPercent: number = 0
  @State todayDone: number = 0
  @State todayTotal: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('detailRoute') @Watch('onDetailRouteChange') detailRoute: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDetailRouteChange(): void {
    if (this.detailRoute.length === 0) {
      void this.reload()
    }
  }

  private todayIso(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  private computeRitualDone(records: GrowthRecordItem[]): boolean {
    const today = this.todayIso()
    for (const r of records) {
      if (r.recordDate === today && r.title.indexOf('今日仪式') >= 0) {
        return true
      }
    }
    return false
  }

  private async joinChallenge(): Promise<void> {
    if (!AuthService.requireAuth('create_goal')) {
      this.onRequireAuth()
      return
    }
    if (this.joiningChallenge) {
      return
    }
    this.joiningChallenge = true
    const ch = WeeklyChallengeItem.current()
    const steps: GoalStepItem[] = []
    const s1 = new GoalStepItem()
    s1.title = ch.step1
    steps.push(s1)
    const s2 = new GoalStepItem()
    s2.title = ch.step2
    steps.push(s2)
    const s3 = new GoalStepItem()
    s3.title = ch.step3
    steps.push(s3)
    const req = new CreatePlanRequest()
    req.title = `本周挑战 · ${ch.title}`
    req.goal = ch.summary
    req.summary = ch.summary
    req.progress = 0
    req.cardsJson = GoalStepItem.encode(steps)
    req.userId = this.currentUsername
    const created = await GrowthBizService.createCreativePlan(req)
    this.joiningChallenge = false
    if (created !== undefined) {
      await this.reload()
      if (created.id.length > 0) {
        GrowthDetailNav.openPlan(created.id)
      }
    }
  }

  private greeting(): string {
    const hour = new Date().getHours()
    if (hour < 11) {
      return '早安，捕捉今日成长'
    }
    if (hour < 17) {
      return '午安，整理成长碎片'
    }
    return '晚安，把成长收进手册'
  }

  private todayLabel(): string {
    const d = new Date()
    const month = d.getMonth() + 1
    const day = d.getDate()
    const weekdays: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `${month}月${day}日 · 星期${weekdays[d.getDay()]}`
  }

  private computeTodayProgress(records: GrowthRecordItem[]): void {
    if (!AuthService.isLoggedIn()) {
      this.todayPercent = 0
      this.todayDone = 0
      this.todayTotal = 0
      return
    }
    const today = this.todayIso()
    let done = 0
    let total = 3
    if (this.ritualDone) {
      done += 1
    }
    let hasRecordToday = false
    for (const r of records) {
      if (r.recordDate === today && r.title.indexOf('今日仪式') < 0 &&
        r.title.indexOf('月报 ·') < 0 && r.title.indexOf('月度主题 ·') < 0) {
        hasRecordToday = true
        break
      }
    }
    if (hasRecordToday) {
      done += 1
    }
    let goalTouched = false
    for (const g of this.activeGoals) {
      if (g.progress > 0) {
        goalTouched = true
        break
      }
    }
    if (goalTouched) {
      done += 1
    }
    this.todayDone = done
    this.todayTotal = total
    this.todayPercent = Math.round((done / total) * 100)
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.statsLoading = true
    this.featured = await GrowthBizService.loadFeatured()
    if (this.featured.length > 0) {
      this.latestFeatured = this.featured[0]
    } else {
      this.latestFeatured = undefined
    }
    const messages = await GrowthBizService.loadMessages()
    this.messageCount = AuthService.isLoggedIn() ? messages.length : 0
    if (AuthService.isLoggedIn()) {
      this.recentRecords = await GrowthBizService.loadRecords(this.currentUsername)
      this.stats = await GrowthBizService.loadStats(this.currentUsername)
      const goals = await GrowthBizService.loadCreativePlans(this.currentUsername)
      const active: GrowthRecordItem[] = []
      for (const g of goals) {
        if (g.progress < 100) {
          active.push(g)
        }
      }
      this.activeGoals = active
      this.achievements = await GrowthBizService.loadAchievements(this.currentUsername)
      this.ritualDone = this.computeRitualDone(this.recentRecords)
      this.monthTheme = MonthThemeUtil.findTheme(this.recentRecords)
      this.computeTodayProgress(this.recentRecords)
      this.achievements = await AchievementService.syncFromStats(
        this.stats, this.achievements, this.currentUsername, false
      )
    } else {
      this.recentRecords = []
      this.stats = new StatsData()
      this.activeGoals = []
      this.achievements = []
      this.messageCount = 0
      this.ritualDone = false
      this.monthTheme = ''
    }
    this.statsLoading = false
    this.loading = false
    this.listEpoch += 1
  }

  private async bumpGoalOnHome(goalId: string): Promise<void> {
    if (!AuthService.requireAuth('create_goal')) {
      this.onRequireAuth()
      return
    }
    if (this.bumpingGoalId.length > 0) {
      return
    }
    let target: GrowthRecordItem | undefined = undefined
    for (const g of this.activeGoals) {
      if (g.id === goalId) {
        target = g
        break
      }
    }
    if (target === undefined) {
      return
    }
    this.bumpingGoalId = goalId
    const req = new UpdatePlanRequest()
    req.title = target.title
    req.goal = target.goal
    req.summary = target.summary.length > 0 ? target.summary : target.goal
    req.progress = Math.min(100, target.progress + 10)
    req.cardsJson = target.cardsJson
    const updated = await GrowthBizService.updateCreativePlan(goalId, req)
    this.bumpingGoalId = ''
    if (updated !== undefined) {
      const next: GrowthRecordItem[] = []
      for (const g of this.activeGoals) {
        if (g.id === goalId) {
          if (updated.progress < 100) {
            next.push(updated)
          }
        } else if (g.progress < 100) {
          next.push(g)
        }
      }
      this.activeGoals = next
      this.stats = await GrowthBizService.loadStats(this.currentUsername)
      this.listEpoch += 1
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Column({ space: 6 }) {
          Text(this.greeting())
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.todayLabel())
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text(this.tagline)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_bg'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(120)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,118,110,0.12)', 0], ['rgba(15,118,110,0.78)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Column({ space: Theme.space.s2 }) {
            Text('成长工作台')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
            Text('记录 · 目标 · 坚持 · 回顾')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .width('100%')

        Image($r('app.media.hero_morning_coffee'))
          .width('100%')
          .height(88)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { this.onOpenRitual() })

        HomeWorkbench({
          stats: this.stats,
          statsLoading: this.statsLoading,
          todayPercent: this.todayPercent,
          todayDone: this.todayDone,
          todayTotal: this.todayTotal,
          ritualDone: this.ritualDone,
          activeGoals: this.activeGoals,
          listEpoch: this.listEpoch,
          bumpingGoalId: this.bumpingGoalId,
          recentRecords: this.recentRecords,
          onWriteRecord: (): void => { this.onWriteRecord() },
          onOpenRitual: (): void => { this.onOpenRitual() },
          onSwitchTab: (index: number): void => { this.onSwitchTab(index) },
          onOpenTools: (): void => { this.onOpenTools() },
          onOpenHabits: (): void => { this.onOpenHabits() },
          onBumpGoal: (goalId: string): void => { void this.bumpGoalOnHome(goalId) },
          onRequireAuth: (): void => { this.onRequireAuth() }
        })

        HomeToolkitRow({
          onOpenStuck: (): void => { this.onOpenStuck() },
          onOpenContrast: (): void => { this.onOpenContrast() },
          onOpenTheme: (): void => { this.onOpenTheme() }
        })

        if (this.latestFeatured !== undefined) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(GrowthMedia.coverMedia(this.latestFeatured.coverKey))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(180)
              .linearGradient({
                angle: 180,
                colors: [['rgba(27,42,65,0.1)', 0], ['rgba(27,42,65,0.78)', 1]]
              })
              .borderRadius(Theme.radius.xl)
            Column({ space: Theme.space.s3 }) {
              Text('精选成长')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
              Text(this.latestFeatured.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textOnInverse)
                .maxLines(2)
              AppButton({
                label: '查看详情',
                variant: 'secondary',
                onTap: (): void => {
                  const hero = this.latestFeatured
                  if (hero !== undefined) {
                    GrowthDetailNav.openFeatured(hero.id)
                  }
                }
              })
            }
            .padding(Theme.space.s5)
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .width('100%')
          .onClick((): void => {
            if (this.latestFeatured !== undefined) {
              GrowthDetailNav.openFeatured(this.latestFeatured.id)
            }
          })
        }

        if (this.loading) {
          AppLoading({ variant: 'skeleton' })
        } else {
          Column({ space: Theme.space.s3 }) {
            Text('推荐成长')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.featured.length === 0) {
              AppEmpty({
                title: '暂无推荐',
                description: '稍后再来看看新的成长灵感'
              })
            } else {
              Scroll() {
                Row({ space: Theme.space.s3 }) {
                  ForEach(this.featured, (item: GrowthRecordItem) => {
                    Column({ space: 8 }) {
                      Image(GrowthMedia.coverMedia(item.coverKey))
                        .width(140)
                        .height(100)
                        .borderRadius(Theme.radius.lg)
                        .objectFit(ImageFit.Cover)
                      Text(item.title)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .maxLines(2)
                        .width(140)
                    }
                    .onClick((): void => { GrowthDetailNav.openFeatured(item.id) })
                  }, (item: GrowthRecordItem) => item.id)
                }
                .padding({ right: Theme.space.pageX })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('我的成长记录')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.recentRecords.length === 0) {
              AppEmpty({
                title: '还没有成长记录',
                description: AuthService.isLoggedIn()
                  ? '使用上方「写记录」或前往「成长记录」Tab 开始'
                  : '登录后可记录并同步你的成长',
                actionLabel: AuthService.isLoggedIn() ? '记录成长' : '',
                onAction: (): void => { this.onWriteRecord() }
              })
            } else {
              ForEach(this.recentRecords.slice(0, 6), (item: GrowthRecordItem) => {
                GrowthListCard({
                  item: item,
                  compact: true,
                  onTap: (): void => { GrowthDetailNav.openInspiration(item.id) }
                })
              }, (item: GrowthRecordItem) => item.id)
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
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
