import { common } from '@kit.AbilityKit'
import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { AppointmentsPage } from './AppointmentsPage'
import { CalendarPage } from './CalendarPage'
import { PlanPage } from './PlanPage'
import { GrowthPage } from './GrowthPage'
import { MinePage } from './MinePage'
import { OnboardingOverlay } from '../components/appointment/OnboardingOverlay'
import { AppointmentFormOverlay } from '../components/appointment/AppointmentFormOverlay'
import { AppointmentDetailOverlay } from '../components/appointment/AppointmentDetailOverlay'
import { TemplateDetailOverlay } from '../components/appointment/TemplateDetailOverlay'
import { InsightsOverlay } from '../components/appointment/InsightsOverlay'
import { SceneHubOverlay } from '../components/appointment/SceneHubOverlay'
import { DailyBriefOverlay } from '../components/appointment/DailyBriefOverlay'
import { SlotFinderOverlay } from '../components/appointment/SlotFinderOverlay'
import { OverdueDeskOverlay } from '../components/appointment/OverdueDeskOverlay'
import { ImportPasteOverlay } from '../components/appointment/ImportPasteOverlay'
import { PlanFormOverlay } from '../components/growth/PlanFormOverlay'
import { PlanDetailOverlay } from '../components/growth/PlanDetailOverlay'
import { SearchHubOverlay } from '../components/growth/SearchHubOverlay'
import { ExtraOverlays } from '../components/appointment/ExtraOverlays'
import { MessagesPage } from './MessagesPage'
import {
  AppointmentFormDraft,
  AppointmentItem,
  AppointmentTemplate,
  WeekDigest,
  MonthInsights,
  FreeSlot,
  ImportPreview
} from '../models/AppointmentModels'
import { CommitmentPlan, PlanFormDraft } from '../models/GrowthModels'
import { AppointmentService } from '../services/AppointmentService'
import { GrowthService } from '../services/GrowthService'
import { AppointmentLocalStore } from '../services/AppointmentLocalStore'
import { ScheduleEngine } from '../services/ScheduleEngine'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem(); t0.index = 0; t0.name = 'home'; t0.label = '首页'; tabs.push(t0)
    const t1 = new TabItem(); t1.index = 1; t1.name = 'biz'; t1.label = '约定'; tabs.push(t1)
    const t2 = new TabItem(); t2.index = 2; t2.name = 'check'; t2.label = '计划'; tabs.push(t2)
    const t3 = new TabItem(); t3.index = 3; t3.name = 'chart'; t3.label = '成长'; tabs.push(t3)
    const t4 = new TabItem(); t4.index = 4; t4.name = 'user'; t4.label = '我的'; tabs.push(t4)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showOnboard: boolean = false
  @State showForm: boolean = false
  @State showDetail: boolean = false
  @State showTemplate: boolean = false
  @State showRhythm: boolean = false
  @State showReview: boolean = false
  @State showPostpone: boolean = false
  @State showInsights: boolean = false
  @State showSceneHub: boolean = false
  @State sceneHubKey: string = 'work'
  @State hubItems: AppointmentItem[] = []
  @State hubTemplates: AppointmentTemplate[] = []
  @State monthInsights: MonthInsights = new MonthInsights()
  @State showBrief: boolean = false
  @State showSlots: boolean = false
  @State showOverdue: boolean = false
  @State showImport: boolean = false
  @State showCalendar: boolean = false
  @State showPlanForm: boolean = false
  @State showPlanDetail: boolean = false
  @State showSearch: boolean = false
  @State planDraft: PlanFormDraft = new PlanFormDraft()
  @State planIsEdit: boolean = false
  @State activePlan: CommitmentPlan = new CommitmentPlan()
  @State linkedPlanId: string = ''
  @State briefItems: AppointmentItem[] = []
  @State missedItems: AppointmentItem[] = []
  @State slotList: FreeSlot[] = []
  @State slotDuration: number = 60
  @State missedCount: number = 0
  @State showMessages: boolean = false
  @State formDraft: AppointmentFormDraft = new AppointmentFormDraft()
  @State formIsEdit: boolean = false
  @State activeItem: AppointmentItem = new AppointmentItem()
  @State activeTemplate: AppointmentTemplate = new AppointmentTemplate()
  @State weekDigest: WeekDigest = new WeekDigest()
  @State toastText: string = ''
  @State refreshTick: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('onboardingDone') onboardingDone: boolean = false
  @Prop company: string = '魏文波'
  @Prop appName: string = '约定提醒'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.showOnboard = !this.onboardingDone
  }

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private toast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private bump(): void {
    this.refreshTick += 1
  }

  private ctx(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext
  }

  private async openItem(id: string): Promise<void> {
    const row = await AppointmentService.findById(id)
    if (row === undefined) {
      this.toast('约定不存在或已删除')
      return
    }
    this.activeItem = row
    this.showDetail = true
    this.hideBar(true)
  }

  private openEditFromDetail(): void {
    this.formDraft = AppointmentService.draftFromItem(this.activeItem)
    this.formIsEdit = true
    this.showDetail = false
    this.showForm = true
  }

  private copyText(text: string): void {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
    } catch {
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.refreshTick,
            appName: this.appName,
            tagline: this.tagline,
            onCreate: (): void => { this.openCreateAt('', '') },
            onOpenItem: (id: string): void => { void this.openItem(id) },
            onOpenList: (): void => { this.current = 1 },
            onOpenCalendar: (): void => { this.showCalendar = true; this.hideBar(true) },
            onOpenTemplate: (tpl: AppointmentTemplate): void => {
              this.activeTemplate = tpl
              this.showTemplate = true
              this.hideBar(true)
            },
            onOpenSceneHub: (scene: string): void => { void this.openSceneHub(scene) },
            onOpenBrief: (): void => { void this.openBrief() },
            onOpenSlots: (): void => { void this.openSlots(60) },
            onOpenOverdue: (): void => { void this.openOverdue() },
            onOpenImport: (): void => { this.showImport = true; this.hideBar(true) },
            onOpenPlans: (): void => { this.current = 2 },
            onOpenGrowth: (): void => { this.current = 3 },
            onOpenSearch: (): void => { this.showSearch = true; this.hideBar(true) },
            onOpenPlan: (id: string): void => { void this.openPlan(id) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          AppointmentsPage({
            refreshToken: this.refreshTick,
            onCreate: (): void => { this.openCreateAt('', '') },
            onOpenItem: (id: string): void => { void this.openItem(id) },
            onImport: (): void => { this.showImport = true; this.hideBar(true) },
            onOpenCalendar: (): void => { this.showCalendar = true; this.hideBar(true) },
            onOpenSearch: (): void => { this.showSearch = true; this.hideBar(true) }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          PlanPage({
            refreshToken: this.refreshTick,
            onCreate: (): void => { this.openPlanCreate() },
            onOpenPlan: (id: string): void => { void this.openPlan(id) }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          GrowthPage({
            refreshToken: this.refreshTick,
            onOpenInsights: (): void => { void this.openInsights() },
            onOpenReview: (): void => { void this.openReview() },
            onOpenRhythm: (): void => { this.showRhythm = true; this.hideBar(true) },
            onOpenItem: (id: string): void => { void this.openItem(id) }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.refreshTick,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => { this.onLogout() },
            onOpenRhythm: (): void => { this.showRhythm = true; this.hideBar(true) },
            onOpenReview: (): void => { void this.openReview() },
            onOpenInsights: (): void => { void this.openInsights() },
            onOpenBrief: (): void => { void this.openBrief() },
            onOpenSlots: (): void => { void this.openSlots(60) },
            onOpenOverdue: (): void => { void this.openOverdue() },
            onOpenImport: (): void => { this.showImport = true; this.hideBar(true) },
            onExportWeek: (): void => { void this.exportWeek() },
            onOpenMessages: (): void => { this.showMessages = true; this.hideBar(true) }
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => { this.TabBarItem(t) }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showOnboard) {
        OnboardingOverlay({
          onFinish: (): void => {
            void AppointmentLocalStore.setOnboardingDone().then(() => {
              this.showOnboard = false
            })
          }
        }).width('100%').height('100%').zIndex(24)
      }

      if (this.showForm) {
        AppointmentFormOverlay({
          draft: this.formDraft,
          isEdit: this.formIsEdit,
          onClose: (): void => { this.showForm = false; this.hideBar(false) },
          onSaved: (): void => {
            this.showForm = false
            this.hideBar(false)
            this.toast('约定已保存')
            this.bump()
          },
          onSubmit: async (draft: AppointmentFormDraft, ctx: common.UIAbilityContext): Promise<boolean> => {
            const saved = await AppointmentService.saveDraft(draft, ctx)
            if (saved === undefined) {
              this.toast(AppointmentService.lastError.length > 0 ?
                AppointmentService.lastError : '保存失败')
              return false
            }
            return true
          }
        }).width('100%').height('100%').zIndex(16)
      }

      if (this.showDetail) {
        AppointmentDetailOverlay({
          item: this.activeItem,
          onClose: (): void => { this.showDetail = false; this.hideBar(false); this.bump() },
          onComplete: async (id: string, ctx: common.UIAbilityContext, followUp: string): Promise<boolean> => {
            const ok = await AppointmentService.complete(id, ctx, followUp)
            this.toast(ok ? '已标记完成' : AppointmentService.lastError)
            if (ok) {
              this.bump()
            }
            return ok
          },
          onDelete: async (id: string): Promise<boolean> => {
            const ok = await AppointmentService.remove(id)
            this.toast(ok ? '约定已删除' : AppointmentService.lastError)
            if (ok) {
              this.bump()
            }
            return ok
          },
          onShare: (): void => { this.toast('已复制到剪贴板，可粘贴分享') },
          onEdit: (): void => { this.openEditFromDetail() },
          onPostpone: (): void => { this.showPostpone = true },
          onPin: (): void => { void this.togglePin() },
          onPrep: (index: number): void => { void this.togglePrep(index) },
          onReopen: (): void => { void this.reopenItem() },
          onDuplicate: (): void => { void this.duplicateActive() },
          onCheckIn: (): void => { void this.checkInActive() },
          onFavorite: (): void => { void this.favoriteActive() }
        }).width('100%').height('100%').zIndex(14)
      }

      if (this.showTemplate) {
        TemplateDetailOverlay({
          template: this.activeTemplate,
          onClose: (): void => { this.showTemplate = false; this.hideBar(false) },
          onCreateDraft: (draft: AppointmentFormDraft): void => {
            this.formDraft = draft
            this.formIsEdit = false
            this.showTemplate = false
            this.showForm = true
          }
        }).width('100%').height('100%').zIndex(16)
      }

      if (this.showInsights) {
        InsightsOverlay({
          insights: this.monthInsights,
          onClose: (): void => { this.showInsights = false; this.hideBar(false) }
        }).width('100%').height('100%').zIndex(17)
      }

      if (this.showSceneHub) {
        SceneHubOverlay({
          scene: this.sceneHubKey,
          items: this.hubItems,
          templates: this.hubTemplates,
          onClose: (): void => { this.showSceneHub = false; this.hideBar(false) },
          onSceneChange: (key: string): void => { this.sceneHubKey = key },
          onOpenItem: (id: string): void => {
            this.showSceneHub = false
            void this.openItem(id)
          },
          onOpenTemplate: (tpl: AppointmentTemplate): void => {
            this.activeTemplate = tpl
            this.showSceneHub = false
            this.showTemplate = true
          },
          onCreateScene: (scene: string): void => {
            const draft = new AppointmentFormDraft()
            draft.dueDate = AppointmentLocalStore.today()
            draft.dueTime = '09:00'
            draft.scene = scene
            draft.prepLine = ScheduleEngine.defaultPrep(scene)
            this.formDraft = draft
            this.formIsEdit = false
            this.showSceneHub = false
            this.showForm = true
          }
        }).width('100%').height('100%').zIndex(17)
      }

      if (this.showMessages) {
        MessagesPage({
          onClose: (): void => { this.showMessages = false; this.hideBar(false) }
        }).width('100%').height('100%').zIndex(16)
      }

      if (this.showBrief) {
        DailyBriefOverlay({
          items: this.briefItems,
          missedCount: this.missedCount,
          onClose: (): void => { this.showBrief = false; this.hideBar(false) },
          onOpenItem: (id: string): void => {
            this.showBrief = false
            void this.openItem(id)
          },
          onComplete: (id: string): void => { void this.quickComplete(id) },
          onCopied: (): void => { this.toast('今日简报已复制') }
        }).width('100%').height('100%').zIndex(17)
      }

      if (this.showSlots) {
        SlotFinderOverlay({
          slots: this.slotList,
          durationMin: this.slotDuration,
          onClose: (): void => { this.showSlots = false; this.hideBar(false) },
          onDuration: (mins: number): void => { void this.openSlots(mins) },
          onPick: (slot: FreeSlot): void => {
            this.showSlots = false
            this.openCreateAt(slot.date, slot.time)
          }
        }).width('100%').height('100%').zIndex(17)
      }

      if (this.showOverdue) {
        OverdueDeskOverlay({
          items: this.missedItems,
          onClose: (): void => { this.showOverdue = false; this.hideBar(false) },
          onOpenItem: (id: string): void => {
            this.showOverdue = false
            void this.openItem(id)
          },
          onPostponeAll: (): void => { void this.postponeMissed() },
          onComplete: (id: string): void => { void this.quickComplete(id) }
        }).width('100%').height('100%').zIndex(17)
      }

      if (this.showImport) {
        ImportPasteOverlay({
          onClose: (): void => { this.showImport = false; this.hideBar(false) },
          onCreateAll: (rows: ImportPreview[]): void => { void this.runImport(rows) }
        }).width('100%').height('100%').zIndex(17)
      }

      if (this.showCalendar) {
        CalendarPage({
          refreshToken: this.refreshTick,
          overlayMode: true,
          onOpenItem: (id: string): void => {
            this.showCalendar = false
            void this.openItem(id)
          },
          onCreateForDate: (iso: string): void => {
            this.showCalendar = false
            this.hideBar(false)
            this.openCreateAt(iso, '09:00')
          },
          onClose: (): void => { this.showCalendar = false; this.hideBar(false) }
        }).width('100%').height('100%').zIndex(17)
      }

      if (this.showSearch) {
        SearchHubOverlay({
          onClose: (): void => { this.showSearch = false; this.hideBar(false) },
          onOpenAppointment: (id: string): void => {
            this.showSearch = false
            void this.openItem(id)
          },
          onOpenPlan: (id: string): void => {
            this.showSearch = false
            void this.openPlan(id)
          }
        }).width('100%').height('100%').zIndex(17)
      }

      if (this.showPlanForm) {
        PlanFormOverlay({
          draft: this.planDraft,
          isEdit: this.planIsEdit,
          onClose: (): void => { this.showPlanForm = false; this.hideBar(false) },
          onSaved: (): void => {
            this.showPlanForm = false
            this.hideBar(false)
            this.toast('计划已保存')
            this.bump()
          },
          onSubmit: async (draft: PlanFormDraft): Promise<boolean> => {
            const saved = await GrowthService.savePlanDraft(draft)
            return saved !== undefined
          }
        }).width('100%').height('100%').zIndex(16)
      }

      if (this.showPlanDetail) {
        PlanDetailOverlay({
          plan: this.activePlan,
          onClose: (): void => { this.showPlanDetail = false; this.hideBar(false) },
          onEdit: (): void => { this.openPlanEdit() },
          onDelete: async (id: string): Promise<boolean> => {
            const ok = await GrowthService.removePlan(id)
            if (ok) {
              this.toast('计划已删除')
              this.bump()
            }
            return ok
          },
          onCreateLinked: (): void => {
            this.linkedPlanId = this.activePlan.id
            this.showPlanDetail = false
            const draft = new AppointmentFormDraft()
            draft.dueDate = AppointmentLocalStore.today()
            draft.dueTime = '09:00'
            draft.planId = this.activePlan.id
            draft.scene = this.activePlan.scene.length > 0 ? this.activePlan.scene : 'life'
            this.formDraft = draft
            this.formIsEdit = false
            this.showForm = true
          }
        }).width('100%').height('100%').zIndex(15)
      }

      if (this.showRhythm || this.showReview || this.showPostpone) {
        ExtraOverlays({
          showRhythm: this.showRhythm,
          showReview: this.showReview,
          showPostpone: this.showPostpone,
          digest: this.weekDigest,
          postponeItem: this.activeItem,
          onCloseRhythm: (): void => { this.showRhythm = false; this.hideBar(false) },
          onApplyRhythm: (category: string): void => { void this.applyRhythm(category) },
          onCloseReview: (): void => { this.showReview = false; this.hideBar(false) },
          onExport: (): void => { void this.exportWeek() },
          onHandleMissed: (): void => {
            this.showReview = false
            this.current = 1
            this.hideBar(false)
          },
          onClosePostpone: (): void => { this.showPostpone = false },
          onPickPostpone: (minutes: number): void => { void this.applyPostpone(minutes) }
        }).width('100%').height('100%').zIndex(18)
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

  private openCreateAt(date: string, time: string): void {
    const draft = new AppointmentFormDraft()
    draft.dueDate = date.length > 0 ? date : AppointmentLocalStore.today()
    draft.dueTime = time.length > 0 ? time : '09:00'
    if (this.linkedPlanId.length > 0) {
      draft.planId = this.linkedPlanId
      this.linkedPlanId = ''
    }
    this.formDraft = draft
    this.formIsEdit = false
    this.showForm = true
    this.hideBar(true)
  }

  private openPlanCreate(): void {
    this.planDraft = new PlanFormDraft()
    this.planIsEdit = false
    this.showPlanForm = true
    this.hideBar(true)
  }

  private openPlanEdit(): void {
    this.planDraft = GrowthService.draftFromPlan(this.activePlan)
    this.planIsEdit = true
    this.showPlanDetail = false
    this.showPlanForm = true
  }

  private async openPlan(id: string): Promise<void> {
    const plan = await GrowthService.findPlan(id)
    if (plan === undefined) {
      this.toast('计划不存在')
      return
    }
    this.activePlan = plan
    this.showPlanDetail = true
    this.hideBar(true)
  }

  private async favoriteActive(): Promise<void> {
    const ok = await AppointmentService.toggleFavorite(this.activeItem.id, this.ctx())
    if (ok) {
      const row = await AppointmentService.findById(this.activeItem.id)
      if (row !== undefined) {
        this.activeItem = row
      }
      this.toast(this.activeItem.favorite ? '已加入收藏' : '已取消收藏')
      this.bump()
    }
  }

  private async openReview(): Promise<void> {
    this.weekDigest = await AppointmentService.weekDigest()
    this.showReview = true
    this.hideBar(true)
  }

  private async openInsights(): Promise<void> {
    this.monthInsights = await AppointmentService.monthInsights()
    this.showInsights = true
    this.hideBar(true)
  }

  private async openSceneHub(scene: string): Promise<void> {
    this.sceneHubKey = scene
    this.hubItems = await AppointmentService.listAll()
    this.hubTemplates = await AppointmentService.templates()
    this.showSceneHub = true
    this.hideBar(true)
  }

  private async openBrief(): Promise<void> {
    this.briefItems = await AppointmentService.listToday()
    this.missedItems = await AppointmentService.listMissed()
    this.missedCount = this.missedItems.length
    this.showBrief = true
    this.hideBar(true)
  }

  private async openSlots(duration: number): Promise<void> {
    this.slotDuration = duration
    this.slotList = await AppointmentService.weekSlots(duration)
    this.showSlots = true
    this.hideBar(true)
  }

  private async openOverdue(): Promise<void> {
    this.missedItems = await AppointmentService.listMissed()
    this.showOverdue = true
    this.hideBar(true)
  }

  private async quickComplete(id: string): Promise<void> {
    const ok = await AppointmentService.complete(id, this.ctx(), '')
    this.toast(ok ? '已标记完成' : AppointmentService.lastError)
    this.briefItems = await AppointmentService.listToday()
    this.missedItems = await AppointmentService.listMissed()
    this.missedCount = this.missedItems.length
    this.bump()
  }

  private async postponeMissed(): Promise<void> {
    const n = await AppointmentService.postponeAllMissed(this.ctx())
    this.toast(`已将 ${n} 件改到明天`)
    this.missedItems = await AppointmentService.listMissed()
    this.bump()
  }

  private async runImport(rows: ImportPreview[]): Promise<void> {
    const n = await AppointmentService.importPreviews(rows, this.ctx())
    this.showImport = false
    this.hideBar(false)
    this.toast(`已导入 ${n} 件约定`)
    this.bump()
  }

  private async duplicateActive(): Promise<void> {
    const row = await AppointmentService.duplicateTomorrow(this.activeItem.id, this.ctx())
    if (row !== undefined) {
      this.toast('已再约到明天同时段')
      this.bump()
      this.activeItem = row
    } else {
      this.toast(AppointmentService.lastError)
    }
  }

  private async checkInActive(): Promise<void> {
    const ok = await AppointmentService.toggleCheckIn(this.activeItem.id, this.ctx())
    if (ok) {
      const row = await AppointmentService.findById(this.activeItem.id)
      if (row !== undefined) {
        this.activeItem = row
      }
      this.toast(this.activeItem.checkedIn ? '已到达打卡' : '已取消打卡')
    }
  }

  private async exportWeek(): Promise<void> {
    const all = await AppointmentService.listAll()
    this.copyText(ScheduleEngine.exportWeek(all))
    this.toast('本周安排已复制')
  }

  private async applyRhythm(category: string): Promise<void> {
    const row = await AppointmentService.createFromRhythm(category, this.ctx())
    this.showRhythm = false
    if (row !== undefined) {
      this.toast('已按整理建议创建约定')
      this.bump()
      void this.openItem(row.id)
    } else {
      this.toast(AppointmentService.lastError)
      this.hideBar(false)
    }
  }

  private async applyPostpone(minutes: number): Promise<void> {
    const ok = await AppointmentService.postpone(this.activeItem.id, minutes, this.ctx())
    this.showPostpone = false
    if (ok) {
      const row = await AppointmentService.findById(this.activeItem.id)
      if (row !== undefined) {
        this.activeItem = row
      }
      this.toast('已改期')
      this.bump()
    } else {
      this.toast(AppointmentService.lastError)
    }
  }

  private async togglePin(): Promise<void> {
    const ok = await AppointmentService.togglePin(this.activeItem.id, this.ctx())
    if (ok) {
      const row = await AppointmentService.findById(this.activeItem.id)
      if (row !== undefined) {
        this.activeItem = row
      }
      this.bump()
    }
  }

  private async togglePrep(index: number): Promise<void> {
    const row = await AppointmentService.togglePrep(this.activeItem.id, index, this.ctx())
    if (row !== undefined) {
      this.activeItem = row
    }
  }

  private async reopenItem(): Promise<void> {
    const ok = await AppointmentService.reopen(this.activeItem.id, this.ctx())
    if (ok) {
      const row = await AppointmentService.findById(this.activeItem.id)
      if (row !== undefined) {
        this.activeItem = row
      }
      this.toast('已重新打开')
      this.bump()
    }
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
    .onClick((): void => {
      this.hideBar(false)
      this.current = t.index
    })
  }
}
