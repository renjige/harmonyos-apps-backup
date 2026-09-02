import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspirationListCard } from '../components/inspiration/InspirationListCard'
import { DailyPromptCard } from '../components/inspiration/DailyPromptCard'
import { HomeFavoriteStrip } from '../components/inspiration/HomeFavoriteStrip'
import { CaptureTemplateGrid } from '../components/inspiration/CaptureTemplateGrid'
import { InspirationItem } from '../models/InspirationModels'
import { DailyPrompt } from '../models/WorkbenchModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { InspirationMedia } from '../services/InspirationMedia'
import { AuthService } from '../services/AuthService'
import { DailyPromptService } from '../services/DailyPromptService'
import { FavoriteSync } from '../services/FavoriteSync'
import { CaptureStreakService } from '../services/CaptureStreakService'
import { BoardPinService } from '../services/BoardPinService'
import { ConvertWorkflowStrip } from '../components/inspiration/ConvertWorkflowStrip'
import { CreativeFeaturesCard } from '../components/inspiration/CreativeFeaturesCard'
import { ConversionPipelineBoard } from '../components/inspiration/ConversionPipelineBoard'
import { GuestExperienceCard } from '../components/inspiration/GuestExperienceCard'
import { HomeWorkbenchHero } from '../components/inspiration/HomeWorkbenchHero'
import { HomeKpiRow } from '../components/inspiration/HomeKpiRow'
import { GrowthStore } from '../services/GrowthStore'
import { GrowthService } from '../services/GrowthService'
import { GrowthStatsService, GrowthStatsSnapshot } from '../services/GrowthStatsService'
import { AchievementService } from '../services/AchievementService'
import { ActivityEvent, RecentBrowseItem } from '../models/GrowthModels'
import {
  ConversionPipelineService,
  PipelineSnapshot,
  PipelineStageItem
} from '../services/ConversionPipelineService'

class QuickEntry {
  label: string = ''
  icon: string = 'book'
  action: () => void = () => {}
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '转化工作台'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('contentEpoch') @Watch('onContentEpochChange') contentEpoch: number = 0
  @StorageLink('favoriteEpoch') @Watch('onFavoriteEpochChange') favoriteEpoch: number = 0
  @StorageLink('growthEpoch') @Watch('onGrowthEpochChange') growthEpoch: number = 0
  onCaptureInspiration: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenOrganize: () => void = () => {}
  onOpenTimeline: () => void = () => {}
  onOpenWeeklyReview: () => void = () => {}
  onOpenPlans: () => void = () => {}
  onOpenCheckIn: () => void = () => {}
  onOpenStats: () => void = () => {}
  onOpenAchievements: () => void = () => {}
  onOpenTopics: () => void = () => {}
  onOpenReadiness: () => void = () => {}
  onSwitchTab: (index: number) => void = () => {}
  onRequireAuth: () => void = () => {}
  @State featured: InspirationItem[] = []
  @State recentInspirations: InspirationItem[] = []
  @State favoritePreview: InspirationItem[] = []
  @State latestFeatured: InspirationItem | undefined = undefined
  @State loading: boolean = true
  @State streakDays: number = 0
  @State boardCount: number = 0
  @State planCount: number = 0
  @State snap: GrowthStatsSnapshot = new GrowthStatsSnapshot()
  @State activePlans: InspirationItem[] = []
  @State activityEvents: ActivityEvent[] = []
  @State recentBrowse: RecentBrowseItem[] = []
  @State pipelineSnap: PipelineSnapshot = PipelineSnapshot.empty()
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onContentEpochChange(): void {
    void this.reload()
  }

  onFavoriteEpochChange(): void {
    void this.reload()
  }

  onGrowthEpochChange(): void {
    void this.reload()
  }

  private greeting(): string {
    const hour = new Date().getHours()
    if (hour < 11) {
      return '早安，开启创意转化'
    }
    if (hour < 17) {
      return '午安，把灵感拆成可推进的计划'
    }
    return '晚安，回顾今日创意成长'
  }

  private todayLabel(): string {
    const d = new Date()
    const month = d.getMonth() + 1
    const day = d.getDate()
    const weekdays: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `${month}月${day}日 · 星期${weekdays[d.getDay()]} · 创意转化工作台`
  }

  private openFeaturedCompare(): void {
    if (this.latestFeatured !== undefined) {
      InspirationDetailNav.openFeatured(this.latestFeatured.id)
      return
    }
    if (this.featured.length > 0) {
      InspirationDetailNav.openFeatured(this.featured[0].id)
    }
  }

  private quickEntries(): QuickEntry[] {
    const entries: QuickEntry[] = []
    const e0 = new QuickEntry()
    e0.label = '快速捕捉'
    e0.icon = 'book'
    e0.action = (): void => { this.onCaptureInspiration() }
    entries.push(e0)
    const e1 = new QuickEntry()
    e1.label = '今日打卡'
    e1.icon = 'check'
    e1.action = (): void => { this.onOpenCheckIn() }
    entries.push(e1)
    const e2 = new QuickEntry()
    e2.label = '灵感专题'
    e2.icon = 'heart'
    e2.action = (): void => { this.onOpenTopics() }
    entries.push(e2)
    const e3 = new QuickEntry()
    e3.label = '成长统计'
    e3.icon = 'chart'
    e3.action = (): void => { this.onOpenStats() }
    entries.push(e3)
    return entries
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.featured = await InspirationBizService.loadFeatured()
    if (this.featured.length > 0) {
      this.latestFeatured = this.featured[0]
    } else {
      this.latestFeatured = undefined
    }
    if (AuthService.isLoggedIn()) {
      this.recentInspirations = await InspirationBizService.loadInspirations(this.currentUsername)
      this.pipelineSnap = await ConversionPipelineService.load(this.currentUsername)
      this.favoritePreview = await InspirationBizService.loadFavorites(this.currentUsername)
      this.streakDays = CaptureStreakService.consecutiveDays(this.recentInspirations)
      const ownBoards = await BoardPinService.listOwnBoards(this.currentUsername)
      this.boardCount = ownBoards.length
      const plans = await InspirationBizService.loadCreativePlans(this.currentUsername)
      this.planCount = plans.length
      const active: InspirationItem[] = []
      for (const p of plans) {
        if (p.progress < 100 && active.length < 2) {
          active.push(p)
        }
      }
      this.activePlans = active
      const growth = await GrowthStore.load(this.currentUsername)
      const newly = AchievementService.evaluate(
        growth, this.recentInspirations, plans, this.favoritePreview
      )
      if (newly.length > 0) {
        await GrowthStore.save(this.currentUsername, growth)
        this.toastText = `点亮成就：${AchievementService.titleOf(newly[0])}`
        setTimeout(() => { this.toastText = '' }, 2600)
      }
      this.snap = GrowthStatsService.snapshot(
        this.recentInspirations,
        this.favoritePreview,
        ownBoards,
        plans,
        growth,
        GrowthService.hasCheckIn(growth, GrowthService.todayIso())
      )
      const evs: ActivityEvent[] = []
      let n = 0
      for (const ev of growth.activity) {
        if (n >= 4) {
          break
        }
        evs.push(ev)
        n += 1
      }
      this.activityEvents = evs
      this.recentBrowse = await GrowthService.loadValidRecent(this.currentUsername, 3)
    } else {
      this.recentInspirations = []
      this.pipelineSnap = PipelineSnapshot.empty()
      this.favoritePreview = []
      this.streakDays = 0
      this.boardCount = 0
      this.planCount = 0
      this.activePlans = []
      this.activityEvents = []
      this.recentBrowse = []
      this.snap = new GrowthStatsSnapshot()
    }
    this.loading = false
  }

  private handleUsePrompt(): void {
    DailyPromptService.applyToCapture()
    this.onCaptureInspiration()
  }

  private handlePickTemplate(item: DailyPrompt): void {
    DailyPromptService.applyPrompt(item)
    this.onCaptureInspiration()
  }

  private openFavoriteItem(item: InspirationItem): void {
    const src = FavoriteSync.parseSourceKey(item.content)
    if (src.startsWith('featured:')) {
      InspirationDetailNav.openFeatured(src.substring(9))
      return
    }
    if (src.startsWith('inspiration:')) {
      InspirationDetailNav.openInspiration(src.substring(13))
    }
  }

  private openRecent(row: RecentBrowseItem): void {
    if (row.kind === 'featured') {
      InspirationDetailNav.openFeatured(row.id)
      return
    }
    if (row.kind === 'inspiration') {
      InspirationDetailNav.openInspiration(row.id)
      return
    }
    if (row.kind === 'board') {
      InspirationDetailNav.openBoard(row.id)
      return
    }
    if (row.kind === 'plan') {
      InspirationDetailNav.openPlan(row.id)
    }
  }

  private queuePreview(): PipelineStageItem[] {
    const rows = ConversionPipelineService.filterByStage(this.pipelineSnap, 'all')
    const out: PipelineStageItem[] = []
    let n = 0
    for (const row of rows) {
      if (n >= 4) {
        break
      }
      out.push(row)
      n += 1
    }
    return out
  }

  private async unfavoriteHome(id: string): Promise<void> {
    const ok = await InspirationBizService.deleteFavorite(id)
    if (ok) {
      const next: InspirationItem[] = []
      for (const it of this.favoritePreview) {
        if (it.id !== id) {
          next.push(it)
        }
      }
      this.favoritePreview = next
      FavoriteSync.bump()
    }
  }

  @Builder
  QuickEntryItem(entry: QuickEntry) {
    Column({ space: 6 }) {
      Column() {
        AppIcon({
          name: entry.icon === 'book' ? 'book' :
            entry.icon === 'check' ? 'check' :
              entry.icon === 'heart' ? 'heart' : 'chart',
          iconSize: Theme.icon.lg,
          color: Theme.colors().brandPrimary
        })
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.lg)
      Text(entry.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .onClick((): void => { entry.action() })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
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
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_latest_inspiration'))
            .width('100%')
            .height(210)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(210)
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,42,65,0.08)', 0], ['rgba(27,42,65,0.78)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          HomeWorkbenchHero({
            weekCapture: this.snap.weekCapture,
            weekGoal: this.snap.weekGoal,
            checkInToday: this.snap.checkInToday,
            loggedIn: AuthService.isLoggedIn(),
            onContinue: (): void => { this.onCaptureInspiration() },
            onCheckIn: (): void => { this.onOpenCheckIn() }
          })
        }
        .width('100%')

        ConversionPipelineBoard({
          snap: this.pipelineSnap,
          loggedIn: AuthService.isLoggedIn(),
          onOpenItem: (id: string): void => { InspirationDetailNav.openInspiration(id) },
          onOpenCapture: (): void => { this.onCaptureInspiration() },
          onOpenReadiness: (): void => { this.onOpenReadiness() }
        })

        if (!AuthService.isLoggedIn()) {
          GuestExperienceCard({
            onBrowseFeatured: (): void => { this.openFeaturedCompare() },
            onLogin: (): void => { this.onRequireAuth() }
          })
        }

        HomeKpiRow({
          captureTotal: this.snap.captureTotal,
          planAvg: this.snap.planAvgProgress,
          favoriteTotal: this.snap.favoriteTotal,
          streakDays: this.snap.streakDays,
          onOpenRecords: (): void => { this.onSwitchTab(1) },
          onOpenPlans: (): void => { this.onOpenPlans() },
          onOpenFavorites: (): void => { this.onOpenFavorites() }
        })

        ConvertWorkflowStrip({
          noteCount: this.recentInspirations.length,
          boardCount: this.boardCount,
          planCount: this.planCount,
          onCapture: (): void => { this.onCaptureInspiration() },
          onOpenBoard: (): void => { this.onSwitchTab(2) },
          onOpenPlans: (): void => { this.onOpenPlans() }
        })

        CreativeFeaturesCard({
          onOpenFeatured: (): void => { this.openFeaturedCompare() },
          onOpenPlans: (): void => { this.onOpenPlans() },
          onOpenTopics: (): void => { this.onOpenTopics() },
          onOpenReview: (): void => { this.onOpenWeeklyReview() }
        })

        DailyPromptCard({
          onUsePrompt: (): void => { this.handleUsePrompt() },
          onOpenReview: (): void => { this.onOpenWeeklyReview() }
        })

        if (this.activePlans.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Text('进行中的计划')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.activePlans, (p: InspirationItem) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 4 }) {
                  Text(p.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(1)
                    .width('100%')
                  Text(`进度 ${p.progress}%`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { InspirationDetailNav.openPlan(p.id) })
            }, (p: InspirationItem) => p.id)
          }
          .width('100%')
        }

        if (this.activityEvents.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Text('最近动态')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.activityEvents, (ev: ActivityEvent) => {
              Column({ space: 4 }) {
                Text(ev.title)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(2)
                  .width('100%')
                Text(`${GrowthService.typeLabel(ev.type)} · ${ev.at}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .alignItems(HorizontalAlign.Start)
              .onClick((): void => {
                if (ev.refKind === 'inspiration' && ev.refId.length > 0) {
                  InspirationDetailNav.openInspiration(ev.refId)
                }
                if (ev.refKind === 'plan' && ev.refId.length > 0) {
                  InspirationDetailNav.openPlan(ev.refId)
                }
              })
            }, (ev: ActivityEvent) => `${ev.at}_${ev.refId}_${ev.type}`)
          }
          .width('100%')
        }

        if (this.recentBrowse.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Text('最近浏览')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.recentBrowse, (row: RecentBrowseItem) => {
              Row() {
                Column({ space: 2 }) {
                  Text(row.title)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(1)
                    .width('100%')
                  Text(GrowthService.recentKindLabel(row.kind))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.openRecent(row) })
            }, (row: RecentBrowseItem) => `${row.kind}_${row.id}_${row.at}`)
          }
          .width('100%')
        }

        CaptureTemplateGrid({
          onPick: (item: DailyPrompt): void => { this.handlePickTemplate(item) }
        })

        Row({ space: Theme.space.s3 }) {
          Image($r('app.media.hero_typography'))
            .layoutWeight(1)
            .height(88)
            .borderRadius(Theme.radius.lg)
            .objectFit(ImageFit.Cover)
          Image($r('app.media.hero_mood_brand'))
            .layoutWeight(1)
            .height(88)
            .borderRadius(Theme.radius.lg)
            .objectFit(ImageFit.Cover)
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          ForEach(this.quickEntries(), (entry: QuickEntry) => {
            this.QuickEntryItem(entry)
          }, (entry: QuickEntry) => entry.label)
        }
        .width('100%')

        if (this.latestFeatured !== undefined) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(InspirationMedia.coverMedia(this.latestFeatured.coverKey))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(180)
              .linearGradient({
                angle: 180,
                colors: [['rgba(51,65,85,0.12)', 0], ['rgba(51,65,85,0.82)', 1]]
              })
              .borderRadius(Theme.radius.xl)
            Column({ space: Theme.space.s3 }) {
              Text('精选灵感')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
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
                    InspirationDetailNav.openFeatured(hero.id)
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
              InspirationDetailNav.openFeatured(this.latestFeatured.id)
            }
          })
        }

        if (this.loading) {
          AppLoading({ variant: 'skeleton' })
        } else {
          Column({ space: Theme.space.s3 }) {
            Row() {
              Text('待转化队列')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              if (AuthService.isLoggedIn() && this.pipelineSnap.totalCount() > 0) {
                Text('查看全部')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => { this.onSwitchTab(1) })
              }
            }
            .width('100%')
            if (this.recentInspirations.length === 0) {
              AppEmpty({
                title: '还没有灵感',
                description: AuthService.isLoggedIn()
                  ? '用今日提示写第一条，或前往「捕捉」Tab 查看转化队列'
                  : '登录后可记录并同步你的转化流水线',
                actionLabel: AuthService.isLoggedIn() ? '快速捕捉' : '',
                onAction: (): void => { this.onCaptureInspiration() }
              })
            } else {
              ForEach(this.queuePreview(), (row: PipelineStageItem) => {
                InspirationListCard({
                  item: row.inspiration,
                  compact: true,
                  stageKey: row.stage,
                  onTap: (): void => { InspirationDetailNav.openInspiration(row.inspiration.id) }
                })
              }, (row: PipelineStageItem) => `${row.stage}_${row.inspiration.id}`)
            }
          }
          .width('100%')

          HomeFavoriteStrip({
            items: this.favoritePreview,
            onOpenAll: (): void => { this.onOpenFavorites() },
            onRequireAuth: (): void => { this.onRequireAuth() },
            onOpenItem: (item: InspirationItem): void => { this.openFavoriteItem(item) },
            onUnfavorite: (id: string): void => { void this.unfavoriteHome(id) }
          })
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

    if (this.toastText.length > 0) {
      Text(this.toastText)
        .fontSize(Theme.type.caption)
        .fontColor('#FFFFFF')
        .padding({
          left: Theme.space.s4,
          right: Theme.space.s4,
          top: Theme.space.s3,
          bottom: Theme.space.s3
        })
        .backgroundColor('rgba(27,42,65,0.92)')
        .borderRadius(Theme.radius.lg)
        .margin({ top: Theme.space.s6 })
        .zIndex(20)
    }
    }
    .width('100%')
    .height('100%')
  }
}
