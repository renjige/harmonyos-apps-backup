import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { JournalListCard } from '../components/journal/JournalListCard'
import { TodayHeroCard } from '../components/life/TodayHeroCard'
import { HomeProgressCard } from '../components/life/HomeProgressCard'
import { HomeStatRow } from '../components/life/HomeStatRow'
import { HomeQuickRow } from '../components/life/HomeQuickRow'
import { HomeTodayTasks } from '../components/life/HomeTodayTasks'
import { HomeMoodPicker } from '../components/life/HomeMoodPicker'
import { HomePlanStrip } from '../components/life/HomePlanStrip'
import { HomeScenarioRow } from '../components/life/HomeScenarioRow'
import { HomeActivityStrip } from '../components/life/HomeActivityStrip'
import { HomeCapabilityBanner } from '../components/life/HomeCapabilityBanner'
import { HomeModuleGrid } from '../components/life/HomeModuleGrid'
import { HomeFeaturedLead } from '../components/life/HomeFeaturedLead'
import { GuestCapabilityPreview } from '../components/life/GuestCapabilityPreview'
import { DeskSnapshot, HomeTaskRow } from '../models/LifeGrowthModels'
import { PlanItem } from '../models/LifeGrowthModels'
import { JournalItem } from '../models/JournalModels'
import { LifeDates, TodoItem } from '../models/LifeHubModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalCatalog, JournalScenario } from '../services/JournalCatalog'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { LifeGrowthService } from '../services/LifeGrowthService'
import { LifeHubNav } from '../services/LifeHubNav'
import { LifeHubStore } from '../services/LifeHubStore'
import { AuthService } from '../services/AuthService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '日常笺语'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('diaryDataVersion') @Watch('onDiaryDataVersionChange') diaryDataVersion: number = 0
  @StorageLink('lifeHubVersion') @Watch('onLifeHubVersionChange') lifeHubVersion: number = 0
  onWriteToday: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State featured: JournalItem[] = []
  @State recentDiaries: JournalItem[] = []
  @State echoItems: JournalItem[] = []
  @State promptText: string = ''
  @State loading: boolean = true
  @State desk: DeskSnapshot = new DeskSnapshot()
  @State plans: PlanItem[] = []
  @State taskEpoch: number = 0
  @State planEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDiaryDataVersionChange(): void {
    void this.reload()
  }

  onLifeHubVersionChange(): void {
    void this.reloadDesk()
  }

  private greeting(): string {
    const hour = new Date().getHours()
    if (hour < 11) {
      return '早安，今天从计划与灵感开始'
    }
    if (hour < 17) {
      return '午后好，执行与创作都在笺台'
    }
    return '晚上好，收一收今天的进度与回顾'
  }

  private firstThree(items: JournalItem[]): JournalItem[] {
    const out: JournalItem[] = []
    for (const d of items) {
      if (out.length < 3) {
        out.push(d)
      }
    }
    return out
  }

  private todayIso(): string {
    return LifeDates.todayIso()
  }

  private todayLabel(): string {
    const d = new Date()
    const names: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `${d.getMonth() + 1}月${d.getDate()}日 · 星期${names[d.getDay()]}`
  }

  private firstFive(items: JournalItem[]): JournalItem[] {
    const out: JournalItem[] = []
    for (const d of items) {
      if (out.length < 5) {
        out.push(d)
      }
    }
    return out
  }

  private async reloadDesk(): Promise<void> {
    this.desk = await LifeGrowthService.loadDesk(this.currentUsername)
    this.plans = await LifeGrowthService.loadActivePlans(this.currentUsername, 2)
    this.taskEpoch += 1
    this.planEpoch += 1
  }

  private applyScenario(s: JournalScenario): void {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    JournalCatalog.applyScenarioPrefill(s, this.todayIso())
    JournalCatalog.triggerScenarioWrite()
  }

  private async reload(): Promise<void> {
    this.promptText = JournalCatalog.promptForDate(this.todayIso())
    try {
      if (this.recentDiaries.length === 0) {
        this.loading = true
      }
      this.featured = await JournalBizService.loadFeatured()
      if (AuthService.isLoggedIn()) {
        const cached = await JournalBizService.cachedDiaries(this.currentUsername)
        if (cached.length > 0) {
          this.recentDiaries = cached
          this.echoItems = JournalBizService.sameDayItems(cached, this.todayIso())
          this.loading = false
        }
        const remote = await JournalBizService.loadDiaries(this.currentUsername)
        this.recentDiaries = remote
        this.echoItems = JournalBizService.sameDayItems(remote, this.todayIso())
        await this.reloadDesk()
      } else {
        this.recentDiaries = []
        this.echoItems = []
        this.desk = new DeskSnapshot()
      }
    } catch {
      this.echoItems = JournalBizService.sameDayItems(this.recentDiaries, this.todayIso())
    }
    this.loading = false
  }

  private async onToggleTask(row: HomeTaskRow): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    if (row.kind === 'todo') {
      const item = new TodoItem()
      item.id = row.id
      item.title = row.title
      item.done = !row.done
      item.date = this.todayIso()
      const all = await LifeHubStore.loadTodos()
      for (const t of all) {
        if (t.id === row.id) {
          t.done = !t.done
          await LifeHubStore.upsertTodo(t)
          await this.reloadDesk()
          return
        }
      }
      await LifeHubStore.upsertTodo(item)
    } else {
      await LifeHubStore.toggleHabit(row.id, this.todayIso())
    }
    await this.reloadDesk()
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
          Text(`${this.todayLabel()} · ${this.appName}`)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text(this.tagline)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        HomeModuleGrid()

        if (!AuthService.isLoggedIn()) {
          GuestCapabilityPreview({
            onRequireAuth: (): void => { this.onRequireAuth() }
          })
        }

        if (!this.loading && this.featured.length > 0) {
          HomeFeaturedLead({ items: this.firstThree(this.featured) })
        }

        HomeCapabilityBanner()

        Row({ space: Theme.space.s3 }) {
          Image($r('app.media.hero_morning_coffee'))
            .layoutWeight(1)
            .height(88)
            .borderRadius(Theme.radius.lg)
            .objectFit(ImageFit.Cover)
          Image($r('app.media.hero_bookstore'))
            .layoutWeight(1)
            .height(88)
            .borderRadius(Theme.radius.lg)
            .objectFit(ImageFit.Cover)
        }
        .width('100%')

        HomePlanStrip({
          plans: this.plans,
          listEpoch: this.planEpoch
        })

        HomeMoodPicker({
          currentMood: this.desk.moodLabel,
          onRequireAuth: (): void => { this.onRequireAuth() },
          onSaved: (): void => { void this.reloadDesk() }
        })

        HomeTodayTasks({
          listEpoch: this.taskEpoch,
          rows: this.desk.tasks,
          onToggle: (row: HomeTaskRow): void => { void this.onToggleTask(row) },
          onEmptyWrite: (): void => { AppStorage.setOrCreate('pendingTab', 1) }
        })

        HomeProgressCard({
          percent: this.desk.progressPct,
          hint: this.desk.progressHint,
          moodLabel: this.desk.moodLabel,
          activityHint: this.desk.diaryDone ? '今日已有创作' : '待办/打卡/创作综合进度',
          onContinue: (): void => { AppStorage.setOrCreate('pendingTab', 2) }
        })

        HomeStatRow({
          diaryCount: this.desk.diaryCount,
          doneCount: this.desk.doneCount,
          favoriteCount: this.desk.favoriteCount,
          streakDays: this.desk.streakDays
        })

        HomeQuickRow({ onWrite: (): void => { AppStorage.setOrCreate('pendingTab', 1) } })

        HomeScenarioRow({
          onPick: (s: JournalScenario): void => { this.applyScenario(s) }
        })

        TodayHeroCard({
          coverKey: this.desk.coverKey,
          moodLabel: this.desk.moodLabel,
          diaryTitle: this.desk.diaryTitle,
          hasToday: this.desk.diaryDone,
          onWriteToday: (): void => { AppStorage.setOrCreate('pendingTab', 1) }
        })

        Column({ space: 6 }) {
          Text('今日创作题')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          Text(this.promptText)
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.lg)
        .onClick((): void => { AppStorage.setOrCreate('pendingTab', 1) })

        HomeActivityStrip({ items: this.desk.recentActs })

        if (this.loading) {
          AppLoading({ variant: 'skeleton' })
        } else {
          this.RecentBlock()
        }

        Row() {
          Text('更多生活工具')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().brandPrimary)
          Blank()
          Text(`成就 ${this.desk.unlockedCount}/${this.desk.badgeTotal}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .onClick((): void => { LifeHubNav.open('menu', false) })
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

  @Builder
  RecentBlock() {
    if (AuthService.isLoggedIn()) {
      Column({ space: Theme.space.s3 }) {
        Text('我的创作')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        if (this.recentDiaries.length === 0) {
          AppEmpty({
            title: '尚无个人创作',
            description: '从灵感页选场景，或在计划页完成今日任务',
            actionLabel: '去灵感页',
            onAction: (): void => { AppStorage.setOrCreate('pendingTab', 1) }
          })
        } else {
          ForEach(this.firstFive(this.recentDiaries), (item: JournalItem) => {
            JournalListCard({
              item: item,
              compact: true,
              onTap: (): void => { JournalDetailNav.openDiary(item.id) }
            })
          }, (item: JournalItem) => item.id)
        }
        if (this.echoItems.length > 0) {
          Text('往年今日')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.firstFive(this.echoItems), (item: JournalItem) => {
            JournalListCard({
              item: item,
              compact: true,
              onTap: (): void => { JournalDetailNav.openDiary(item.id) }
            })
          }, (item: JournalItem) => `echo_${item.id}`)
        }
      }
      .width('100%')
    }
  }
}
