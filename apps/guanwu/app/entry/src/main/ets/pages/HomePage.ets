import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { RecordTimelineCard } from '../components/guanwu/RecordTimelineCard'
import {
  HomeProgressCard, HomeKpiRow, HomeQuickActions, HomeDailyPlanStrip
} from '../components/guanwu/HomeWorkbench'
import { ObserveRecord, WisdomTip } from '../models/ObserveModels'
import { ObserveTemplate, ExploreTaskDef } from '../models/ObserveCatalog'
import { DateHelper } from '../services/DateHelper'
import { ObserveStore } from '../services/ObserveStore'
import { MorningCardService, DailyChallenge } from '../services/MorningCardService'
import { InsightService } from '../services/InsightService'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'
import { ObservePlanService, PlanItem } from '../services/ObservePlanService'
import { CheckInService } from '../services/CheckInService'
import { ObserveLifecycleService } from '../services/ObserveLifecycleService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpenEditor: () => void = () => {}
  onOpenChallenge: (kind: string, hint: string) => void = () => {}
  onOpenPrefill: (record: ObserveRecord) => void = () => {}
  onOpenAtlas: () => void = () => {}
  onOpenRecords: () => void = () => {}
  onOpenInsight: () => void = () => {}
  onOpenExplore: () => void = () => {}
  onOpenRecord: (id: string) => void = () => {}
  onAchievementToast: (msg: string) => void = () => {}
  @State dateLabel: string = ''
  @State greeting: string = ''
  @State suggestion: string = ''
  @State recent: ObserveRecord[] = []
  @State tips: WisdomTip[] = []
  @State challenge: DailyChallenge = new DailyChallenge()
  @State planItems: PlanItem[] = []
  @State planDone: number = 0
  @State planTotal: number = 3
  @State progressPercent: number = 0
  @State checkedIn: boolean = false
  @State totalRecords: number = 0
  @State favoriteCount: number = 0
  @State streakDays: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
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
    this.dateLabel = DateHelper.displayDate(DateHelper.todayKey())
    const todayKey = DateHelper.todayKey()
    const today = await ObserveStore.notesForDate(todayKey)
    const weekStart = new Date()
    weekStart.setDate(weekStart.getDate() - 6)
    const weekNotes = await ObserveStore.notesInRange(DateHelper.keyFromDate(weekStart), todayKey)
    const card = MorningCardService.build(today.length, weekNotes.length)
    this.greeting = card.greeting
    this.suggestion = card.suggestion
    this.planItems = await ObservePlanService.syncFromTodayRecords()
    this.planDone = ObservePlanService.doneCount(this.planItems)
    this.planTotal = this.planItems.length
    this.checkedIn = await CheckInService.isCheckedIn(todayKey)
    let progress = ObservePlanService.progressPercent(this.planItems)
    if (this.checkedIn) {
      progress = Math.min(1, progress + 0.15)
    }
    this.progressPercent = progress
    const all = await ObserveStore.loadAll()
    this.totalRecords = all.length
    this.favoriteCount = (await ObserveStore.filterFavorites()).length
    this.streakDays = await ObserveStore.streakDays()
    const slice: ObserveRecord[] = []
    for (let i = 0; i < all.length && i < 3; i++) {
      slice.push(ObserveRecord.cloneFrom(all[i]))
    }
    this.recent = slice
    this.tips = await InsightService.wisdomTips()
    this.challenge = MorningCardService.todayChallenge()
  }

  private async togglePlan(id: string): Promise<void> {
    this.planItems = await ObservePlanService.toggle(id)
    this.planDone = ObservePlanService.doneCount(this.planItems)
    this.progressPercent = ObservePlanService.progressPercent(this.planItems)
  }

  private async handleCheckIn(): Promise<void> {
    if (this.checkedIn) {
      this.showToast('今日已打卡')
      return
    }
    const unlocked = await ObserveLifecycleService.afterManualCheckIn()
    this.checkedIn = true
    this.planItems = await ObservePlanService.syncFromTodayRecords()
    this.planDone = ObservePlanService.doneCount(this.planItems)
    this.progressPercent = Math.min(1, ObservePlanService.progressPercent(this.planItems) + 0.15)
    this.showToast('今日观察打卡成功')
    if (unlocked.length > 0) {
      this.onAchievementToast(`解锁成就：${unlocked[0]}`)
    }
  }

  private recordListKey(item: ObserveRecord): string {
    const imgs = item.imagePaths.join('|')
    return `${item.id}-${item.updatedAt}-${imgs}`
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Column({ space: 4 }) {
              Text('观物工作台')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(`${CategoryEmojiUtil.weekdayMark()} ${this.dateLabel}`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')

          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_morning'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(140)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0.1)', 0], ['rgba(26,26,46,0.82)', 1]]
              })
            Text('以观物取象，看见日常')
              .fontSize(Theme.type.body)
              .fontColor('#FFFFFF')
              .padding(Theme.space.s4)
          }
          .width('100%')
          .borderRadius(Theme.radius.md)
          .clip(true)

          Image($r('app.media.banner_observe'))
            .width('100%')
            .height(72)
            .borderRadius(Theme.radius.md)
            .objectFit(ImageFit.Cover)

          HomeProgressCard({
            planDone: this.planDone,
            planTotal: this.planTotal,
            checkedIn: this.checkedIn,
            progressPercent: this.progressPercent,
            greeting: this.greeting,
            suggestion: this.suggestion,
            onContinue: (): void => {
              if (!this.checkedIn) {
                void this.handleCheckIn()
                return
              }
              if (this.planDone < this.planTotal) {
                this.onOpenEditor()
                return
              }
              this.onOpenExplore()
            }
          })

          HomeKpiRow({
            totalRecords: this.totalRecords,
            planDone: this.planDone,
            favoriteCount: this.favoriteCount,
            streakDays: this.streakDays
          })

          HomeQuickActions({
            onNewRecord: (): void => this.onOpenEditor(),
            onOpenRecords: (): void => this.onOpenRecords(),
            onOpenAtlas: (): void => this.onOpenAtlas(),
            onCheckIn: (): void => { void this.handleCheckIn() },
            onOpenGrowth: (): void => this.onOpenInsight()
          })

          HomeDailyPlanStrip({
            items: this.planItems,
            onToggle: (id: string): void => { void this.togglePlan(id) }
          })

          Row({ space: Theme.space.s2 }) {
            Column() {
              AppButton({
                label: '探索中心',
                variant: 'secondary',
                onTap: (): void => this.onOpenExplore()
              })
            }.layoutWeight(1)
            Column() {
              AppButton({
                label: '今日挑战',
                variant: 'ghost',
                onTap: (): void => this.onOpenChallenge(this.challenge.kind, this.challenge.prompt)
              })
            }.layoutWeight(1)
          }
          .width('100%')

          if (this.tips.length > 0) {
            Column({ space: 6 }) {
              Text('智慧提示')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.tips[0].title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(this.tips[0].body)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }

          if (this.recent.length > 0) {
            Text('最近观察')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.recent, (item: ObserveRecord) => {
              RecordTimelineCard({
                record: item,
                onTap: (): void => this.onOpenRecord(item.id)
              })
            }, (item: ObserveRecord) => this.recordListKey(item))
          }
        }
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4, bottom: this.bottomInset })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
