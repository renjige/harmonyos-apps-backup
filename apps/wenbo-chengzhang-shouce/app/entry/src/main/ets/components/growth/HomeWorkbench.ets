import { Theme } from '../design-system/Theme'
import { AppStatCard } from '../design-system/AppStatCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AppIcon } from '../design-system/AppIcon'
import { GrowthListCard } from './GrowthListCard'
import { GrowthRecordItem, StatsData } from '../../models/GrowthModels'
import { GrowthDetailNav } from '../../services/GrowthDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct HomeWorkbench {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop stats: StatsData = new StatsData()
  @Prop statsLoading: boolean = true
  @Prop todayPercent: number = 0
  @Prop todayDone: number = 0
  @Prop todayTotal: number = 0
  @Prop ritualDone: boolean = false
  @Prop activeGoals: GrowthRecordItem[] = []
  @Prop listEpoch: number = 0
  @Prop bumpingGoalId: string = ''
  @Prop recentRecords: GrowthRecordItem[] = []
  onWriteRecord: () => void = () => {}
  onOpenRitual: () => void = () => {}
  onSwitchTab: (index: number) => void = () => {}
  onOpenTools: () => void = () => {}
  onOpenHabits: () => void = () => {}
  onBumpGoal: (goalId: string) => void = () => {}
  onRequireAuth: () => void = () => {}

  build() {
    Column({ space: Theme.space.s5 }) {
      Column({ space: Theme.space.s3 }) {
        Text('今日进度')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后开始今日成长',
            description: '对齐仪式、记录与目标，进度会在这里汇总',
            actionLabel: '去登录',
            onAction: (): void => { this.onRequireAuth() }
          })
        } else {
          Column({ space: Theme.space.s3 }) {
            Text(`${this.todayPercent}%`)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
            Stack({ alignContent: Alignment.Start }) {
              Column()
                .width('100%')
                .height(10)
                .backgroundColor(Theme.colors().strokeHairline)
                .borderRadius(Theme.radius.pill)
              Column()
                .width(`${Math.min(this.todayPercent, 100)}%`)
                .height(10)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.pill)
            }
            .width('100%')
            Text(`已完成 ${this.todayDone} / 今日待办 ${this.todayTotal}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              AppButton({
                label: this.ritualDone ? '仪式已完成' : '继续今日仪式',
                variant: 'secondary',
                onTap: (): void => { this.onOpenRitual() }
              }).layoutWeight(1)
              AppButton({
                label: '写一条记录',
                onTap: (): void => { this.onWriteRecord() }
              }).layoutWeight(1)
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')

      if (AuthService.isLoggedIn()) {
        if (this.statsLoading) {
          AppLoading({ label: '加载数据…' })
        } else {
          Row({ space: Theme.space.s2 }) {
            AppStatCard({ label: '记录', value: `${this.stats.recordCount}`, trend: '条', positive: true })
              .layoutWeight(1)
            AppStatCard({ label: '已完成', value: `${this.stats.completedGoals}`, trend: '个', positive: true })
              .layoutWeight(1)
          }
          .width('100%')
          Row({ space: Theme.space.s2 }) {
            AppStatCard({ label: '连续', value: `${this.stats.streakDays}`, trend: '天', positive: true })
              .layoutWeight(1)
            AppStatCard({ label: '里程碑', value: `${this.stats.milestoneCount}`, trend: '条', positive: true })
              .layoutWeight(1)
          }
          .width('100%')
        }

        Row({ space: Theme.space.s2 }) {
          this.QuickChip('写记录', 'book', (): void => { this.onWriteRecord() })
          this.QuickChip('设目标', 'calendar', (): void => { this.onSwitchTab(2) })
          this.QuickChip('习惯', 'check', (): void => { this.onOpenHabits() })
          this.QuickChip('更多', 'search', (): void => { this.onOpenTools() })
        }
        .width('100%')

        if (this.activeGoals.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('进行中目标')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.activeGoals.slice(0, 2), (goal: GrowthRecordItem) => {
              Column({ space: 6 }) {
                Row() {
                  Text(goal.title)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                    .maxLines(1)
                  Text(`${goal.progress}%`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                }
                .width('100%')
                AppButton({
                  label: this.bumpingGoalId === goal.id ? '更新中…' : '+10% 进度',
                  variant: 'secondary',
                  onTap: (): void => { this.onBumpGoal(goal.id) }
                })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => {
                if (goal.id.length > 0) {
                  GrowthDetailNav.openPlan(goal.id)
                }
              })
            }, (goal: GrowthRecordItem) => `${goal.id}-${goal.progress}-${this.listEpoch}`)
          }
          .width('100%')
        }

        if (this.recentRecords.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('最近动态')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.recentRecords.slice(0, 5), (item: GrowthRecordItem) => {
              GrowthListCard({
                item: item,
                onTap: (): void => { GrowthDetailNav.openInspiration(item.id) }
              })
            }, (item: GrowthRecordItem) => `${item.id}-${this.listEpoch}`)
          }
          .width('100%')
        }
      }
    }
    .width('100%')
  }

  @Builder
  QuickChip(label: string, icon: string, action: () => void) {
    Column({ space: 4 }) {
      AppIcon({
        name: icon === 'book' ? 'book' : (icon === 'calendar' ? 'calendar' :
          (icon === 'check' ? 'check' : 'search')),
        iconSize: Theme.icon.md,
        color: Theme.colors().brandPrimary
      })
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.lg)
    .onClick(action)
  }
}
