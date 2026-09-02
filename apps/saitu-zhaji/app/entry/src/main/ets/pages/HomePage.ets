import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { WorkbenchSnapshot, TimelineEntry, TodoItem } from '../models/SaituGrowthModels'
import { SaituWorkbenchService } from '../services/SaituWorkbenchService'
import { SaituAchievementStore } from '../services/SaituAchievementStore'
import { SaituDetailNav } from '../services/SaituDetailNav'
import { DateHelper } from '../services/DateHelper'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituJourneyEpoch') @Watch('onJourneyEpochChange') journeyEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State snap: WorkbenchSnapshot = new WorkbenchSnapshot()
  @State toastText: string = ''
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onJourneyEpochChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async reload(): Promise<void> {
    this.loading = true
    const newly = await SaituAchievementStore.evaluateAndUnlock()
    if (newly.length > 0) {
      const defs = SaituAchievementStore.defs()
      for (const id of newly) {
        for (const d of defs) {
          if (d.id === id) {
            this.showToast(`解锁成就：${d.title}`)
            break
          }
        }
      }
    }
    this.snap = await SaituWorkbenchService.loadSnapshot()
    this.loading = false
  }

  private streakLabel(): string {
    const s = Math.max(this.snap.checkInStreak, this.snap.recordStreak)
    return s > 0 ? `${s} 天` : '—'
  }

  private openTodo(t: TodoItem): void {
    if (t.kind === 'milestone') {
      SaituDetailNav.openMilestone(t.refId)
      return
    }
    if (t.kind === 'sport_plan') {
      SaituDetailNav.openSportDetail(t.refId)
      return
    }
    if (t.kind === 'journey_plan') {
      SaituDetailNav.openPlan(t.refId)
    }
  }

  private openTimelineEntry(e: TimelineEntry): void {
    if (e.kind === 'record') {
      SaituDetailNav.openRecord(e.refId)
      return
    }
    if (e.kind === 'sport') {
      SaituDetailNav.openSportDetail(e.refId)
      return
    }
    if (e.kind === 'insight') {
      SaituDetailNav.openInsight(e.refId)
      return
    }
    if (e.kind === 'milestone') {
      SaituDetailNav.openMilestone(e.refId)
      return
    }
    if (e.kind === 'plan') {
      SaituDetailNav.openPlan(e.refId)
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_ambient'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(140)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0.55)', 0], ['rgba(0,0,0,0.72)', 1]]
              })
            Row() {
              Column({ space: 4 }) {
                Text('赛途工作台')
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text(`${this.snap.nickname} · 连续 ${this.streakLabel()}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor('#FFFFFF')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Text(`${this.snap.achievementUnlocked}/${this.snap.achievementTotal}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor('#FFFFFF')
                .borderRadius(Theme.radius.pill)
                .onClick((): void => AppStorage.setOrCreate('saituMainTab', 3))
            }
            .width('100%')
            .padding(Theme.space.pageX)
            .margin({ bottom: Theme.space.s3 })
          }
          .width('100%')
          .borderRadius(Theme.radius.lg)
          .clip(true)

          Column({ space: Theme.space.s3 }) {
            Text(this.snap.focusJourneyName.length > 0 ? this.snap.focusJourneyName : '今日赛途')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Row() {
              Row()
                .width(`${Math.max(8, Math.round(this.snap.focusProgress * 100))}%`)
                .height(10)
                .backgroundColor(this.snap.focusJourneyColor.length > 0 ? this.snap.focusJourneyColor :
                  Theme.colors().brandPrimary)
                .borderRadius(5)
            }
            .width('100%')
            .height(10)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(5)
            Text(this.snap.focusProgressLabel.length > 0 ? this.snap.focusProgressLabel :
              '创建旅途并设节点，进度会显示在这里')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Text(this.snap.todayCheckedIn ? '今日已打卡 ✓' : '今日尚未打卡')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.snap.todayCheckedIn ? Theme.colors().success : Theme.colors().brandPrimary)
              .width('100%')
            AppButton({
              label: this.snap.focusJourneyId.length > 0 ? '继续推进赛途' : '创建第一条赛途',
              variant: 'primary',
              onTap: (): void => {
                if (this.snap.focusJourneyId.length > 0) {
                  AppStorage.setOrCreate('saituMainTab', 2)
                } else {
                  SaituDetailNav.openJourneyManage()
                }
              }
            })
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '札记', value: `${this.snap.totalRecords}` })
            AppStatCard({ label: '赛事', value: `${this.snap.sportTotal}` })
            AppStatCard({ label: '训练', value: `${this.snap.trainingTotal}` })
            AppStatCard({ label: '连续', value: this.streakLabel() })
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Row() {
              Text('本周赛途摘要')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Blank()
              Text(DateHelper.weekRangeLabel())
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
            .width('100%')
            Text(`札记 ${this.snap.weekRecordCount} · 赛事 ${this.snap.weekSportCount} · 训练 ${this.snap.weekTrainingCount}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row() {
            Text('适用场景')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('查看全部')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => SaituDetailNav.openScenarioGuide())
          }
          .width('100%')
          Text('观赛复盘 · 训练日志 · 旅途推进 · 球队关注 · 打卡习惯 · 数据导出')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Text('快捷操作')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            this.QuickChip('札记', (): void => SaituDetailNav.openNewEditor())
            this.QuickChip('赛事', (): void => SaituDetailNav.openSportHub())
            this.QuickChip('训练', (): void => SaituDetailNav.openNewTrainingEditor())
            this.QuickChip('打卡', (): void => SaituDetailNav.openCheckInEditor(''))
          }
          .width('100%')

          if (this.snap.todos.length > 0) {
            Text('待办')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.snap.todos, (t: TodoItem) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 4 }) {
                  Text(t.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(t.subtitle)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => this.openTodo(t))
            }, (t: TodoItem) => t.id)
          }

          Row() {
            Text('最近动态')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('查看全部')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => SaituDetailNav.openTimeline())
          }
          .width('100%')

          if (this.loading) {
            Text('加载中…')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
          } else if (this.snap.recentTimeline.length === 0) {
            Column({ space: Theme.space.s3 }) {
              Image($r('app.media.empty_trail'))
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              AppEmpty({
                title: '还没有动态',
                description: '写札记、记赛事或打卡，动态会出现在这里'
              })
            }
            .width('100%')
          } else {
            ForEach(this.snap.recentTimeline, (e: TimelineEntry) => {
              Row({ space: Theme.space.s3 }) {
                Text(e.kindLabel())
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                Column({ space: 4 }) {
                  Text(e.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(e.subtitle)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => this.openTimelineEntry(e))
            }, (e: TimelineEntry) => e.id)
          }

          Blank().height(this.bottomInset + Theme.space.s6)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  QuickChip(label: string, action: () => void) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick((): void => action())
  }
}
