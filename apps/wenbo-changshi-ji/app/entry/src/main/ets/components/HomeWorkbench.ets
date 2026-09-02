import { Theme } from './design-system/Theme'
import { AppIcon, AppIconName } from './design-system/AppIcon'
import { AppStatCard } from './design-system/AppStatCard'
import { AppRingChart } from './design-system/AppChart'
import { LearningHubService } from '../services/LearningHubService'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { DailyTaskState, LearningEvent, WorkbenchSnapshot } from '../models/LearningHubModels'

class TaskChip {
  key: string = ''
  label: string = ''
  done: boolean = false
}

@Component
export struct HomeWorkbench {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State snap: WorkbenchSnapshot = new WorkbenchSnapshot()

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.snap = LearningHubService.workbench()
  }

  private taskChips(): TaskChip[] {
    const t = this.snap.tasks
    const rows: TaskChip[] = []
    const keys: string[] = ['read', 'quiz', 'checkin', 'list']
    const labels: string[] = ['阅读 1 条', '完成小测', '今日打卡', '清单掌握']
    const flags: boolean[] = [t.readDone, t.quizDone, t.checkInDone, t.checklistDone]
    for (let i = 0; i < keys.length; i++) {
      const row = new TaskChip()
      row.key = keys[i]
      row.label = labels[i]
      row.done = flags[i]
      rows.push(row)
    }
    return rows
  }

  private openTask(key: string): void {
    if (key === 'quiz') {
      CommonSenseDetailNav.openQuiz()
    } else if (key === 'checkin') {
      CommonSenseDetailNav.openCheckIn()
    } else if (key === 'list') {
      CommonSenseDetailNav.openLists()
    } else {
      CommonSenseDetailNav.openPlan()
    }
  }

  private eventIcon(type: string): string {
    if (type === 'favorite') {
      return '已收藏'
    }
    if (type === 'quiz') {
      return '小测'
    }
    if (type === 'master') {
      return '掌握'
    }
    if (type === 'checkin') {
      return '打卡'
    }
    return '阅读'
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s2 }) {
        Column({ space: 4 }) {
          Text('本周学习进度')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Text(`目标 ${this.snap.plan.targetCount} 条 · 已完成 ${this.snap.plan.completedCount}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text('调整计划')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { CommonSenseDetailNav.openPlan() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Row({ space: Theme.space.s2 }) {
        Column() {
          AppRingChart({
            title: '',
            percent: this.snap.plan.progressPercent() / 100
          })
        }
        .layoutWeight(1)
        Column({ space: Theme.space.s2 }) {
          AppStatCard({ label: '已阅读', value: `${this.snap.readCount}`, trend: '' })
          AppStatCard({ label: '连续打卡', value: `${this.snap.streak} 天`, trend: '' })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Row({ space: Theme.space.s2 }) {
        AppStatCard({ label: '深度掌握', value: `${this.snap.masterCount}`, trend: '' })
          .layoutWeight(1)
        AppStatCard({ label: '我的收藏', value: `${this.snap.favCount}`, trend: '' })
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: Theme.space.s2 }) {
        Row() {
          Text('今日任务')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(`${this.snap.tasks.doneCount()}/4`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
        }
        .width('100%')
        ForEach(this.taskChips(), (chip: TaskChip) => {
          Row({ space: Theme.space.s2 }) {
            AppIcon({
              name: chip.done ? 'check' : 'empty',
              iconSize: Theme.icon.sm,
              color: chip.done ? Theme.colors().success : Theme.colors().textTertiary
            })
            Text(chip.label)
              .fontSize(Theme.type.body)
              .fontColor(chip.done ? Theme.colors().textSecondary : Theme.colors().textPrimary)
              .layoutWeight(1)
            if (!chip.done) {
              Text('去完成')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
            }
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .onClick((): void => { this.openTask(chip.key) })
        }, (chip: TaskChip) => chip.key)
      }
      .width('100%')
      .padding(Theme.space.s4)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.card)

      Row({ space: Theme.space.s2 }) {
        this.QuickEntry('时间轴', 'clock', (): void => { CommonSenseDetailNav.openTimeline() })
        this.QuickEntry('成就', 'ai', (): void => { CommonSenseDetailNav.openAchievements() })
        this.QuickEntry('周回顾', 'calendar', (): void => { CommonSenseDetailNav.openReview() })
        this.QuickEntry('统计', 'chart', (): void => { CommonSenseDetailNav.openGrowth() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (this.snap.recentEvents.length > 0) {
        Column({ space: Theme.space.s2 }) {
          Row() {
            Text('最近动态')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('全部')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { CommonSenseDetailNav.openTimeline() })
          }
          .width('100%')
          ForEach(this.snap.recentEvents, (ev: LearningEvent) => {
            Row({ space: Theme.space.s2 }) {
              Text(this.eventIcon(ev.type))
                .fontSize(10)
                .fontColor(Theme.colors().brandOnPrimary)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.xs)
              Column({ space: 2 }) {
                Text(ev.title)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textPrimary)
                  .maxLines(1)
                Text(ev.summary)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .maxLines(1)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding({ top: 6, bottom: 6 })
          }, (ev: LearningEvent) => ev.id)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      }
    }
    .width('100%')
  }

  @Builder
  QuickEntry(label: string, icon: AppIconName, onTap: () => void) {
    Column({ space: 4 }) {
      AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      Text(label)
        .fontSize(11)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }
}
