import { Theme } from '../design-system/Theme'
import { AppStatCard } from '../design-system/AppStatCard'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { AppLoading } from '../design-system/AppLoading'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppButton } from '../design-system/AppButton'
import { GrowthRecordItem, StatsData } from '../../models/GrowthModels'
import { GrowthDetailNav } from '../../services/GrowthDetailNav'
import { AuthService } from '../../services/AuthService'

class QuickActionItem {
  label: string = ''
  subtitle: string = ''
  icon: AppIconName = 'home'
  action: string = ''
}

@Component
export struct HomeDashboard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop stats: StatsData = new StatsData()
  @Prop statsLoading: boolean = true
  @Prop activeGoals: GrowthRecordItem[] = []
  @Prop listEpoch: number = 0
  @Prop bumpingGoalId: string = ''
  @Prop achievements: GrowthRecordItem[] = []
  @Prop messageCount: number = 0
  onWriteRecord: () => void = () => {}
  onSwitchTab: (index: number) => void = () => {}
  onBumpGoal: (goalId: string) => void = () => {}
  onOpenAnnualReport: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenOrganize: () => void = () => {}
  onOpenMessages: () => void = () => {}
  onOpenHabits: () => void = () => {}
  onOpenReviews: () => void = () => {}
  onOpenDiagnose: () => void = () => {}

  private quickActions(): QuickActionItem[] {
    const items: QuickActionItem[] = []
    const a0 = new QuickActionItem()
    a0.label = '写记录'
    a0.subtitle = '图文日记'
    a0.icon = 'book'
    a0.action = 'record'
    items.push(a0)
    const a1 = new QuickActionItem()
    a1.label = '设目标'
    a1.subtitle = '进度追踪'
    a1.icon = 'calendar'
    a1.action = 'plan'
    items.push(a1)
    const a2 = new QuickActionItem()
    a2.label = '时间轴'
    a2.subtitle = '里程碑'
    a2.icon = 'chart'
    a2.action = 'board'
    items.push(a2)
    const a3 = new QuickActionItem()
    a3.label = '年度报告'
    a3.subtitle = '数据回顾'
    a3.icon = 'chart'
    a3.action = 'annual'
    items.push(a3)
    const a4 = new QuickActionItem()
    a4.label = '成就收藏'
    a4.subtitle = '徽章成果'
    a4.icon = 'heart'
    a4.action = 'favorites'
    items.push(a4)
    const a5 = new QuickActionItem()
    a5.label = '智慧整理'
    a5.subtitle = '搜索归档'
    a5.icon = 'search'
    a5.action = 'organize'
    items.push(a5)
    const a6 = new QuickActionItem()
    a6.label = '习惯'
    a6.subtitle = '每日打卡'
    a6.icon = 'check'
    a6.action = 'habit'
    items.push(a6)
    const a7 = new QuickActionItem()
    a7.label = '复盘'
    a7.subtitle = '本周四问'
    a7.icon = 'book'
    a7.action = 'review'
    items.push(a7)
    const a8 = new QuickActionItem()
    a8.label = '诊断'
    a8.subtitle = '模板报告'
    a8.icon = 'ai'
    a8.action = 'diagnose'
    items.push(a8)
    const a9 = new QuickActionItem()
    a9.label = '消息'
    a9.subtitle = '成长提醒'
    a9.icon = 'message'
    a9.action = 'messages'
    items.push(a9)
    return items
  }

  private handleQuickAction(action: string): void {
    if (action === 'record') {
      this.onWriteRecord()
      return
    }
    if (action === 'plan') {
      this.onSwitchTab(2)
      return
    }
    if (action === 'board') {
      this.onSwitchTab(3)
      return
    }
    if (action === 'annual') {
      this.onOpenAnnualReport()
      return
    }
    if (action === 'favorites') {
      this.onOpenFavorites()
      return
    }
    if (action === 'organize') {
      this.onOpenOrganize()
      return
    }
    if (action === 'messages') {
      this.onOpenMessages()
      return
    }
    if (action === 'habit') {
      this.onOpenHabits()
      return
    }
    if (action === 'review') {
      this.onOpenReviews()
      return
    }
    if (action === 'diagnose') {
      this.onOpenDiagnose()
    }
  }

  build() {
    Column({ space: Theme.space.s5 }) {
      Column({ space: Theme.space.s3 }) {
        Text('成长概览')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        if (this.statsLoading) {
          AppLoading({ label: '加载数据…' })
        } else if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后查看个人数据',
            description: '记录数、连续天数、目标完成率将在此展示',
            actionLabel: '',
            onAction: (): void => {}
          })
        } else {
          Row({ space: Theme.space.s3 }) {
            AppStatCard({
              label: '记录',
              value: `${this.stats.recordCount}`,
              trend: '条',
              positive: true
            }).layoutWeight(1)
            AppStatCard({
              label: '连续',
              value: `${this.stats.streakDays}`,
              trend: '天',
              positive: true
            }).layoutWeight(1)
          }
          .width('100%')
          Row({ space: Theme.space.s3 }) {
            AppStatCard({
              label: '目标',
              value: `${this.stats.goalCount}`,
              trend: '项',
              positive: true
            }).layoutWeight(1)
            AppStatCard({
              label: '已完成',
              value: `${this.stats.completedGoals}`,
              trend: '个',
              positive: true
            }).layoutWeight(1)
          }
          .width('100%')
        }
      }
      .width('100%')

      Column({ space: Theme.space.s3 }) {
        Row() {
          Text('进行中目标')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('全部')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => { this.onSwitchTab(2) })
        }
        .width('100%')
        if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后管理目标',
            description: '设定阶段目标并追踪完成进度',
            actionLabel: '',
            onAction: (): void => {}
          })
        } else if (this.activeGoals.length === 0) {
          AppEmpty({
            title: '暂无进行中的目标',
            description: '前往「成长目标」创建第一个目标',
            actionLabel: '去创建',
            onAction: (): void => { this.onSwitchTab(2) }
          })
        } else {
          ForEach(this.activeGoals.slice(0, 3), (goal: GrowthRecordItem) => {
            Column({ space: 8 }) {
              Row() {
                Text(goal.title.length > 0 ? goal.title : '未命名目标')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                  .onClick((): void => {
                    if (goal.id.length > 0) {
                      GrowthDetailNav.openPlan(goal.id)
                    }
                  })
                Text(`${goal.progress}%`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              }
              .width('100%')
              Stack({ alignContent: Alignment.Start }) {
                Column()
                  .width('100%')
                  .height(8)
                  .backgroundColor(Theme.colors().strokeHairline)
                  .borderRadius(Theme.radius.pill)
                Column()
                  .width(`${Math.min(goal.progress, 100)}%`)
                  .height(8)
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.pill)
              }
              .width('100%')
              Row({ space: Theme.space.s2 }) {
                AppButton({
                  label: this.bumpingGoalId === goal.id ? '更新中…' :
                    (goal.progress >= 90 ? '+10% 完成' : '+10% 进度'),
                  variant: 'secondary',
                  onTap: (): void => { this.onBumpGoal(goal.id) }
                }).layoutWeight(1)
                Text('查看详情')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .padding({ top: 10, bottom: 10 })
                  .onClick((): void => {
                    if (goal.id.length > 0) {
                      GrowthDetailNav.openPlan(goal.id)
                    }
                  })
              }
              .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
          }, (goal: GrowthRecordItem) => `${goal.id}-${goal.progress}-${this.listEpoch}`)
        }
      }
      .width('100%')

      Column({ space: Theme.space.s3 }) {
        Text('功能入口')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.quickActions(), (item: QuickActionItem) => {
            Column({ space: 6 }) {
              Column() {
                AppIcon({
                  name: item.icon,
                  iconSize: Theme.icon.md,
                  color: Theme.colors().brandPrimary
                })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.lg)
              Text(item.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(item.subtitle)
                .fontSize(Theme.type.overline)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('22%')
            .margin({ bottom: Theme.space.s3 })
            .onClick((): void => { this.handleQuickAction(item.action) })
          }, (item: QuickActionItem) => item.action)
        }
        .width('100%')
      }
      .width('100%')

      if (this.messageCount > 0) {
        Row({ space: Theme.space.s3 }) {
          AppIcon({ name: 'message', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
          Column({ space: 2 }) {
            Text(`你有 ${this.messageCount} 条成长提醒`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('点击查看机构通知与阶段提醒')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick((): void => { this.onOpenMessages() })
      }

      if (this.achievements.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('成长徽章')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Scroll() {
            Row({ space: Theme.space.s3 }) {
              ForEach(this.achievements.slice(0, 6), (badge: GrowthRecordItem) => {
                Column({ space: 6 }) {
                  Column() {
                    AppIcon({ name: 'check', iconSize: Theme.icon.md, color: Theme.colors().brandAccent })
                  }
                  .width(48)
                  .height(48)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  Text(badge.title)
                    .fontSize(Theme.type.overline)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                    .textAlign(TextAlign.Center)
                    .width(72)
                }
              }, (badge: GrowthRecordItem) => badge.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
        .width('100%')
      }
    }
    .width('100%')
  }
}
