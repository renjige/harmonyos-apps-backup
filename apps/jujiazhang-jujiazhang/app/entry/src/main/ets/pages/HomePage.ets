import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { HomeItem, DutySlot, SceneTip, ActivityEvent, FamilyGoal } from '../models/JujiaModels'
import { ItemService } from '../services/ItemService'
import { SceneTipService } from '../services/SceneTipService'
import { MemberService } from '../services/MemberService'
import { ExpiryAlertBlock } from '../components/jujia/ExpiryAlertBlock'
import { SceneTipBlock, DutyStampBlock } from '../components/jujia/SceneDutyBlock'
import { HomeOverviewBlock } from '../components/jujia/HomeOverviewBlock'
import { TaskDates } from '../models/FamilyTaskModels'
import { TaskService } from '../services/TaskService'
import { HomeKpiGrid } from '../components/jujia/HomeKpiGrid'
import { HomeQuickActions } from '../components/jujia/HomeQuickActions'
import { HomeRecentActivity } from '../components/jujia/HomeRecentActivity'
import { HomeGoalsBlock } from '../components/jujia/HomeGoalsBlock'
import { HomeCapabilityStrip } from '../components/jujia/HomeCapabilityStrip'
import { HomeSceneBlock } from '../components/jujia/HomeSceneBlock'
import { HomeWeeklyReportBlock } from '../components/jujia/HomeWeeklyReportBlock'
import { FamilyStatsService } from '../services/FamilyStatsService'
import { ActivityService } from '../services/ActivityService'
import { GoalService } from '../services/GoalService'
import { ScenePackService } from '../services/ScenePackService'
import { HomeDiscoverHero } from '../components/jujia/HomeDiscoverHero'
import { FamilyOrderService } from '../services/FamilyOrderService'
import { ReviewService } from '../services/ReviewService'
import { LifeSceneDef } from '../models/LifeSceneModels'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State expiring: HomeItem[] = []
  @State tips: SceneTip[] = []
  @State slots: DutySlot[] = []
  @State stamps: number = 0
  @State itemTotal: number = 0
  @State itemExpiring: number = 0
  @State memoTotal: number = 0
  @State checklistTotal: number = 0
  @State diaryTotal: number = 0
  @State taskDone: number = 0
  @State memberTotal: number = 0
  @State favoriteTotal: number = 0
  @State streakDays: number = 0
  @State activities: ActivityEvent[] = []
  @State goals: FamilyGoal[] = []
  @State scenes: LifeSceneDef[] = []
  @State weekSummary: string = ''
  @State monthHeadline: string = ''
  @State orderScore: number = 0
  @State orderHeadline: string = ''
  @StorageLink('windowIsWide') isWide: boolean = false
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('dataRefreshEpoch') @Watch('onTick') dataRefreshEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  onOpenItems: () => void = () => {}
  onOpenMemos: () => void = () => {}
  onOpenTasks: () => void = () => {}
  onOpenMembers: () => void = () => {}
  onOpenSearch: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onCreateGoal: () => void = () => {}
  onOpenActivity: (ev: ActivityEvent) => void = (_e: ActivityEvent) => {}
  onApplyScene: (code: string) => void = (_c: string) => {}
  onOpenDiscover: () => void = () => {}
  onToast: (msg: string) => void = (_m: string) => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const snap = FamilyStatsService.snapshot()
    this.itemTotal = snap.itemTotal
    this.itemExpiring = await ItemService.countExpiring()
    this.memoTotal = snap.memoTotal
    this.checklistTotal = snap.checklistTotal
    this.diaryTotal = snap.diaryTotal
    this.taskDone = snap.taskDone
    this.memberTotal = snap.memberTotal
    this.favoriteTotal = snap.favoriteTotal
    this.streakDays = snap.streakDays
    this.activities = ActivityService.recent(5)
    this.goals = GoalService.active()
    this.scenes = ScenePackService.catalog()
    this.weekSummary = ReviewService.weekSummary()
    this.monthHeadline = ReviewService.monthHeadline()
    this.orderScore = FamilyOrderService.score()
    this.orderHeadline = FamilyOrderService.headline(this.orderScore)
    const soon = await ItemService.expiringSoon()
    const capped: HomeItem[] = []
    const limit = soon.length > 3 ? 3 : soon.length
    for (let i = 0; i < limit; i++) {
      capped.push(soon[i])
    }
    this.expiring = capped
    this.tips = await SceneTipService.build()
    this.slots = MemberService.todaySlots()
    const week = TaskService.weekRows(await TaskService.all(), TaskDates.today())
    const doneWeek = TaskService.doneCount(week)
    this.stamps = doneWeek > 7 ? 7 : doneWeek
  }

  private handleTip(code: string): void {
    if (code === 'items') {
      this.onOpenItems()
      return
    }
    if (code === 'memos') {
      this.onOpenMemos()
      return
    }
    if (code === 'members') {
      this.onOpenMembers()
      return
    }
    if (code === 'tasks') {
      this.onOpenTasks()
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          this.TopBar()
          HomeDiscoverHero({
            orderScore: this.orderScore,
            orderHeadline: this.orderHeadline,
            onOpenDiscover: () => this.onOpenDiscover()
          })
          HomeCapabilityStrip({
            onOpenDiscover: () => this.onOpenDiscover(),
            onOpenTasks: () => this.onOpenTasks(),
            onOpenItems: () => this.onOpenItems(),
            onOpenMemos: () => this.onOpenMemos(),
            onOpenSearch: () => this.onOpenSearch(),
            onOpenGrowth: () => this.onOpenGrowth()
          })
          HomeSceneBlock({
            scenes: this.scenes,
            onApply: (code: string) => this.onApplyScene(code)
          })
          HomeWeeklyReportBlock({
            summary: this.weekSummary,
            headline: this.monthHeadline,
            onOpenGrowth: () => this.onOpenGrowth()
          })
          HomeKpiGrid({
            checklistTotal: this.checklistTotal,
            memoTotal: this.memoTotal,
            itemTotal: this.itemTotal,
            favoriteTotal: this.favoriteTotal,
            streakDays: this.streakDays,
            onOpenMemos: () => this.onOpenMemos(),
            onOpenItems: () => this.onOpenItems(),
            onOpenFavorites: () => this.onOpenFavorites(),
            onOpenGrowth: () => this.onOpenGrowth()
          })
          HomeQuickActions({
            onApplyScene: () => this.onOpenDiscover(),
            onAddItem: () => this.onOpenItems(),
            onAddMemo: () => this.onOpenMemos(),
            onSearch: () => this.onOpenSearch(),
            onGrowth: () => this.onOpenGrowth()
          })
          HomeRecentActivity({
            items: this.activities,
            onOpenAll: () => this.onOpenGrowth(),
            onTapItem: (ev: ActivityEvent) => this.onOpenActivity(ev)
          })
          HomeGoalsBlock({
            goals: this.goals,
            onCreate: () => this.onCreateGoal()
          })
          HomeOverviewBlock({
            itemTotal: this.itemTotal,
            itemExpiring: this.itemExpiring,
            taskPendingToday: 0,
            taskPendingAll: 0,
            memoTotal: this.memoTotal,
            checklistTotal: this.checklistTotal,
            diaryTotal: this.diaryTotal,
            memberTotal: this.memberTotal,
            onOpenItems: () => this.onOpenItems(),
            onOpenMemos: () => this.onOpenMemos(),
            onOpenMembers: () => this.onOpenMembers(),
            onOpenTasks: () => this.onOpenTasks()
          })
          ExpiryAlertBlock({
            items: this.expiring,
            onOpenItems: () => this.onOpenItems(),
            onToast: (m: string) => this.onToast(m)
          })
          DutyStampBlock({
            slots: this.slots,
            stamps: this.stamps,
            onOpenMembers: () => this.onOpenMembers()
          })
          SceneTipBlock({
            tips: this.tips,
            onAction: (code: string) => this.handleTip(code)
          })
        }
        .padding({
          left: this.isWide ? 32 : Theme.space.pageX,
          right: this.isWide ? 32 : Theme.space.pageX,
          top: Theme.space.s5,
          bottom: 96
        })
        .constraintSize({ maxWidth: 720 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column() {
        Row({ space: 6 }) {
          AppIcon({ name: 'search', iconSize: 18, color: Theme.colors().brandOnPrimary })
          Text('生活发现')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandOnPrimary)
        }
      }
      .height(48)
      .padding({ left: 18, right: 20 })
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.button)
      .margin({ right: 20, bottom: 12 })
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onOpenDiscover())
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TopBar() {
    Row() {
      Column({ space: 4 }) {
        Text('家庭总览')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('场景 · 物品 · 备忘 · 成长，多模块协同一览。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(TaskDates.displayDate(TaskDates.today()))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Row({ space: 8 }) {
        Column() {
          AppIcon({ name: 'search', iconSize: 20, color: Theme.colors().textSecondary })
        }
        .width(44)
        .height(44)
        .borderRadius(22)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onOpenSearch())
        Column() {
          AppIcon({ name: 'grid', iconSize: 22, color: Theme.colors().textSecondary })
        }
        .width(44)
        .height(44)
        .borderRadius(22)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onOpenItems())
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
