import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { ProgressTrack, SectionTitle } from '../components/shop/ShoppingCards'
import {
  AchievementBadge,
  ActivityEvent,
  CalendarDayMark,
  CheckInRecord,
  MonthlyReview,
  ProcurementPlan,
  ProcurementTopic,
  WeeklyReview
} from '../models/ShoppingModels'
import { GrowthService } from '../services/GrowthService'
import { ShoppingLocalStore } from '../services/ShoppingLocalStore'
import { ListMiniCard } from '../components/shop/ShoppingCards'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State segment: number = 0
  @State plan: ProcurementPlan = new ProcurementPlan()
  @State hasPlan: boolean = false
  @State badges: AchievementBadge[] = []
  @State events: ActivityEvent[] = []
  @State checkIns: CheckInRecord[] = []
  @State review: WeeklyReview = new WeeklyReview()
  @State planDone: number = 0
  @State streak: number = 0
  @State topics: ProcurementTopic[] = []
  @State monthReview: MonthlyReview = new MonthlyReview()
  @State calendarMarks: CalendarDayMark[] = []
  @State toastText: string = ''
  @Prop @Watch('onTick') refreshToken: number = 0
  onOpenPlanEditor: () => void = () => {}
  onOpenTopics: () => void = () => {}
  onOpenCalendar: () => void = () => {}
  onOpenMonthlyReview: () => void = () => {}
  onOpenList: (id: string) => void = () => {}
  onOpenItem: (itemId: string, listId: string) => void = () => {}
  onOpenTopic: (id: string) => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  async reload(): Promise<void> {
    const active = GrowthService.activePlan()
    if (active !== undefined) {
      this.plan = active
      this.hasPlan = true
      this.planDone = GrowthService.planProgress(active)
    } else {
      this.hasPlan = false
      this.plan = new ProcurementPlan()
      this.planDone = 0
    }
    this.badges = GrowthService.badges()
    this.events = GrowthService.recentEvents(20)
    this.checkIns = GrowthService.checkIns()
    this.review = GrowthService.weeklyReview()
    this.streak = GrowthService.checkInStreak()
    this.topics = GrowthService.topics()
    this.monthReview = GrowthService.monthlyReview(GrowthService.currentMonthKey())
    const now = new Date()
    this.calendarMarks = GrowthService.calendarMarks(now.getFullYear(), now.getMonth() + 1)
  }

  private todayCheckedIn(): boolean {
    const key = ShoppingLocalStore.today()
    for (const row of this.checkIns) {
      if (row.dateKey === key) {
        return true
      }
    }
    return false
  }

  @Builder
  SegChip(label: string, index: number) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.segment === index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.segment === index ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.segment = index })
  }

  @Builder
  DataPanel() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        this.KpiCard('本周勾选', `${this.review.checkedCount}`)
        this.KpiCard('完成清单', `${this.review.listDone}`)
        this.KpiCard('打卡天数', `${this.review.checkInDays}`)
      }
      .width('100%')
      Text(`常买分类：${this.review.topCategory}`)
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        .width('100%')
      Text(`累计花费约 ${this.review.paidTotal} 元`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
  }

  @Builder
  KpiCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  PlanPanel() {
    Column({ space: 12 }) {
      if (!this.hasPlan) {
        AppEmpty({
          title: '还没有采购计划',
          description: '设定本周目标件数与预算，勾选进度会自动累计',
          actionLabel: '创建本周计划',
          onAction: (): void => {
            void GrowthService.createDefaultWeekPlan().then((p) => {
              this.plan = p
              this.hasPlan = true
              this.planDone = 0
              this.showToast('本周计划已创建')
              void this.reload()
            })
          }
        })
      } else {
        Text(this.plan.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
          .width('100%')
        ProgressTrack({ done: this.planDone, total: this.plan.targetItemCount > 0 ? this.plan.targetItemCount : 1 })
        Text(`目标 ${this.plan.targetItemCount} 件 · 预算 ${this.plan.targetBudgetYuan} 元`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .width('100%')
        Text(`已用预算约 ${GrowthService.planBudgetUsed(this.plan)} 元`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .width('100%')
        if (this.plan.status === 'done') {
          Text('本周计划已完成')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
        }
        AppButton({ label: '编辑计划', variant: 'secondary', onTap: (): void => { this.onOpenPlanEditor() } })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
  }

  @Builder
  CheckInPanel() {
    Column({ space: 12 }) {
      Text(`连续打卡 ${this.streak} 天`)
        .fontSize(Theme.type.subtitleM)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        .width('100%')
      if (this.todayCheckedIn()) {
        Text('今日已打卡')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
      } else {
        AppButton({
          label: '今日采购打卡',
          onTap: (): void => {
            void GrowthService.checkInToday('manual', '完成今日采购').then((ok) => {
              if (ok) {
                this.showToast('打卡成功')
                void this.reload()
                return
              }
              this.showToast('今日已打卡')
            })
          }
        })
      }
      if (this.checkIns.length === 0) {
        Text('打卡记录会显示在这里')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .width('100%')
      } else {
        ForEach(this.checkIns, (row: CheckInRecord) => {
          Row() {
            Text(row.dateKey)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .layoutWeight(1)
            Text(row.note.length > 0 ? row.note : row.source)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .maxLines(1)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
        }, (row: CheckInRecord) => row.dateKey + row.createdAt)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
  }

  @Builder
  BadgePanel() {
    Column({ space: 10 }) {
      if (this.badges.length === 0) {
        Text('成就加载中…')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .width('100%')
      } else {
        ForEach(this.badges, (b: AchievementBadge) => {
          Column({ space: 4 }) {
            Row() {
              Text(b.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                .layoutWeight(1)
              Text(b.unlockedAt.length > 0 ? '已解锁' : `${b.progress}/${b.target}`)
                .fontSize(Theme.type.caption)
                .fontColor(b.unlockedAt.length > 0 ? Theme.colors().brandPrimary : Theme.paint(this.themeEpoch).textSecondary)
            }
            .width('100%')
            Text(b.desc)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.lg)
        }, (b: AchievementBadge) => b.id)
      }
    }
    .width('100%')
  }

  @Builder
  TimelinePanel() {
    Column({ space: 8 }) {
      if (this.events.length === 0) {
        AppEmpty({
          title: '还没有动态',
          description: '创建清单、勾选物品、打卡后会自动记录'
        })
      } else {
        ForEach(this.events, (e: ActivityEvent) => {
          Column({ space: 4 }) {
            Text(e.title)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            Text(e.summary)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
              .maxLines(2)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => {
            const target = GrowthService.eventTarget(e)
            if (target === undefined) {
              return
            }
            if (target.kind === 'list') {
              this.onOpenList(target.id)
              return
            }
            if (target.kind === 'item') {
              this.onOpenItem(target.id, target.listId)
              return
            }
            if (target.kind === 'topic') {
              this.onOpenTopic(target.id)
            }
          })
        }, (e: ActivityEvent) => e.id)
      }
    }
    .width('100%')
  }

  @Builder
  TopicsPanel() {
    Column({ space: 10 }) {
      AppButton({ label: '管理采购主题', onTap: (): void => { this.onOpenTopics() } })
      if (this.topics.length === 0) {
        AppEmpty({ title: '还没有主题', description: '把多份清单归到同一采购主题' })
      } else {
        ForEach(this.topics, (row: ProcurementTopic) => {
          ListMiniCard({
            title: row.title,
            meta: `${row.listIds.length} 份清单`,
            coverKey: row.coverKey,
            onTap: (): void => { this.onOpenTopic(row.id) }
          })
        }, (row: ProcurementTopic) => row.id)
      }
    }
    .width('100%')
  }

  @Builder
  ReviewPanel() {
    Column({ space: 12 }) {
      Text('本周回顾')
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        .width('100%')
      Text(this.review.summary)
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        .width('100%')
      Text('本月摘要')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        .width('100%')
        .margin({ top: 8 })
      Text(this.monthReview.summary)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
      AppButton({ label: '打开月度报告', variant: 'secondary', onTap: (): void => { this.onOpenMonthlyReview() } })
      AppButton({ label: '打开采购日历', variant: 'secondary', onTap: (): void => { this.onOpenCalendar() } })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
  }

  private calendarActiveDays(): number {
    let markCount = 0
    for (const mark of this.calendarMarks) {
      if (mark.checkIn || mark.checkedCount > 0) {
        markCount += 1
      }
    }
    return markCount
  }

  @Builder
  CalendarPanel() {
    Column({ space: 10 }) {
      Text(`${GrowthService.currentMonthKey()} 打卡与勾选概览`)
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        .width('100%')
      Text(`本月有记录 ${this.calendarActiveDays()} 天 · 连续打卡 ${this.streak} 天`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
      AppButton({ label: '查看完整日历', onTap: (): void => { this.onOpenCalendar() } })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
  }

  @Builder
  MonthlyPanel() {
    Column({ space: 10 }) {
      Text(`${this.monthReview.monthKey} 月度报告`)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        .width('100%')
      Text(`勾选 ${this.monthReview.checkedCount} · 实付约 ${this.monthReview.paidTotal} 元`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
      if (this.monthReview.vsLastMonthPercent !== 0) {
        Text(`较上月 ${this.monthReview.vsLastMonthPercent > 0 ? '+' : ''}${this.monthReview.vsLastMonthPercent}%`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .width('100%')
      }
      AppButton({ label: '查看完整月报', onTap: (): void => { this.onOpenMonthlyReview() } })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '成长', subtitle: '计划 · 打卡 · 成就 · 回顾' })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Scroll() {
              Row({ space: 8 }) {
                this.SegChip('数据', 0)
                this.SegChip('计划', 1)
                this.SegChip('打卡', 2)
                this.SegChip('成就', 3)
                this.SegChip('动态', 4)
                this.SegChip('回顾', 5)
                this.SegChip('主题', 6)
                this.SegChip('日历', 7)
                this.SegChip('月报', 8)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            if (this.segment === 0) {
              this.DataPanel()
            } else if (this.segment === 1) {
              this.PlanPanel()
            } else if (this.segment === 2) {
              this.CheckInPanel()
            } else if (this.segment === 3) {
              SectionTitle({ title: '采购成就' })
              this.BadgePanel()
            } else if (this.segment === 4) {
              SectionTitle({ title: '最近动态' })
              this.TimelinePanel()
            } else if (this.segment === 5) {
              this.ReviewPanel()
            } else if (this.segment === 6) {
              SectionTitle({ title: '采购主题' })
              this.TopicsPanel()
            } else if (this.segment === 7) {
              this.CalendarPanel()
            } else {
              this.MonthlyPanel()
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: Theme.space.pageX, y: Theme.space.s6 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
