import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AchievementDetailOverlay } from '../components/vitality/AchievementDetailOverlay'
import { PlanEditorSheet } from '../components/vitality/PlanEditorSheet'
import {
  AchievementProgress, MonthReport, VitalityPlan, YearReport
} from '../models/VitalityModels'
import { AchievementService, StatsService } from '../services/StatsService'
import { VitalityStore } from '../services/VitalityStore'
import { DateHelper } from '../services/DateHelper'
import { PrescriptionService } from '../services/PrescriptionService'
import { AchievementPage } from './AchievementPage'

enum GrowthSegment {
  Achievements = 0,
  Overview = 1,
  Plans = 2,
  Review = 3
}

@Component
export struct GrowthHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop @Watch('onPlansPulseChange') plansPulse: number = 0
  @Prop bottomInset: number = 76
  onChanged: () => void = () => {}
  @State segment: GrowthSegment = GrowthSegment.Achievements
  @State statTotal: number = 0
  @State statMonth: number = 0
  @State statRxPct: number = 0
  @State statFav: number = 0
  @State insightText: string = ''
  @State monthReport: MonthReport | undefined = undefined
  @State yearReport: YearReport | undefined = undefined
  @State plans: VitalityPlan[] = []
  @State plansEpoch: number = 0
  @State editorSession: number = 0
  @State weekDone: number = 0
  @State todayCheckedIn: boolean = false
  @State todayRxTotal: number = 0
  @State todayRxDone: number = 0
  @State todayRxRate: number = 0
  @State showPlanEditor: boolean = false
  @State editingPlan: VitalityPlan | undefined = undefined
  @State showAchDetail: boolean = false
  @State achProgress: AchievementProgress = new AchievementProgress()
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onPlansPulseChange(): void {
    this.segment = GrowthSegment.Plans
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    await VitalityStore.refreshCacheFromDisk()
    this.weekDone = await StatsService.weekCheckInCount()
    const today = DateHelper.todayKey()
    const todayRec = await VitalityStore.recordForDate(today)
    this.todayCheckedIn = todayRec !== undefined && todayRec.isComplete()
    const dash = await StatsService.dashboardStats()
    this.statTotal = dash.totalRecords
    this.statMonth = dash.monthRecords
    this.statRxPct = StatsService.prescriptionRatePercent(dash.prescriptionDone, dash.prescriptionTotal)
    this.statFav = dash.favoriteCount
    if (this.todayCheckedIn && todayRec !== undefined) {
      await PrescriptionService.ensureFor(todayRec)
    }
    await this.ensureWeeklyPlan()
    const todayRx = await StatsService.todayPrescriptionStats()
    this.todayRxDone = todayRx.done
    this.todayRxTotal = todayRx.total
    this.todayRxRate = StatsService.prescriptionRatePercent(todayRx.done, todayRx.total)
    this.statRxPct = this.todayRxRate
    this.plans = await VitalityStore.loadPlans()
    this.insightText = await StatsService.currentMonthInsight()
    this.monthReport = await StatsService.lastMonthReport()
    this.yearReport = await StatsService.yearReport()
    this.plansEpoch++
    await StatsService.refreshPlanProgress()
  }

  private async ensureWeeklyPlan(): Promise<void> {
    const profile = await VitalityStore.loadProfile()
    const existing = await VitalityStore.loadPlans()
    let found = false
    for (const p of existing) {
      if (p.planType === 'checkin' && p.status === 'active' && p.id.indexOf('plan-week-') === 0) {
        p.targetValue = profile.weeklyGoalDays
        p.currentValue = this.weekDone
        p.endKey = DateHelper.weekKey(DateHelper.todayKey())
        found = true
        await VitalityStore.savePlan(p)
      }
    }
    if (!found) {
      const plan = new VitalityPlan()
      plan.id = `plan-week-${Date.now()}`
      plan.title = '本周活力打卡'
      plan.planType = 'checkin'
      plan.targetValue = profile.weeklyGoalDays
      plan.currentValue = this.weekDone
      plan.startKey = DateHelper.weekKey(DateHelper.todayKey())
      plan.endKey = plan.startKey
      plan.status = 'active'
      await VitalityStore.savePlan(plan)
    }
  }

  private planPercent(p: VitalityPlan): number {
    if (p.planType === 'prescription') {
      if (!this.todayCheckedIn) {
        return 0
      }
      if (this.todayRxTotal === 0) {
        return 5
      }
      return this.todayRxRate > 100 ? 100 : this.todayRxRate
    }
    if (p.targetValue <= 0) {
      return 0
    }
    const raw = Math.round((p.currentValue / p.targetValue) * 100)
    return raw > 100 ? 100 : raw
  }

  private planProgressLabel(p: VitalityPlan): string {
    if (p.planType === 'prescription') {
      if (!this.todayCheckedIn) {
        return `目标 ${p.targetValue}% · 今日尚未打卡（打卡后自动生成处方）`
      }
      if (this.todayRxTotal === 0) {
        return `目标 ${p.targetValue}% · 已打卡，处方加载中`
      }
      const hit = this.todayRxRate >= p.targetValue ? ' · 已达标' : ''
      return `目标 ${p.targetValue}% · 已打卡 · 处方 ${this.todayRxDone}/${this.todayRxTotal}（${this.todayRxRate}%）${hit}`
    }
    return `${p.currentValue} / ${p.targetValue} 天`
  }

  private planBarColor(p: VitalityPlan): string {
    if (p.planType === 'prescription' && this.todayRxRate >= p.targetValue) {
      return Theme.colors().success
    }
    return Theme.colors().brandPrimary
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          this.SegChip('成就', GrowthSegment.Achievements)
          this.SegChip('概览', GrowthSegment.Overview)
          this.SegChip('计划', GrowthSegment.Plans)
          this.SegChip('回顾', GrowthSegment.Review)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        if (this.segment === GrowthSegment.Achievements) {
          AchievementPage({
            refreshToken: this.refreshToken,
            bottomInset: this.bottomInset,
            onTapAchievement: (id: string): void => { void this.openAchievement(id) }
          }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              if (this.segment === GrowthSegment.Overview) {
                this.OverviewBody()
              } else if (this.segment === GrowthSegment.Plans) {
                this.PlansBody()
              } else {
                this.ReviewBody()
              }
              Row().height(this.bottomInset)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')

      PlanEditorSheet({
        visible: this.showPlanEditor,
        editingPlan: this.editingPlan,
        formSession: this.editorSession,
        onClose: (): void => {
          this.showPlanEditor = false
          this.editingPlan = undefined
          AppStorage.setOrCreate('tabBarHidden', false)
        },
        onSave: (p: VitalityPlan): void => { void this.savePlan(p) }
      })

      if (this.showAchDetail) {
        AchievementDetailOverlay({
          progress: this.achProgress,
          onClose: (): void => {
            this.showAchDetail = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
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
  OverviewBody() {
    Text('成长概览')
      .fontSize(Theme.type.title2)
      .fontWeight(FontWeight.Bold)
      .width('100%')
    GridRow({ columns: 2, gutter: Theme.space.s3 }) {
      this.StatTile('累计打卡', `${this.statTotal}`, 'check')
      this.StatTile('本月记录', `${this.statMonth}`, 'chart')
      this.StatTile('处方完成', `${this.statRxPct}%`, 'biz')
      this.StatTile('收藏笔记', `${this.statFav}`, 'message')
    }
    .width('100%')
    Column({ space: Theme.space.s2 }) {
      Text('本月洞察').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium)
      Text(this.insightText).fontSize(Theme.type.body).fontColor(Theme.colors().textSecondary).lineHeight(22)
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  PlansBody() {
    Text('活力计划').fontSize(Theme.type.title2).fontWeight(FontWeight.Bold).width('100%')
    Column() {
      AppButton({
        label: '新建计划',
        variant: 'primary',
        onTap: (): void => {
          this.editingPlan = undefined
          this.editorSession++
          this.showPlanEditor = true
          AppStorage.setOrCreate('tabBarHidden', true)
        }
      })
    }
    .width('100%')
    if (this.plans.length === 0) {
      Text('创建第一个计划，让目标可见可追踪')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
    }
    ForEach(this.plans, (p: VitalityPlan) => {
      Column({ space: Theme.space.s3 }) {
        Row() {
          Text(p.title).fontSize(Theme.type.body).fontWeight(FontWeight.Medium).layoutWeight(1)
          Text(p.status === 'active' ? '进行中' : '已完成')
            .fontSize(Theme.type.caption).fontColor(Theme.colors().brandPrimary)
        }
        .width('100%')
        Stack({ alignContent: Alignment.Start }) {
          Column().width('100%').height(8).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.pill)
          Column().width(`${this.planPercent(p)}%`).height(8).backgroundColor(this.planBarColor(p)).borderRadius(Theme.radius.pill)
        }
        .width('100%')
        Text(this.planProgressLabel(p))
          .fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppButton({
              label: '编辑',
              variant: 'secondary',
              onTap: (): void => {
                this.editingPlan = p.copy()
                this.editorSession++
                this.showPlanEditor = true
                AppStorage.setOrCreate('tabBarHidden', true)
              }
            })
          }
          .layoutWeight(1)
          Column() {
            AppButton({ label: '删除', variant: 'secondary', onTap: (): void => { void this.deletePlan(p.id) } })
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(Theme.space.cardPadding)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
    }, (p: VitalityPlan) => `${p.id}-${p.targetValue}-${p.title}-${this.todayRxRate}-${this.todayRxDone}-${this.plansEpoch}`)
  }

  @Builder
  ReviewBody() {
    Text('长期回顾').fontSize(Theme.type.title2).fontWeight(FontWeight.Bold).width('100%')
    Column({ space: Theme.space.s2 }) {
      Text('本月洞察').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium)
      Text(this.insightText).fontSize(Theme.type.body).fontColor(Theme.colors().textSecondary).lineHeight(22)
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Start)
    if (this.monthReport !== undefined) {
      Column({ space: Theme.space.s2 }) {
        Text('上月摘要').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium)
        Text(this.monthReport.summary).fontSize(Theme.type.body).fontColor(Theme.colors().textSecondary).lineHeight(22)
      }
      .width('100%')
      .padding(Theme.space.cardPadding)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.lg)
      .alignItems(HorizontalAlign.Start)
    }
    if (this.yearReport !== undefined) {
      Column({ space: Theme.space.s2 }) {
        Text(`${this.yearReport.year} 年度回顾`).fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium)
        Text(this.yearReport.summary).fontSize(Theme.type.body).fontColor(Theme.colors().textSecondary).lineHeight(22)
      }
      .width('100%')
      .padding(Theme.space.cardPadding)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .alignItems(HorizontalAlign.Start)
    } else {
      Text('今年还没有足够记录，完成打卡后会生成年度回顾')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
    }
  }

  @Builder
  SegChip(label: string, seg: GrowthSegment) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.segment === seg ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.segment === seg ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.segment = seg
        if (seg === GrowthSegment.Plans) {
          void this.reload()
        }
      })
  }

  @Builder
  StatTile(label: string, value: string, icon: AppIconName) {
    GridCol() {
      Column({ space: Theme.space.s2 }) {
        AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        Text(value).fontSize(Theme.type.title3).fontWeight(FontWeight.Bold)
        Text(label).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
      }
      .width('100%')
      .padding(Theme.space.cardPadding)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .alignItems(HorizontalAlign.Start)
    }
  }

  private async openAchievement(id: string): Promise<void> {
    this.achProgress = await AchievementService.progressState(id)
    this.showAchDetail = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private async savePlan(p: VitalityPlan): Promise<void> {
    await VitalityStore.savePlan(p)
    this.showPlanEditor = false
    this.editingPlan = undefined
    AppStorage.setOrCreate('tabBarHidden', false)
    await StatsService.refreshPlanProgress()
    const fresh = await VitalityStore.loadPlans()
    const todayRx = await StatsService.todayPrescriptionStats()
    this.todayRxDone = todayRx.done
    this.todayRxTotal = todayRx.total
    this.todayRxRate = StatsService.prescriptionRatePercent(todayRx.done, todayRx.total)
    this.statRxPct = this.todayRxRate
    this.plansEpoch++
    this.plans = fresh
    this.showToast('计划已保存')
    this.onChanged()
  }

  private async deletePlan(id: string): Promise<void> {
    await VitalityStore.deletePlan(id)
    this.plansEpoch++
    this.plans = await VitalityStore.loadPlans()
    this.showToast('计划已删除')
    this.onChanged()
  }
}
