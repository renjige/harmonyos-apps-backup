import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { TripsPage } from './TripsPage'
import { PreparePage } from './PreparePage'
import { GuidePage } from './GuidePage'
import { MinePage } from './MinePage'
import { AuthService } from '../services/AuthService'
import { TravelService } from '../services/TravelService'
import { CreateNoteRequest, TravelEditSeed, TravelTemplate, TravelTip, TripItem, ChecklistItem, ReminderItem, NoteItem, ItineraryItem } from '../models/TravelModels'
import { TripDetailOverlay } from '../components/travel/TripDetailOverlay'
import { TravelFormMode, TravelFormOverlay } from '../components/travel/TravelFormOverlay'
import { TemplateDetailOverlay } from '../components/travel/TemplateDetailOverlay'
import { TipDetailOverlay } from '../components/travel/TipDetailOverlay'
import { SearchOverlay } from '../components/travel/SearchOverlay'
import { GrowthHubOverlay } from '../components/travel/GrowthHubOverlay'
import { TravelGrowthService } from '../services/TravelGrowthService'
import {
  AchievementItem,
  ActivityEvent,
  SearchResultItem,
  TravelFavorite,
  TravelStatsSnapshot,
  TripRecapItem
} from '../models/TravelGrowthModels'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem(); t0.index = 0; t0.name = 'home'; t0.label = '首页'; tabs.push(t0)
    const t1 = new TabItem(); t1.index = 1; t1.name = 'biz'; t1.label = '行程'; tabs.push(t1)
    const t2 = new TabItem(); t2.index = 2; t2.name = 'check'; t2.label = '准备'; tabs.push(t2)
    const t3 = new TabItem(); t3.index = 3; t3.name = 'chart'; t3.label = '攻略'; tabs.push(t3)
    const t4 = new TabItem(); t4.index = 4; t4.name = 'user'; t4.label = '我的'; tabs.push(t4)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showDetail: boolean = false
  @State showForm: boolean = false
  @State showTemplate: boolean = false
  @State showTip: boolean = false
  @State showSearch: boolean = false
  @State showGrowth: boolean = false
  @State growthSegment: string = 'stats'
  @State searchResults: SearchResultItem[] = []
  @State growthStats: TravelStatsSnapshot = new TravelStatsSnapshot()
  @State growthAchievements: AchievementItem[] = []
  @State growthFavorites: TravelFavorite[] = []
  @State growthRecaps: TripRecapItem[] = []
  @State growthActivities: ActivityEvent[] = []
  @State templateFavorited: boolean = false
  @State tipFavorited: boolean = false
  @State formMode: TravelFormMode = 'trip'
  @State editId: string = ''
  @State editSeed: TravelEditSeed = new TravelEditSeed()
  @State dataEpoch: number = 0
  @State selectedTrip: TripItem = new TripItem()
  @State selectedTemplate: TravelTemplate = new TravelTemplate()
  @State selectedTip: TravelTip = new TravelTip()
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop appName: string = '出行备忘'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bump(): void {
    this.dataEpoch += 1
  }

  private restoreBar(): void {
    AppStorage.setOrCreate('tabBarHidden',
      this.showDetail || this.showTemplate || this.showTip || this.showSearch || this.showGrowth)
  }

  private async refreshGrowth(): Promise<void> {
    const trips = await TravelService.trips()
    const checklist = await TravelService.checklistItems()
    const notes = await TravelService.notes()
    const reminders = await TravelService.reminders()
    const enriched = TravelService.attachProgress(trips, checklist)
    this.growthFavorites = await TravelGrowthService.listFavorites()
    const streak = AuthService.isLoggedIn() ? await TravelGrowthService.prepStreakDays() : 0
    this.growthStats = TravelGrowthService.computeStats(
      enriched, checklist, this.growthFavorites, streak, notes, reminders
    )
    this.growthAchievements = TravelGrowthService.evaluateAchievements(this.growthStats, streak)
    this.growthRecaps = await TravelGrowthService.buildRecaps(enriched, checklist)
    this.growthActivities = TravelGrowthService.buildActivities(enriched, checklist, notes, this.growthFavorites)
  }

  private openSearch(): void {
    void this.refreshGrowth()
    this.searchResults = []
    this.showSearch = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openGrowth(segment: string): void {
    this.growthSegment = segment
    void this.refreshGrowth().then(() => {
      this.showGrowth = true
      AppStorage.setOrCreate('tabBarHidden', true)
    })
  }

  private async runSearch(keyword: string): Promise<void> {
    const trips = await TravelService.trips()
    const checklist = await TravelService.checklistItems()
    const notes = await TravelService.notes()
    const templates = await TravelService.templates()
    const tips = await TravelService.tips()
    this.searchResults = TravelGrowthService.searchAll(keyword, trips, checklist, notes, templates, tips)
  }

  private async handleSearchPick(item: SearchResultItem): Promise<void> {
    this.showSearch = false
    if (item.entityType === 'trip') {
      const trips = await TravelService.trips()
      for (const trip of trips) {
        if (trip.id === item.id) {
          this.openTrip(trip)
          return
        }
      }
    }
    if (item.entityType === 'template') {
      const templates = await TravelService.templates()
      for (const row of templates) {
        if (row.id === item.id) {
          this.selectedTemplate = row
          this.showTemplate = true
          void this.syncTemplateFavorite()
          AppStorage.setOrCreate('tabBarHidden', true)
          return
        }
      }
    }
    if (item.entityType === 'tip') {
      const tips = await TravelService.tips()
      for (const row of tips) {
        if (row.id === item.id) {
          this.selectedTip = row
          this.showTip = true
          void this.syncTipFavorite()
          AppStorage.setOrCreate('tabBarHidden', true)
          return
        }
      }
    }
    if (item.entityType === 'checklist' || item.entityType === 'note') {
      this.current = 2
    }
    this.restoreBar()
  }

  private async syncTemplateFavorite(): Promise<void> {
    this.templateFavorited = await TravelGrowthService.isFavorite('template', this.selectedTemplate.id)
  }

  private async syncTipFavorite(): Promise<void> {
    this.tipFavorited = await TravelGrowthService.isFavorite('tip', this.selectedTip.id)
  }

  private async toggleTemplateFavorite(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.onOpenLogin()
      return
    }
    const added = await TravelGrowthService.toggleFavorite(
      'template', this.selectedTemplate.id, this.selectedTemplate.title
    )
    this.templateFavorited = added
    this.bump()
    this.showToast(added ? '已加入收藏' : '已取消收藏')
  }

  private async toggleTipFavorite(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.onOpenLogin()
      return
    }
    const added = await TravelGrowthService.toggleFavorite('tip', this.selectedTip.id, this.selectedTip.title)
    this.tipFavorited = added
    this.bump()
    this.showToast(added ? '已加入收藏' : '已取消收藏')
  }

  private openTrip(trip: TripItem): void {
    this.selectedTrip = trip
    this.showDetail = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openForm(mode: TravelFormMode, keepTrip: boolean = false): void {
    if (!AuthService.isLoggedIn()) {
      this.onOpenLogin()
      return
    }
    if (!keepTrip) {
      this.selectedTrip = new TripItem()
    }
    this.editId = ''
    this.editSeed = new TravelEditSeed()
    this.formMode = mode
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openEdit(mode: TravelFormMode, seed: TravelEditSeed, trip: TripItem = new TripItem()): void {
    if (!AuthService.isLoggedIn()) {
      this.onOpenLogin()
      return
    }
    if (trip.id.length > 0) {
      this.selectedTrip = trip
    }
    this.editId = seed.id
    this.editSeed = seed
    this.formMode = mode
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private seedFromTrip(trip: TripItem): TravelEditSeed {
    const seed = new TravelEditSeed()
    seed.id = trip.id
    seed.title = trip.title
    seed.destination = trip.destination
    seed.startDate = trip.startDate
    seed.endDate = trip.endDate
    seed.detail = trip.summary
    return seed
  }

  private seedFromChecklist(item: ChecklistItem): TravelEditSeed {
    const seed = new TravelEditSeed()
    seed.id = item.id
    seed.title = item.title
    seed.category = item.category
    seed.tripId = item.tripId
    return seed
  }

  private seedFromReminder(item: ReminderItem): TravelEditSeed {
    const seed = new TravelEditSeed()
    seed.id = item.id
    seed.title = item.title
    seed.reminderType = item.reminderType
    seed.remindAt = item.remindAt
    seed.detail = item.note
    seed.tripId = item.tripId
    return seed
  }

  private seedFromNote(item: NoteItem): TravelEditSeed {
    const seed = new TravelEditSeed()
    seed.id = item.id
    seed.title = item.title
    seed.detail = item.body
    seed.tripId = item.tripId
    return seed
  }

  private seedFromItinerary(item: ItineraryItem): TravelEditSeed {
    const seed = new TravelEditSeed()
    seed.id = item.id
    seed.title = item.title
    seed.startDate = item.itemDate
    seed.startTime = item.startTime
    seed.destination = item.location
    seed.detail = item.note
    seed.tripId = item.tripId
    return seed
  }

  private confirmDeleteTrip(trip: TripItem): void {
    AlertDialog.show({
      title: '删除行程',
      message: `确定删除「${trip.title}」？关联安排不会自动恢复。`,
      primaryButton: {
        value: '删除',
        action: (): void => { void this.deleteTrip(trip.id) }
      },
      secondaryButton: { value: '取消', action: (): void => {} }
    })
  }

  private async deleteTrip(id: string): Promise<void> {
    const ok = await TravelService.deleteTrip(id)
    this.bump()
    this.showToast(ok ? '行程已删除' : '删除失败，请稍后重试')
    if (this.showDetail && this.selectedTrip.id === id) {
      this.showDetail = false
      this.restoreBar()
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async applyTemplate(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.showTemplate = false
      this.onOpenLogin()
      return
    }
    const ok = await TravelService.applyTemplate(this.selectedTemplate)
    this.showTemplate = false
    this.restoreBar()
    this.bump()
    this.showToast(ok ? '已生成行程、安排、清单与出发提醒' : '创建失败，请稍后重试')
  }

  private async saveTipNote(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.showTip = false
      this.onOpenLogin()
      return
    }
    const body = new CreateNoteRequest()
    body.title = this.selectedTip.title
    body.body = this.selectedTip.body.length > 0 ? this.selectedTip.body : this.selectedTip.summary
    const ok = await TravelService.createNote(body)
    this.showTip = false
    this.restoreBar()
    this.bump()
    this.showToast(ok ? '已记入旅途备忘' : '保存失败，请稍后重试')
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            dataEpoch: this.dataEpoch,
            onOpenTrip: (trip: TripItem) => this.openTrip(trip),
            onCreateTrip: () => this.openForm('trip'),
            onOpenTrips: () => { this.current = 1 },
            onOpenPrepare: () => { this.current = 2 },
            onOpenGuide: () => { this.current = 3 },
            onOpenSearch: () => this.openSearch(),
            onOpenGrowth: (segment: string) => this.openGrowth(segment),
            onRequireAuth: () => this.onOpenLogin(),
            onToast: (message: string) => this.showToast(message),
            onOpenTemplate: (item: TravelTemplate) => {
              this.selectedTemplate = item
              this.showTemplate = true
              void this.syncTemplateFavorite()
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenTip: (item: TravelTip) => {
              this.selectedTip = item
              this.showTip = true
              void this.syncTipFavorite()
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          TripsPage({
            dataEpoch: this.dataEpoch,
            onOpenTrip: (trip: TripItem) => this.openTrip(trip),
            onCreateTrip: () => this.openForm('trip'),
            onEditTrip: (trip: TripItem) => this.openEdit('trip', this.seedFromTrip(trip), trip),
            onDeleteTrip: (trip: TripItem) => this.confirmDeleteTrip(trip)
          }).layoutWeight(1)
        } else if (this.current === 2) {
          PreparePage({
            dataEpoch: this.dataEpoch,
            onCreateChecklist: () => this.openForm('checklist'),
            onCreateReminder: () => this.openForm('reminder'),
            onCreateNote: () => this.openForm('note'),
            onRequireAuth: () => this.onOpenLogin(),
            onChanged: () => this.bump(),
            onEditChecklist: (item: ChecklistItem) => this.openEdit('checklist', this.seedFromChecklist(item)),
            onEditReminder: (item: ReminderItem) => this.openEdit('reminder', this.seedFromReminder(item)),
            onEditNote: (item: NoteItem) => this.openEdit('note', this.seedFromNote(item)),
            onDeleteReminder: (item: ReminderItem) => { void this.deleteReminder(item) },
            onDeleteNote: (item: NoteItem) => { void this.deleteNote(item) }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          GuidePage({
            dataEpoch: this.dataEpoch,
            onOpenSearch: () => this.openSearch(),
            onOpenTemplate: (item: TravelTemplate) => {
              this.selectedTemplate = item
              this.showTemplate = true
              void this.syncTemplateFavorite()
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenTip: (item: TravelTip) => {
              this.selectedTip = item
              this.showTip = true
              void this.syncTipFavorite()
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            dataEpoch: this.dataEpoch,
            onOpenLogin: () => this.onOpenLogin(),
            onOpenTrips: () => { this.current = 1 },
            onOpenPrepare: () => { this.current = 2 },
            onOpenGuide: () => { this.current = 3 },
            onOpenSearch: () => this.openSearch(),
            onOpenGrowth: (segment: string) => this.openGrowth(segment),
            onLogout: () => { this.onLogout() }
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(10,37,64,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showDetail) {
        TripDetailOverlay({
          trip: this.selectedTrip,
          dataEpoch: this.dataEpoch,
          onClose: () => { this.showDetail = false; this.restoreBar() },
          onCreateItinerary: () => this.openForm('itinerary', true),
          onCreateReminder: () => this.openForm('reminder', true),
          onImportChecklist: () => { void this.importForTrip() },
          onEditTrip: (trip: TripItem) => {
            this.selectedTrip = trip
            this.openEdit('trip', this.seedFromTrip(trip), trip)
          },
          onEditItinerary: (item: ItineraryItem) => this.openEdit('itinerary', this.seedFromItinerary(item), this.selectedTrip),
          onDeleteItinerary: (id: string) => { void this.deleteItinerary(id) }
        })
        .width('100%').height('100%').zIndex(10)
      }
      if (this.showTemplate) {
        TemplateDetailOverlay({
          template: this.selectedTemplate,
          favorited: this.templateFavorited,
          onClose: () => { this.showTemplate = false; this.restoreBar() },
          onApply: () => { void this.applyTemplate() },
          onToggleFavorite: (): void => { void this.toggleTemplateFavorite() }
        })
        .width('100%').height('100%').zIndex(12)
      }
      if (this.showTip) {
        TipDetailOverlay({
          tip: this.selectedTip,
          favorited: this.tipFavorited,
          onClose: () => { this.showTip = false; this.restoreBar() },
          onSaveNote: () => { void this.saveTipNote() },
          onToggleFavorite: (): void => { void this.toggleTipFavorite() }
        })
        .width('100%').height('100%').zIndex(12)
      }
      if (this.showForm) {
        TravelFormOverlay({
          mode: this.formMode,
          tripId: this.selectedTrip.id,
          editId: this.editId,
          editSeed: this.editSeed,
          onClose: () => {
            this.showForm = false
            this.editId = ''
            this.editSeed = new TravelEditSeed()
            this.restoreBar()
          },
          onSaved: (message: string) => {
            this.showForm = false
            this.editId = ''
            this.editSeed = new TravelEditSeed()
            this.restoreBar()
            this.bump()
            this.showToast(message)
          }
        })
        .width('100%').height('100%').zIndex(15)
      }
      if (this.showSearch) {
        SearchOverlay({
          results: this.searchResults,
          onClose: () => { this.showSearch = false; this.restoreBar() },
          onSearch: (keyword: string): void => { void this.runSearch(keyword) },
          onPick: (item: SearchResultItem): void => { void this.handleSearchPick(item) }
        })
        .width('100%').height('100%').zIndex(18)
      }
      if (this.showGrowth) {
        GrowthHubOverlay({
          segment: this.growthSegment,
          stats: this.growthStats,
          achievements: this.growthAchievements,
          favorites: this.growthFavorites,
          activities: this.growthActivities,
          recaps: this.growthRecaps,
          onClose: () => { this.showGrowth = false; this.restoreBar() },
          onSegment: (seg: string) => { this.growthSegment = seg }
        })
        .width('100%').height('100%').zIndex(18)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: Theme.space.pageX, y: Theme.space.s6 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  private async importForTrip(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.onOpenLogin()
      return
    }
    const count = await TravelService.importPresets(this.selectedTrip.id)
    this.bump()
    this.showToast(count > 0 ? `已导入 ${count} 项出行清单` : '清单模板已在清单中')
  }

  private async deleteItinerary(id: string): Promise<void> {
    const ok = await TravelService.deleteItinerary(id)
    this.bump()
    this.showToast(ok ? '安排已删除' : '删除失败，请稍后重试')
  }

  private async deleteReminder(item: ReminderItem): Promise<void> {
    const ok = await TravelService.deleteReminder(item.id)
    this.bump()
    this.showToast(ok ? '提醒已删除' : '删除失败，请稍后重试')
  }

  private async deleteNote(item: NoteItem): Promise<void> {
    const ok = await TravelService.deleteNote(item.id)
    this.bump()
    this.showToast(ok ? '备忘已删除' : '删除失败，请稍后重试')
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
