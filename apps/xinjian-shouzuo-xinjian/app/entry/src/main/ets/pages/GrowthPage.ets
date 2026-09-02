import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppRingChart, AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { AppIcon } from '../components/design-system/AppIcon'
import { CraftPlan, CraftPlanTask, CraftTimelineEvent } from '../models/CraftLocalModels'
import { CraftLocalStore } from '../services/CraftLocalStore'
import { CraftStatsService } from '../services/CraftStatsService'
import { CraftDashboardStats } from '../models/CraftLocalModels'
import { CraftAchievement } from '../models/CraftLocalModels'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('craftDataEpoch') @Watch('onDataChange') craftDataEpoch: number = 0
  @State stats: CraftDashboardStats = new CraftDashboardStats()
  @State plans: CraftPlan[] = []
  @State timeline: CraftTimelineEvent[] = []
  @State achievements: CraftAchievement[] = []
  @State barItems: BarChartItem[] = []
  @State newPlanTitle: string = ''
  @State newTaskText: string = ''
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onDataChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.stats = await CraftStatsService.loadDashboard(this.currentUsername)
    this.plans = CraftLocalStore.plans()
    this.timeline = await CraftStatsService.timeline(this.currentUsername, 12)
    this.achievements = CraftStatsService.achievements(this.stats)
    this.barItems = await CraftStatsService.weekBarItems(this.currentUsername)
  }

  private async handleCheckIn(): Promise<void> {
    if (this.currentUsername.length === 0) {
      this.onRequireAuth()
      return
    }
    if (CraftLocalStore.hasCheckInToday()) {
      this.showToast('今日已打卡')
      return
    }
    await CraftLocalStore.checkInToday('今日有创作')
    this.showToast('打卡成功')
    void this.reload()
  }

  private async addPlan(): Promise<void> {
    if (this.currentUsername.length === 0) {
      this.onRequireAuth()
      return
    }
    if (this.newPlanTitle.trim().length === 0) {
      this.showToast('请填写计划名称')
      return
    }
    const tasks: CraftPlanTask[] = []
    if (this.newTaskText.trim().length > 0) {
      const t = new CraftPlanTask()
      t.id = `t_${Date.now()}`
      t.title = this.newTaskText.trim()
      t.done = false
      tasks.push(t)
    }
    await CraftLocalStore.addPlan(this.newPlanTitle.trim(), '综合', tasks)
    this.newPlanTitle = ''
    this.newTaskText = ''
    this.showToast('计划已创建')
    void this.reload()
  }

  private async toggleTask(planId: string, taskId: string): Promise<void> {
    await CraftLocalStore.togglePlanTask(planId, taskId)
    void this.reload()
  }

  private async exportReview(): Promise<void> {
    const text = CraftStatsService.weekReviewText(this.currentUsername, this.stats)
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('本周回顾已复制')
    } catch {
      this.showToast('导出失败')
    }
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppHeader({ title: '成长', subtitle: '计划 · 打卡 · 统计 · 成就 · 回顾' })

          AppCard({ title: '今日创作打卡', variant: 'outlined' }) {
            Column({ space: Theme.space.s3 }) {
              Text(this.stats.todayCheckedIn ? '今日已打卡，继续保持' : '记录今日有创作，积累连续天数')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Text(`连续 ${this.stats.streakDays} 天`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().brandDeep)
                .width('100%')
              AppButton({
                label: this.stats.todayCheckedIn ? '已完成今日打卡' : '打卡',
                variant: this.stats.todayCheckedIn ? 'secondary' : 'primary',
                disabled: this.stats.todayCheckedIn,
                onTap: (): void => { void this.handleCheckIn() }
              })
            }.width('100%').alignItems(HorizontalAlign.Start)
          }

          Row({ space: Theme.space.s2 }) {
            Column() {
              AppRingChart({
                title: '计划进度',
                percent: this.stats.planTotal > 0 ? this.stats.planDone / this.stats.planTotal : 0
              })
            }.layoutWeight(1)
            Column() {
              AppBarChart({ title: '本周记录', items: this.barItems })
            }.layoutWeight(1)
          }.width('100%').padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          AppCard({ title: '新建创作计划', variant: 'glass' }) {
            Column({ space: Theme.space.s3 }) {
              TextInput({ text: this.newPlanTitle, placeholder: '计划名称，如：完成刺绣杯垫' })
                .width('100%')
                .onChange((v: string) => { this.newPlanTitle = v })
              TextInput({ text: this.newTaskText, placeholder: '首个步骤（可选）' })
                .width('100%')
                .onChange((v: string) => { this.newTaskText = v })
              AppButton({
                label: '创建计划',
                variant: 'primary',
                onTap: (): void => { void this.addPlan() }
              })
            }.width('100%')
          }

          Column({ space: Theme.space.s3 }) {
            Text('进行中的计划')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            if (this.plans.length === 0) {
              AppEmpty({
                title: '暂无计划',
                description: '创建计划并拆分步骤，跟做课堂更高效'
              })
            } else {
              ForEach(this.plans, (plan: CraftPlan) => {
                AppCard({ title: plan.title, variant: 'outlined' }) {
                  Column({ space: Theme.space.s2 }) {
                    Text(`进度 ${plan.completedCount()}/${plan.tasks.length} · ${plan.progressPercent()}%`)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.colors().textSecondary)
                      .width('100%')
                    ForEach(plan.tasks, (task: CraftPlanTask) => {
                      Row({ space: Theme.space.s2 }) {
                        AppIcon({
                          name: task.done ? 'check' : 'empty',
                          iconSize: Theme.icon.sm,
                          color: task.done ? Theme.colors().success : Theme.colors().textSecondary
                        })
                        Text(task.title)
                          .fontSize(Theme.type.subhead)
                          .fontColor(task.done ? Theme.colors().textSecondary : Theme.colors().textPrimary)
                          .decoration({ type: task.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                          .layoutWeight(1)
                      }
                      .width('100%')
                      .padding(Theme.space.s2)
                      .onClick((): void => { void this.toggleTask(plan.id, task.id) })
                    }, (task: CraftPlanTask) => `${task.id}_${task.done ? '1' : '0'}`)
                  }.width('100%')
                }
              }, (plan: CraftPlan) => plan.id)
            }
          }.width('100%').padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: Theme.space.s3 }) {
            Text('成就徽章')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.achievements, (a: CraftAchievement) => {
                Column({ space: 4 }) {
                  Text(a.unlocked ? a.title : '???')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(a.unlocked ? Theme.colors().brandDeep : Theme.colors().textTertiary)
                  Text(a.unlocked ? a.summary : '待解锁')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                }
                .width('46%')
                .padding(Theme.space.s3)
                .margin({ right: '4%', bottom: Theme.space.s2 })
                .backgroundColor(a.unlocked ? Theme.colors().successContainer : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.lg)
                .opacity(a.unlocked ? 1 : 0.72)
              }, (a: CraftAchievement) => a.id)
            }.width('100%')
          }.width('100%').padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: Theme.space.s3 }) {
            Text('创作历程')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            if (this.timeline.length === 0) {
              AppEmpty({ title: '暂无历程', description: '记录作品、灵感或打卡后会出现在这里' })
            } else {
              ForEach(this.timeline, (ev: CraftTimelineEvent) => {
                Row({ space: Theme.space.s3 }) {
                  Text(ev.at)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width(96)
                  Column({ space: 2 }) {
                    Text(ev.title)
                      .fontSize(Theme.type.subhead)
                      .fontColor(Theme.colors().textPrimary)
                    Text(ev.kind)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                  }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
              }, (ev: CraftTimelineEvent) => ev.id)
            }
          }.width('100%').padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          AppButton({
            label: '导出本周回顾',
            variant: 'secondary',
            onTap: (): void => { void this.exportReview() }
          })
        }
        .padding({ bottom: Theme.space.s10 })
      }
      .scrollBar(BarState.Off)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
