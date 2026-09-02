import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { ActivityEvent } from '../../models/GrowthModels'
import { GrowthStore } from '../../services/GrowthStore'
import { LearnStore } from '../../services/LearnStore'
import { VaultStore } from '../../services/VaultStore'
import { AskNav } from '../../services/AskNav'

@Component
struct HomeQuickTile {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop icon: AppIconName = 'home'
  onTap: () => void = () => {}

  build() {
    Column({ space: 6 }) {
      AppIcon({
        name: this.icon,
        iconSize: Theme.icon.md,
        color: Theme.colors().brandPrimary
      })
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct HomeDashboard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop nick: string = '问知用户'
  @Prop dailyGoal: number = 3
  @Prop todayProgress: number = 0
  @Prop streakDays: number = 0
  @Prop askCount: number = 0
  @Prop quizCount: number = 0
  @Prop collectCount: number = 0
  @Prop checkedIn: boolean = false
  onCheckin: () => void = () => {}
  onOpenPlan: () => void = () => {}

  private progressPercent(): number {
    if (this.dailyGoal <= 0) {
      return 0
    }
    const p = this.todayProgress / this.dailyGoal
    return p > 1 ? 1 : p
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Column({ space: 4 }) {
          Text(`你好，${this.nick}`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('个人知识学习工作台')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      Column({ space: Theme.space.s3 }) {
        Text('今日学习进度')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Progress({
          value: this.todayProgress,
          total: this.dailyGoal > 0 ? this.dailyGoal : 1,
          type: ProgressType.Linear
        })
          .width('100%')
          .color(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
        Row() {
          Text(`已完成 ${this.todayProgress} / ${this.dailyGoal}`)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Blank()
          Text(`连续 ${this.streakDays} 天`)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        .width('100%')
        Row({ space: Theme.space.s2 }) {
          Text(this.checkedIn ? '今日已打卡 ✓' : '今日未打卡')
            .fontSize(Theme.type.footnote)
            .fontColor(this.checkedIn ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
            .layoutWeight(1)
          Text('查看计划 →')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandPrimary)
            .onClick(() => { this.onOpenPlan() })
        }
        .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.card)
      .onClick(() => { this.onOpenPlan() })

      Row({ space: Theme.space.s2 }) {
        this.StatTile(`${this.askCount}`, '提问')
        this.StatTile(`${this.quizCount}`, '答题')
        this.StatTile(`${this.collectCount}`, '收藏')
        this.StatTile(`${this.streakDays}天`, '连续')
      }
      .width('100%')

      Row({ space: Theme.space.s2 }) {
        HomeQuickTile({ label: '路径', icon: 'chart', onTap: (): void => { AskNav.switchTab(1) } })
        HomeQuickTile({ label: '闪卡', icon: 'bookmark', onTap: (): void => { AskNav.openLearn('flashcards') } })
        HomeQuickTile({ label: '计划', icon: 'check', onTap: (): void => { AskNav.openLearn('plan') } })
        HomeQuickTile({ label: '统计', icon: 'chart', onTap: (): void => { AskNav.openLearn('stats') } })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  StatTile(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}

@Component
export struct HomeRecentActivity {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop events: string[] = []

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('最近动态')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('全部')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => { AskNav.openLearn('timeline') })
      }
      .width('100%')
      if (this.events.length === 0) {
        Text('完成提问、阅读或答题后，这里会留下学习足迹')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.events, (line: string) => {
          Text(line)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }, (line: string) => line)
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}

export class HomeDashHelper {
  static formatActivityLines(): string[] {
    const recent: ActivityEvent[] = GrowthStore.recentActivities(3)
    const lines: string[] = []
    for (const e of recent) {
      lines.push(HomeDashHelper.timeLabel(e.createdAt) + ' · ' + e.title)
    }
    return lines
  }

  static syncStats(): HomeDashSnapshot {
    const s = new HomeDashSnapshot()
    s.dailyGoal = LearnStore.goal()
    s.todayProgress = LearnStore.todayCount()
    s.streakDays = VaultStore.streakDays()
    s.askCount = VaultStore.asks()
    s.quizCount = LearnStore.quizTimes()
    s.collectCount = VaultStore.count()
    s.checkedIn = GrowthStore.hasCheckinToday()
    s.nick = VaultStore.nick()
    return s
  }

  private static timeLabel(ms: number): string {
    const d = new Date(ms)
    const now = new Date()
    if (d.getDate() === now.getDate() && d.getMonth() === now.getMonth()) {
      return `${d.getHours()}:${d.getMinutes() < 10 ? '0' : ''}${d.getMinutes()}`
    }
    return `${d.getMonth() + 1}/${d.getDate()}`
  }
}

export class HomeDashSnapshot {
  dailyGoal: number = 3
  todayProgress: number = 0
  streakDays: number = 0
  askCount: number = 0
  quizCount: number = 0
  collectCount: number = 0
  checkedIn: boolean = false
  nick: string = '问知用户'
}
