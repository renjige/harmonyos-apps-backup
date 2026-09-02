import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { TodayHeroSection } from '../components/vitality/TodayHeroSection'
import { VitalityScoreBadge } from '../components/vitality/VitalityScoreBadge'
import { DimensionSummaryChips } from '../components/vitality/DimensionSummaryChips'
import { WeeklyGoalBar, BreathingGuideOverlay, VitalityInsightsCard } from '../components/vitality/VitalityExtras'
import { QuickActionRow, RecentTimelineStrip, ProgressHeroCard, CheckInCalendarStrip, WorkbenchStatGrid } from '../components/vitality/WorkbenchComponents'
import { CheckInSheet } from '../components/vitality/CheckInSheet'
import { DayDetailOverlay } from '../components/vitality/DayDetailOverlay'
import { NoteDetailOverlay } from '../components/vitality/NoteDetailOverlay'
import { AchievementDetailOverlay } from '../components/vitality/AchievementDetailOverlay'
import {
  DimensionOption, MicroAction, TimelineEvent,
  UserProfile, VitalityNote, VitalityRecord, TodayProgress, AchievementProgress
} from '../models/VitalityModels'
import { DateHelper } from '../services/DateHelper'
import { VitalityStore } from '../services/VitalityStore'
import { StatsService, AchievementService } from '../services/StatsService'
import { QuoteService } from '../services/QuoteService'
import { PrescriptionService } from '../services/PrescriptionService'
import { TimelineService } from '../services/TimelineService'

@Component
export struct HomeDashboardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onChanged: () => void = () => {}
  onOpenJournal: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onOpenAction: () => void = () => {}
  onOpenSearch: () => void = () => {}
  @State profile: UserProfile = new UserProfile()
  @State todayRecord: VitalityRecord = new VitalityRecord()
  @State hasCheckedIn: boolean = false
  @State editing: boolean = false
  @State exerciseKey: string = ''
  @State moodKey: string = ''
  @State energyKey: string = ''
  @State noteText: string = ''
  @State streak: number = 0
  @State dailyQuote: string = ''
  @State toastText: string = ''
  @State dateLabel: string = ''
  @State actions: MicroAction[] = []
  @State pinned: boolean = false
  @State weekDone: number = 0
  @State weekGoal: number = 5
  @State actionRevision: number = 0
  @State showBreathing: boolean = false
  @State showCheckIn: boolean = false
  @State showNoteSheet: boolean = false
  @State noteTitle: string = ''
  @State noteBody: string = ''
  @State statTotal: number = 0
  @State statMonth: number = 0
  @State statRxPct: number = 0
  @State statFav: number = 0
  @State progressPercent: number = 0
  @State progressCheckedIn: boolean = false
  @State progressRxDone: number = 0
  @State progressRxTotal: number = 0
  @State dashboardEpoch: number = 0
  @State recentEvents: TimelineEvent[] = []
  @State insightText: string = ''
  @State todayProgress: TodayProgress = new TodayProgress()
  @State monthKeys: string[] = []
  @State checkedMonthKeys: string[] = []
  @State showDayDetail: boolean = false
  @State showNoteDetail: boolean = false
  @State showAchDetail: boolean = false
  @State detailRecord: VitalityRecord = new VitalityRecord()
  @State detailActions: MicroAction[] = []
  @State detailPinned: boolean = false
  @State detailNote: VitalityNote = new VitalityNote()
  @State achProgress: AchievementProgress = new AchievementProgress()

  aboutToAppear(): void {
    this.dateLabel = DateHelper.displayDate(DateHelper.todayKey())
    this.dailyQuote = QuoteService.dailyQuote()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async reload(): Promise<void> {
    await VitalityStore.refreshCacheFromDisk()
    this.profile = await VitalityStore.loadProfile()
    const today = DateHelper.todayKey()
    const rec = await VitalityStore.recordForDate(today)
    this.streak = await StatsService.streakDays()
    this.weekDone = await StatsService.weekCheckInCount()
    this.weekGoal = this.profile.weeklyGoalDays >= 1 ? this.profile.weeklyGoalDays : 5
    this.pinned = await VitalityStore.isPinned(today)
    const d = new Date()
    this.monthKeys = DateHelper.monthKeys(d.getFullYear(), d.getMonth() + 1)
    const monthStart = this.monthKeys.length > 0 ? this.monthKeys[0] : today
    const monthEnd = this.monthKeys.length > 0 ? this.monthKeys[this.monthKeys.length - 1] : today
    const all = await VitalityStore.loadAll()
    const checked: string[] = []
    let totalComplete = 0
    let monthComplete = 0
    for (const r of all) {
      if (r.isComplete()) {
        totalComplete++
        checked.push(r.dateKey)
        if (r.dateKey >= monthStart && r.dateKey <= monthEnd) {
          monthComplete++
        }
      }
    }
    this.checkedMonthKeys = checked
    if (rec !== undefined && rec.isComplete()) {
      this.hasCheckedIn = true
      this.todayRecord = rec
      this.exerciseKey = rec.exerciseKey
      this.moodKey = rec.moodKey
      this.energyKey = rec.energyKey
      this.noteText = rec.note
      this.actions = await PrescriptionService.ensureFor(rec)
    } else {
      this.hasCheckedIn = false
      this.editing = false
      this.todayRecord = VitalityRecord.createNew(today)
      this.actions = []
    }
    const rxDone = this.doneActionCount()
    const rxTotal = this.actions.length
    this.todayProgress = await StatsService.todayProgress(
      this.hasCheckedIn,
      rxDone,
      rxTotal,
      this.weekDone,
      this.weekGoal
    )
    this.progressPercent = this.todayProgress.percent
    this.progressCheckedIn = this.todayProgress.checkedIn
    this.progressRxDone = this.todayProgress.prescriptionDone
    this.progressRxTotal = this.todayProgress.prescriptionTotal
    this.statTotal = totalComplete
    this.statMonth = monthComplete
    this.statRxPct = StatsService.prescriptionRatePercent(rxDone, rxTotal)
    this.statFav = await VitalityStore.favoriteCount()
    this.dashboardEpoch++
    this.recentEvents = await TimelineService.buildEvents(5)
    this.insightText = await StatsService.currentMonthInsight()
  }

  private openCheckIn(): void {
    this.showCheckIn = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeCheckIn(): void {
    this.showCheckIn = false
    this.editing = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async handleSubmit(): Promise<void> {
    const storeOk = await VitalityStore.ensureReady()
    if (!storeOk) {
      this.showToast('本地存储未就绪，请重启应用后再试')
      return
    }
    if (this.exerciseKey.length === 0 || this.moodKey.length === 0 || this.energyKey.length === 0) {
      this.showToast('请选择运动、心情、精力')
      return
    }
    const today = DateHelper.todayKey()
    const rec = VitalityRecord.createNew(today)
    rec.exerciseKey = this.exerciseKey
    rec.moodKey = this.moodKey
    rec.energyKey = this.energyKey
    rec.note = this.noteText.trim()
    rec.timestamp = Date.now()
    await VitalityStore.saveRecord(rec)
    this.actions = await PrescriptionService.ensureFor(rec)
    await StatsService.refreshPlanProgress()
    await AchievementService.evaluateAndUnlock()
    this.editing = false
    this.showToast(this.hasCheckedIn ? '已更新' : '记录成功，去完成一条处方吧')
    await this.reload()
    this.onChanged()
  }

  private async handleToggleAction(id: string): Promise<void> {
    const next: MicroAction[] = []
    for (const a of this.actions) {
      const copy = new MicroAction()
      copy.id = a.id
      copy.dateKey = a.dateKey
      copy.title = a.title
      copy.hint = a.hint
      copy.done = a.id === id ? !a.done : a.done
      next.push(copy)
    }
    this.actions = next
    this.actionRevision++
    await VitalityStore.toggleAction(id)
    await StatsService.refreshPlanProgress()
    await AchievementService.evaluateAndUnlock()
    await this.reload()
    this.onChanged()
  }

  private async handlePin(): Promise<void> {
    this.pinned = await VitalityStore.togglePin(DateHelper.todayKey())
    await AchievementService.evaluateAndUnlock()
    this.showToast(this.pinned ? '已收藏高光日' : '已取消收藏')
    await this.reload()
    this.onChanged()
  }

  private async saveNote(): Promise<void> {
    if (this.noteBody.trim().length === 0) {
      this.showToast('请先写点内容')
      return
    }
    const n = new VitalityNote()
    n.id = `note-${Date.now()}`
    n.title = this.noteTitle.trim().length > 0 ? this.noteTitle.trim() : '纪行笔记'
    n.body = this.noteBody.trim()
    n.dateKey = DateHelper.todayKey()
    n.createdAt = Date.now()
    n.favorite = false
    await VitalityStore.saveNote(n)
    this.noteTitle = ''
    this.noteBody = ''
    this.showNoteSheet = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('纪行笔记已保存')
    await this.reload()
    this.onChanged()
  }

  private doneActionCount(): number {
    let c = 0
    for (const a of this.actions) {
      if (a.done) {
        c++
      }
    }
    return c
  }

  private async openEventDetail(e: TimelineEvent): Promise<void> {
    if (e.eventType === 'checkin' || e.eventType === 'highlight') {
      await this.openDayDetail(e.dateKey)
      return
    }
    if (e.eventType === 'note') {
      const n = await VitalityStore.noteById(e.refId)
      if (n !== undefined) {
        this.detailNote = n
        this.showNoteDetail = true
        AppStorage.setOrCreate('tabBarHidden', true)
      }
      return
    }
    if (e.eventType === 'achievement') {
      this.achProgress = await AchievementService.progressState(e.refId)
      this.showAchDetail = true
      AppStorage.setOrCreate('tabBarHidden', true)
      return
    }
    await this.openDayDetail(e.dateKey)
  }

  private async openDayDetail(dateKey: string): Promise<void> {
    const r = await VitalityStore.recordForDate(dateKey)
    if (r === undefined || !r.isComplete()) {
      return
    }
    this.detailRecord = r
    this.detailActions = await PrescriptionService.ensureFor(r)
    this.detailPinned = await VitalityStore.isPinned(dateKey)
    this.showDayDetail = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeOverlays(): void {
    this.showDayDetail = false
    this.showNoteDetail = false
    this.showAchDetail = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          TodayHeroSection({
            greetingLine: `${DateHelper.greeting()}，${this.profile.nickname}`,
            dateLabel: this.dateLabel,
            quote: this.dailyQuote,
            streak: this.streak
          })

          Column({ space: Theme.space.s5 }) {
            ProgressHeroCard({
              percent: this.progressPercent,
              checkedIn: this.progressCheckedIn,
              rxDone: this.progressRxDone,
              rxTotal: this.progressRxTotal,
              weekDone: this.weekDone,
              weekGoal: this.weekGoal
            })
            WorkbenchStatGrid({
              totalRecords: this.statTotal,
              monthRecords: this.statMonth,
              rxPercent: this.statRxPct,
              favoriteCount: this.statFav
            })
            this.MainCard()
            CheckInCalendarStrip({ monthKeys: this.monthKeys, checkedKeys: this.checkedMonthKeys })
            WeeklyGoalBar({ weekDone: this.weekDone, weekGoal: this.weekGoal })
            QuickActionRow({
              onCheckIn: (): void => this.openCheckIn(),
              onNote: (): void => {
                this.showNoteSheet = true
                AppStorage.setOrCreate('tabBarHidden', true)
              },
              onPlan: (): void => this.onOpenGrowth(),
              onAction: (): void => this.onOpenAction(),
              onBreathing: (): void => {
                this.showBreathing = true
                AppStorage.setOrCreate('tabBarHidden', true)
              },
              onSearch: (): void => this.onOpenSearch()
            })
            RecentTimelineStrip({
              events: this.recentEvents,
              onTapEvent: (e: TimelineEvent): void => { void this.openEventDetail(e) }
            })
            VitalityInsightsCard({
              insightText: this.insightText,
              onBreathing: (): void => {
                this.showBreathing = true
                AppStorage.setOrCreate('tabBarHidden', true)
              }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ top: Theme.space.s2 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      CheckInSheet({
        visible: this.showCheckIn,
        hasCheckedIn: this.hasCheckedIn,
        editing: this.editing,
        todayRecord: this.todayRecord,
        exerciseKey: this.exerciseKey,
        moodKey: this.moodKey,
        energyKey: this.energyKey,
        noteText: this.noteText,
        pinned: this.pinned,
        actions: this.actions,
        actionRevision: this.actionRevision,
        onClose: (): void => this.closeCheckIn(),
        onSelectExercise: (k: string): void => { this.exerciseKey = k },
        onSelectMood: (k: string): void => { this.moodKey = k },
        onSelectEnergy: (k: string): void => { this.energyKey = k },
        onNoteChange: (t: string): void => { this.noteText = t },
        onSubmit: (): void => { void this.handleSubmit() },
        onEdit: (): void => { this.editing = true },
        onPin: (): void => { void this.handlePin() },
        onToggleAction: (id: string): void => { void this.handleToggleAction(id) }
      })

      if (this.showNoteSheet) {
        this.NoteSheet()
      }

      if (this.showBreathing) {
        BreathingGuideOverlay({
          onClose: (): void => {
            this.showBreathing = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
      }

      if (this.showDayDetail) {
        DayDetailOverlay({
          dateLabel: DateHelper.displayDate(this.detailRecord.dateKey),
          record: this.detailRecord,
          actions: this.detailActions,
          pinned: this.detailPinned,
          onClose: (): void => this.closeOverlays(),
          onToggleAction: (id: string): void => { void this.toggleDetailAction(id) },
          onTogglePin: (): void => { void this.toggleDetailPin() },
          onSave: (ex: string, mood: string, energy: string, note: string): void => {
            void this.saveDetail(ex, mood, energy, note)
          },
          onDelete: (): void => { void this.deleteDetail() }
        })
      }

      if (this.showNoteDetail) {
        NoteDetailOverlay({
          note: this.detailNote,
          onClose: (): void => this.closeOverlays(),
          onToggleFavorite: (): void => { void this.toggleNoteFavorite() },
          onSave: (title: string, body: string, tags: string): void => {
            void this.saveNoteDetail(title, body, tags)
          },
          onDelete: (): void => { void this.deleteNoteDetail() }
        })
      }

      if (this.showAchDetail) {
        AchievementDetailOverlay({
          progress: this.achProgress,
          onClose: (): void => this.closeOverlays()
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,42,58,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 56 })
          .markAnchor({ x: '50%', y: 0 })
          .zIndex(60)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  MainCard() {
    Column({ space: Theme.space.s4 }) {
      if (this.hasCheckedIn) {
        Row({ space: Theme.space.s4 }) {
          VitalityScoreBadge({ score: this.todayRecord.vitalityScore() })
          Column({ space: Theme.space.s2 }) {
            Text('今日活力已记录')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text(`处方 ${this.doneActionCount()}/${this.actions.length} 已完成`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        DimensionSummaryChips({
          exerciseLabel: DimensionOption.labelFor('exercise', this.todayRecord.exerciseKey),
          moodLabel: DimensionOption.labelFor('mood', this.todayRecord.moodKey),
          energyLabel: DimensionOption.labelFor('energy', this.todayRecord.energyKey)
        })
        AppButton({ label: '管理今日活力', variant: 'primary', onTap: (): void => this.openCheckIn() })
      } else {
        Column({ space: Theme.space.s3 }) {
          Text('今日进度')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Text('用 3 秒记录运动 · 心情 · 精力，获得专属活力处方')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(20)
          AppButton({ label: '记录今日活力', variant: 'primary', onTap: (): void => this.openCheckIn() })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({
      radius: 20,
      color: Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(255,107,53,0.08)',
      offsetX: 0,
      offsetY: 6
    })
  }

  @Builder
  NoteSheet() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column().width('100%').height('100%').backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => {
          this.showNoteSheet = false
          AppStorage.setOrCreate('tabBarHidden', false)
        })
      Column({ space: Theme.space.s4 }) {
        Text('写纪行笔记')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
        TextInput({ text: this.noteTitle, placeholder: '标题（选填）' })
          .onChange((v: string): void => { this.noteTitle = v })
        TextArea({ text: this.noteBody, placeholder: '记录今天想留给未来的话…' })
          .height(120)
          .onChange((v: string): void => { this.noteBody = v })
        AppButton({ label: '保存笔记', variant: 'primary', onTap: (): void => { void this.saveNote() } })
      }
      .width('100%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
    }
    .width('100%')
    .height('100%')
    .zIndex(55)
  }

  private async toggleDetailAction(id: string): Promise<void> {
    await VitalityStore.toggleAction(id)
    this.detailActions = await VitalityStore.actionsForDate(this.detailRecord.dateKey)
    await this.reload()
    this.onChanged()
  }

  private async toggleDetailPin(): Promise<void> {
    this.detailPinned = await VitalityStore.togglePin(this.detailRecord.dateKey)
    await this.reload()
    this.onChanged()
  }

  private async saveDetail(ex: string, mood: string, energy: string, note: string): Promise<void> {
    const rec = this.detailRecord
    rec.exerciseKey = ex
    rec.moodKey = mood
    rec.energyKey = energy
    rec.note = note.trim()
    await VitalityStore.saveRecord(rec)
    await AchievementService.evaluateAndUnlock()
    await this.reload()
    this.onChanged()
  }

  private async deleteDetail(): Promise<void> {
    await VitalityStore.deleteRecord(this.detailRecord.dateKey)
    this.closeOverlays()
    await this.reload()
    this.onChanged()
  }

  private async toggleNoteFavorite(): Promise<void> {
    const fav = await VitalityStore.toggleNoteFavorite(this.detailNote.id)
    this.detailNote.favorite = fav
    this.showToast(fav ? '已收藏笔记' : '已取消收藏')
    this.onChanged()
  }

  private async saveNoteDetail(title: string, body: string, tags: string): Promise<void> {
    this.detailNote.title = title.trim().length > 0 ? title.trim() : '纪行笔记'
    this.detailNote.body = body.trim()
    this.detailNote.tagKeys = tags
    await VitalityStore.saveNote(this.detailNote)
    this.showToast('笔记已更新')
    await this.reload()
    this.onChanged()
  }

  private async deleteNoteDetail(): Promise<void> {
    await VitalityStore.deleteNote(this.detailNote.id)
    this.closeOverlays()
    this.showToast('笔记已删除')
    await this.reload()
    this.onChanged()
  }
}
