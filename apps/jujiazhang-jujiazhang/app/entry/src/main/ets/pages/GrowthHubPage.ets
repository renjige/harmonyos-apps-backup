import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { FormSheetHeader } from '../components/design-system/FormSheetHeader'
import { ChoiceChip } from '../components/family/ChoiceChip'
import { ActivityEvent, AchievementDef } from '../models/JujiaModels'
import { ActivityService } from '../services/ActivityService'
import { AchievementService } from '../services/AchievementService'
import { ReviewService } from '../services/ReviewService'
import { TaskLocalStore } from '../services/TaskLocalStore'
import { TaskService } from '../services/TaskService'
import { TaskDates } from '../models/FamilyTaskModels'
import { JujiaLocalStore } from '../services/JujiaLocalStore'
import { CheckInService } from '../services/CheckInService'
import { FavoriteService } from '../services/FavoriteService'
import { CategorySuggest } from '../services/CategorySuggest'

@Component
export struct GrowthHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State segment: string = 'stats'
  @State weekRate: number = 0
  @State weekDone: number = 0
  @State weekTotal: number = 0
  @State review: string = ''
  @State activities: ActivityEvent[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    const all = TaskLocalStore.tasks()
    const week = TaskService.weekRows(all, TaskDates.today())
    this.weekTotal = week.length
    this.weekDone = TaskService.doneCount(week)
    this.weekRate = TaskService.progress(week)
    this.review = ReviewService.weekSummary()
    this.activities = ActivityService.recent(30)
  }

  private typeLabel(t: string): string {
    if (t === 'task') { return '计划' }
    if (t === 'item') { return '物品' }
    if (t === 'memo') { return '备忘' }
    if (t === 'checklist') { return '清单' }
    if (t === 'diary') { return '日记' }
    return t
  }

  build() {
    Column() {
      FormSheetHeader({ title: '家庭成长', onClose: () => this.onClose() })
      Scroll() {
        Row({ space: 8 }) {
          ChoiceChip({ label: '统计', active: this.segment === 'stats', onPick: () => { this.segment = 'stats' } })
          ChoiceChip({ label: '时间轴', active: this.segment === 'timeline', onPick: () => { this.segment = 'timeline' } })
          ChoiceChip({ label: '成就', active: this.segment === 'achievements', onPick: () => { this.segment = 'achievements' } })
          ChoiceChip({ label: '回顾', active: this.segment === 'review', onPick: () => { this.segment = 'review' } })
        }
        .padding({ left: 16, right: 16, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      Scroll() {
        Column({ space: 12 }) {
          if (this.segment === 'stats') {
            this.StatsPanel()
          }
          if (this.segment === 'timeline') {
            this.TimelinePanel()
          }
          if (this.segment === 'achievements') {
            this.AchievementPanel()
          }
          if (this.segment === 'review') {
            this.ReviewPanel()
          }
        }
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  StatsPanel() {
    Column({ space: 10 }) {
      Text('本周计划完成率')
        .fontSize(Theme.type.subtitleS)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row() {
        Text(`${this.weekRate}%`)
          .fontSize(Theme.type.displayS)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
        Text(`${this.weekDone}/${this.weekTotal} 项`)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .margin({ left: 12 })
      }
      .width('100%')
      Progress({ value: this.weekRate, total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(10)
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
      Row({ space: 8 }) {
        this.StatMini('物品', `${JujiaLocalStore.items().length}`)
        this.StatMini('备忘', `${JujiaLocalStore.memos().length}`)
        this.StatMini('收藏', `${FavoriteService.countAll()}`)
        this.StatMini('连续', `${CheckInService.streakDays()}天`)
      }
      .width('100%')
      ForEach(CategorySuggest.categories(), (cat: string) => {
        Row() {
          Text(cat)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(`${TaskService.categoryShare(TaskService.weekRows(TaskLocalStore.tasks(), TaskDates.today()), cat)}%`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      }, (cat: string) => cat)
    }
    .width('100%')
  }

  @Builder
  StatMini(label: string, value: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(Theme.type.body)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(10)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  TimelinePanel() {
    if (this.activities.length === 0) {
      Text('还没有动态，完成计划或创建内容后会出现在这里。')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
    } else {
      ForEach(this.activities, (ev: ActivityEvent) => {
        Row({ space: 8 }) {
          AppIcon({ name: 'clock', iconSize: 16, color: Theme.colors().textSecondary })
          Column({ space: 2 }) {
            Text(ev.title)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(`${ev.occurredAt.substring(0, 10)} ${ActivityService.formatTime(ev.occurredAt)} · ${this.typeLabel(ev.entityType)}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      }, (ev: ActivityEvent) => ev.id)
    }
  }

  @Builder
  AchievementPanel() {
    ForEach(AchievementService.defs(), (def: AchievementDef) => {
      Row({ space: 10 }) {
        AppIcon({
          name: def.iconName === 'star' ? 'ai' : 'check',
          iconSize: 20,
          color: AchievementService.isUnlocked(def.code) ? Theme.colors().brandPrimary : Theme.colors().textTertiary
        })
        Column({ space: 2 }) {
          Text(def.title)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(def.description)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text(AchievementService.isUnlocked(def.code) ? '已解锁' : '未解锁')
          .fontSize(Theme.type.caption)
          .fontColor(AchievementService.isUnlocked(def.code) ? Theme.colors().success : Theme.colors().textTertiary)
      }
      .width('100%')
      .padding(14)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
    }, (def: AchievementDef) => def.code)
  }

  @Builder
  ReviewPanel() {
    Column({ space: 8 }) {
      Text('本周回顾')
        .fontSize(Theme.type.subtitleS)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(this.review)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding(16)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      Text(ReviewService.monthHeadline())
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
  }
}
