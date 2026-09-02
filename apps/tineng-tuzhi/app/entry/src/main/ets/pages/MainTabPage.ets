import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { ActionDetailPane } from '../components/fitness/ActionDetailPane'
import { AtlasReportPane } from '../components/fitness/AtlasReportPane'
import { DayWorkoutList } from '../components/fitness/DayWorkoutList'
import { ProgramGuidePane } from '../components/fitness/ProgramGuidePane'
import { WeekPlanSheet } from '../components/fitness/WeekPlanSheet'
import { WorkoutDetailPane } from '../components/fitness/WorkoutDetailPane'
import { WorkoutHistoryPane } from '../components/fitness/WorkoutHistoryPane'
import { WorkoutRecordSheet } from '../components/fitness/WorkoutRecordSheet'
import { WorkoutRecord } from '../models/WorkoutModels'
import { AchievementService } from '../services/AchievementService'
import { DateHelper } from '../services/DateHelper'
import { FitDataNotify } from '../services/FitDataNotify'
import { TrainingStore } from '../services/TrainingStore'
import { StatsService } from '../services/StatsService'
import { TemplateStore } from '../services/TemplateStore'
import { WorkoutStore } from '../services/WorkoutStore'
import { AtlasPage } from './AtlasPage'
import { GrowthPage } from './GrowthPage'
import { HomePage } from './HomePage'
import { MinePage } from './MinePage'
import { PlanHubPage } from './PlanHubPage'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '首页'],
      ['1', 'biz', '计划'],
      ['2', 'search', '图鉴'],
      ['3', 'chart', '成长'],
      ['4', 'user', '我的']
    ]
    for (const d of defs) {
      const t = new TabItem()
      t.index = parseInt(d[0], 10)
      t.name = d[1] as AppIconName
      t.label = d[2]
      tabs.push(t)
    }
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('fitDataEpoch') fitDataEpoch: number = 0
  @State current: number = 0
  @State refreshToken: number = 0
  @State showRecord: boolean = false
  @State editingId: string = ''
  @State seedDateKey: string = ''
  @State detailRecord: WorkoutRecord | undefined = undefined
  @State showPlan: boolean = false
  @State showAtlas: boolean = false
  @State actionId: string = ''
  @State dayListKey: string = ''
  @State dayItems: WorkoutRecord[] = []
  @State showHistory: boolean = false
  @State historyFilter: string = 'all'
  @State historyItems: WorkoutRecord[] = []
  @State showPrograms: boolean = false
  @State seedTypeKey: string = ''
  @State seedDurationMinutes: number = 0
  @State seedSessionTitle: string = ''
  @State globalToast: string = ''
  onPrivacyRevoked: () => void = () => {}
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 28

  build() {
    Stack() {
      Column() {
        Stack() {
          HomePage({
            refreshToken: $refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onRecord: (): void => { this.openRecord('', DateHelper.todayKey()) },
            onOpenDetail: (id: string): void => { void this.openDetail(id) },
            onOpenWeekPlan: (): void => { this.openPlan() },
            onGoPlan: (): void => { this.current = 1 },
            onGoAtlas: (): void => { this.current = 2 },
            onGoGrowth: (): void => { this.current = 3 },
            onOpenHistory: (): void => { void this.openHistory() },
            onOpenDay: (dateKey: string): void => { void this.openDay(dateKey) },
            onQuickTemplate: (typeKey: string, minutes: number, title: string): void => {
              this.openRecordWithSeed(typeKey, minutes, title)
            }
          })
            .width('100%')
            .height('100%')
            .key(`home-tab-${this.refreshToken}`)
            .zIndex(this.current === 0 ? 10 : 0)
            .opacity(this.current === 0 ? 1 : 0)
            .hitTestBehavior(this.current === 0 ? HitTestMode.Default : HitTestMode.None)

          PlanHubPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onOpenWeekPlan: (): void => { this.openPlan() },
            onOpenPrograms: (): void => { this.openPrograms() },
            onRecord: (): void => { this.openRecord('', DateHelper.todayKey()) }
          })
            .width('100%')
            .height('100%')
            .zIndex(this.current === 1 ? 10 : 0)
            .opacity(this.current === 1 ? 1 : 0)
            .hitTestBehavior(this.current === 1 ? HitTestMode.Default : HitTestMode.None)

          AtlasPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onOpenAction: (id: string): void => { this.openAction(id) }
          })
            .width('100%')
            .height('100%')
            .zIndex(this.current === 2 ? 10 : 0)
            .opacity(this.current === 2 ? 1 : 0)
            .hitTestBehavior(this.current === 2 ? HitTestMode.Default : HitTestMode.None)

          GrowthPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onOpenDay: (dateKey: string): void => { void this.openDay(dateKey) },
            onOpenWeekReport: (): void => { this.openAtlas() }
          })
            .width('100%')
            .height('100%')
            .zIndex(this.current === 3 ? 10 : 0)
            .opacity(this.current === 3 ? 1 : 0)
            .hitTestBehavior(this.current === 3 ? HitTestMode.Default : HitTestMode.None)

          MinePage({
            refreshToken: $refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onPrivacyRevoked: (): void => {},
            onDataCleared: (): void => {
              this.refreshToken++
              void FitDataNotify.syncStats()
            }
          })
            .width('100%')
            .height('100%')
            .key(`mine-tab-${this.refreshToken}`)
            .zIndex(this.current === 4 ? 10 : 0)
            .opacity(this.current === 4 ? 1 : 0)
            .hitTestBehavior(this.current === 4 ? HitTestMode.Default : HitTestMode.None)
        }
        .layoutWeight(1)
        .width('100%')

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(this.tabBarHeight)
          .padding({ left: Theme.space.s3, right: Theme.space.s3, bottom: this.tabSafeBottom })
          .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s2 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(26,35,50,0.08)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showRecord) {
        WorkoutRecordSheet({
          editingId: this.editingId,
          seedDateKey: this.seedDateKey,
          seedTypeKey: this.seedTypeKey,
          seedDurationMinutes: this.seedDurationMinutes,
          seedSessionTitle: this.seedSessionTitle,
          onClose: (): void => { this.closeRecord() },
          onSave: (rec: WorkoutRecord): void => { void this.handleSave(rec) }
        })
          .width('100%')
          .height('100%')
          .zIndex(25)
      }

      if (this.dayListKey.length > 0) {
        DayWorkoutList({
          dateKey: this.dayListKey,
          items: this.dayItems,
          onClose: (): void => { this.closeDay() },
          onOpenDetail: (id: string): void => { void this.openDetail(id) },
          onRecordDay: (): void => { this.openRecord('', this.dayListKey) }
        })
          .width('100%')
          .height('100%')
          .zIndex(24)
      }

      if (this.showPlan) {
        WeekPlanSheet({
          onClose: (): void => { this.closePlan() },
          onSaved: (): void => { void this.handlePlanSaved() }
        })
          .width('100%')
          .height('100%')
          .zIndex(25)
      }

      if (this.showAtlas) {
        AtlasReportPane({
          onClose: (): void => { this.closeAtlas() },
          onOpenPlan: (): void => {
            this.showAtlas = false
            this.openPlan()
          },
          onRecord: (): void => {
            this.showAtlas = false
            this.openRecord('', DateHelper.todayKey())
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(25)
      }

      if (this.showPrograms) {
        ProgramGuidePane({
          onClose: (): void => { this.closePrograms() },
          onApply: (programId: string): void => { void this.handleApplyProgram(programId) }
        })
          .width('100%')
          .height('100%')
          .zIndex(25)
      }

      if (this.showHistory) {
        WorkoutHistoryPane({
          items: this.historyItems,
          filterKey: this.historyFilter,
          onClose: (): void => { this.closeHistory() },
          onFilterChange: (key: string): void => { void this.applyHistoryFilter(key) },
          onOpenDetail: (id: string): void => { void this.openDetail(id) },
          onRecord: (): void => {
            this.closeHistory()
            this.openRecord('', DateHelper.todayKey())
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(24)
      }

      if (this.actionId.length > 0) {
        ActionDetailPane({
          actionId: this.actionId,
          onClose: (): void => { this.closeAction() },
          onLog: (): void => {
            this.closeAction()
            this.openRecord('', DateHelper.todayKey())
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(25)
      }

      if (this.detailRecord !== undefined) {
        WorkoutDetailPane({
          recordId: this.detailRecord.id,
          typeKey: this.detailRecord.typeKey,
          dateKey: this.detailRecord.dateKey,
          durationMinutes: this.detailRecord.durationMinutes,
          calories: this.detailRecord.calories,
          distanceKm: this.detailRecord.distanceKm,
          heartRateZone: this.detailRecord.heartRateZone,
          feeling: this.detailRecord.feeling,
          tag: this.detailRecord.tag,
          note: this.detailRecord.note,
          insight: this.detailRecord.insight,
          sessionTitle: this.detailRecord.sessionTitle,
          starRating: this.detailRecord.starRating,
          completeState: this.detailRecord.completeState,
          onClose: (): void => { this.closeDetail() },
          onDelete: (): void => { void this.handleDelete() },
          onEdit: (): void => { this.openEditFromDetail() }
        })
          .width('100%')
          .height('100%')
          .zIndex(26)
      }

      if (this.globalToast.length > 0) {
        Text(this.globalToast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .margin({ top: 52 })
          .backgroundColor('#1A2332')
          .borderRadius(Theme.radius.pill)
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }

  private hideBar(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private showBarIfIdle(): void {
    if (!this.showRecord && !this.showPlan && !this.showAtlas && !this.showHistory &&
      !this.showPrograms && this.detailRecord === undefined && this.dayListKey.length === 0 &&
      this.actionId.length === 0) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  private clearRecordSeed(): void {
    this.seedTypeKey = ''
    this.seedDurationMinutes = 0
    this.seedSessionTitle = ''
  }

  private openRecord(editingId: string, dateKey: string): void {
    if (editingId.length === 0) {
      this.clearRecordSeed()
    }
    this.editingId = editingId
    this.seedDateKey = dateKey
    this.hideBar()
    this.showRecord = true
  }

  private openRecordWithSeed(typeKey: string, minutes: number, title: string): void {
    this.editingId = ''
    this.seedDateKey = DateHelper.todayKey()
    this.seedTypeKey = typeKey
    this.seedDurationMinutes = minutes
    this.seedSessionTitle = title
    this.hideBar()
    this.showRecord = true
  }

  private closeRecord(): void {
    this.showRecord = false
    this.editingId = ''
    this.clearRecordSeed()
    this.showBarIfIdle()
  }

  private openPrograms(): void {
    this.hideBar()
    this.showPrograms = true
  }

  private closePrograms(): void {
    this.showPrograms = false
    this.showBarIfIdle()
  }

  private async handleApplyProgram(programId: string): Promise<void> {
    await TrainingStore.applyProgram(programId)
    await FitDataNotify.syncStats()
    this.refreshToken++
    this.closePrograms()
    this.showGlobalToast('训练方案已加入周期计划')
  }

  private async openHistory(): Promise<void> {
    this.historyFilter = 'all'
    this.historyItems = await MainTabPage.sortHistory(await WorkoutStore.loadAll(), 'all')
    this.hideBar()
    this.showHistory = true
  }

  private closeHistory(): void {
    this.showHistory = false
    this.showBarIfIdle()
  }

  private async applyHistoryFilter(key: string): Promise<void> {
    this.historyFilter = key
    this.historyItems = await MainTabPage.sortHistory(await WorkoutStore.loadAll(), key)
  }

  private static async sortHistory(all: WorkoutRecord[], filterKey: string): Promise<WorkoutRecord[]> {
    const filtered: WorkoutRecord[] = []
    for (const w of all) {
      if (filterKey === 'all' || w.typeKey === filterKey) {
        filtered.push(w)
      }
    }
    for (let i = 0; i < filtered.length; i++) {
      for (let j = i + 1; j < filtered.length; j++) {
        if (filtered[j].timestamp > filtered[i].timestamp) {
          const tmp = filtered[i]
          filtered[i] = filtered[j]
          filtered[j] = tmp
        }
      }
    }
    return filtered
  }

  private openPlan(): void {
    this.hideBar()
    this.showPlan = true
  }

  private closePlan(): void {
    this.showPlan = false
    this.showBarIfIdle()
  }

  private openAtlas(): void {
    this.hideBar()
    this.showAtlas = true
  }

  private closeAtlas(): void {
    this.showAtlas = false
    this.showBarIfIdle()
  }

  private openAction(id: string): void {
    this.actionId = id
    this.hideBar()
  }

  private closeAction(): void {
    this.actionId = ''
    this.showBarIfIdle()
  }

  private async openDay(dateKey: string): Promise<void> {
    if (dateKey.length < 8) {
      return
    }
    this.dayItems = await WorkoutStore.workoutsForDate(dateKey)
    this.dayListKey = dateKey
    this.hideBar()
  }

  private closeDay(): void {
    this.dayListKey = ''
    this.dayItems = []
    this.showBarIfIdle()
  }

  private async openDetail(id: string): Promise<void> {
    const rec = await WorkoutStore.findById(id)
    if (rec === undefined) {
      return
    }
    this.detailRecord = rec
    this.hideBar()
  }

  private closeDetail(): void {
    this.detailRecord = undefined
    this.showBarIfIdle()
  }

  private openEditFromDetail(): void {
    if (this.detailRecord === undefined) {
      return
    }
    const id = this.detailRecord.id
    const dateKey = this.detailRecord.dateKey
    this.detailRecord = undefined
    this.openRecord(id, dateKey)
  }

  private showGlobalToast(msg: string): void {
    this.globalToast = msg
    setTimeout((): void => { this.globalToast = '' }, 2800)
  }

  private async handleSave(rec: WorkoutRecord): Promise<void> {
    await WorkoutStore.saveWorkout(rec)
    await TemplateStore.rememberFromRecord(rec)
    await TrainingStore.ensureCheckin(rec.dateKey)
    await AchievementService.evaluateAndUnlock()
    await FitDataNotify.syncStats()
    this.refreshToken++
    this.closeRecord()
    if (this.dayListKey.length > 0) {
      this.dayItems = await WorkoutStore.workoutsForDate(this.dayListKey)
    }
    if (this.showHistory) {
      this.historyItems = await MainTabPage.sortHistory(await WorkoutStore.loadAll(), this.historyFilter)
    }
    const list = await WorkoutStore.loadAll()
    const streak = await StatsService.streakDays()
    this.showGlobalToast(`已保存 · 累计 ${list.length} 次 · 连续 ${streak} 天`)
  }

  private async handlePlanSaved(): Promise<void> {
    await AchievementService.evaluateAndUnlock()
    await FitDataNotify.syncStats()
    this.refreshToken++
    this.closePlan()
    this.showGlobalToast('周训计划已保存')
  }

  private async handleDelete(): Promise<void> {
    if (this.detailRecord !== undefined) {
      await WorkoutStore.deleteWorkout(this.detailRecord.id)
    }
    await FitDataNotify.syncStats()
    this.refreshToken++
    this.closeDetail()
    if (this.dayListKey.length > 0) {
      this.dayItems = await WorkoutStore.workoutsForDate(this.dayListKey)
    }
    if (this.showHistory) {
      this.historyItems = await MainTabPage.sortHistory(await WorkoutStore.loadAll(), this.historyFilter)
    }
    this.showGlobalToast('记录已删除')
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 4 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(44)
      .height(26)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : Color.Transparent)
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(10)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Regular)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      if (t.index === 0 || t.index === 4) {
        void FitDataNotify.syncStats()
        this.refreshToken++
      }
    })
  }
}
