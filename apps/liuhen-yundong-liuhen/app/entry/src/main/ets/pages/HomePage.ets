import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { WorkoutRecord } from '../models/WorkoutModels'
import { DateHelper } from '../services/DateHelper'
import { WorkoutStore } from '../services/WorkoutStore'
import { StatsService } from '../services/StatsService'
import { InsightService } from '../services/InsightService'
import { HabitStore } from '../services/HabitStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('homeStatsEpoch') @Watch('onHomeStatsEpochChange') homeStatsEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 88
  onStartWorkout: () => void = () => {}
  onOpenDetail: (record: WorkoutRecord) => void = () => {}
  @State monthTarget: number = 20
  @State weekGoal: number = 3
  @State streak: number = 0
  @State checkStreak: number = 0
  @State checkedToday: boolean = false
  @State insight: string = ''
  @State weekCount: number = 0
  @State weekMinutes: number = 0
  @State weekAvg: number = 0
  @State weekMax: number = 0
  @State monthCount: number = 0
  @State weekRangeLabel: string = ''
  @State latestMinutes: number = 0
  @State latestDistance: number = 0
  @State latestDateKey: string = ''
  @State latestId: string = ''
  @State latestInWeekFlag: number = 0

  aboutToAppear(): void {
    this.syncHomeStatsFromStorage()
    void this.loadAuxiliaryStats()
  }

  onPageShow(): void {
    this.syncHomeStatsFromStorage()
    void this.loadAuxiliaryStats()
  }

  onRefreshTokenChange(): void {
    this.syncHomeStatsFromStorage()
    void this.loadAuxiliaryStats()
  }

  onDataEpochChange(): void {
    this.syncHomeStatsFromStorage()
    void this.loadAuxiliaryStats()
  }

  onHomeStatsEpochChange(): void {
    this.syncHomeStatsFromStorage()
  }

  private syncHomeStatsFromStorage(): void {
    this.weekCount = AppStorage.get<number>('homeWeekCount') ?? 0
    this.weekMinutes = AppStorage.get<number>('homeWeekMinutes') ?? 0
    this.weekAvg = AppStorage.get<number>('homeWeekAvg') ?? 0
    this.weekMax = AppStorage.get<number>('homeWeekMax') ?? 0
    this.monthCount = AppStorage.get<number>('homeMonthCount') ?? 0
    const range = AppStorage.get<string>('homeWeekRange')
    this.weekRangeLabel = range !== undefined ? range : ''
    this.latestMinutes = AppStorage.get<number>('homeLatestMinutes') ?? 0
    this.latestDistance = AppStorage.get<number>('homeLatestDistance') ?? 0
    const dk = AppStorage.get<string>('homeLatestDateKey')
    this.latestDateKey = dk !== undefined ? dk : ''
    const lid = AppStorage.get<string>('homeLatestId')
    this.latestId = lid !== undefined ? lid : ''
    this.latestInWeekFlag = AppStorage.get<number>('homeLatestInWeek') ?? 0
  }

  private async loadAuxiliaryStats(): Promise<void> {
    this.streak = await StatsService.streakDays()
    this.insight = await InsightService.weeklyInsight()
    const settings = await WorkoutStore.loadSettings()
    this.monthTarget = settings.monthTarget
    this.weekGoal = settings.weeklyGoal
    this.checkedToday = await HabitStore.hasCheckin(DateHelper.todayKey())
    this.checkStreak = await HabitStore.checkinStreak()
  }

  private async doCheckin(): Promise<void> {
    await HabitStore.checkInToday()
    await this.loadAuxiliaryStats()
  }

  private async openLatestDetail(): Promise<void> {
    if (this.latestId.length === 0) {
      this.onStartWorkout()
      return
    }
    const rec = await WorkoutStore.findById(this.latestId)
    if (rec !== undefined) {
      this.onOpenDetail(rec)
      return
    }
    this.onStartWorkout()
  }

  private hasLatest(): boolean {
    return this.latestId.length > 0 && this.latestDateKey.length > 0
  }

  private latestInWeek(): boolean {
    return this.latestInWeekFlag === 1
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.TopStart }) {
          Image($r('app.media.hero_trace'))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column() {
            Blank()
            Column({ space: Theme.space.s3 }) {
              Text(`本月运动 ${this.monthCount} 次`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(`目标 ${this.monthCount}/${this.monthTarget} · 连续运动 ${this.streak} 天`)
                .fontSize(Theme.type.bodyS)
                .fontColor('#FFFFFF')
              Row() {
                Column() {
                  Text('开始运动')
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().brandPrimary)
                }
                .width(120)
                .height(120)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#FFFFFF')
                .borderRadius(60)
                .border({ width: 3, color: Theme.colors().brandPrimary })
                .onClick((): void => { this.onStartWorkout() })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .padding(Theme.space.s5)
            .linearGradient({
              angle: 180,
              colors: [['#00000000', 0], ['#DD1A1A2E', 0.55], ['#EE1A1A2E', 1]]
            })
          }
          .width('100%')
          .height(220)
        }

        Text(this.insight)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .padding({ left: Theme.space.s1, right: Theme.space.s1 })

        Row() {
          Column({ space: 4 }) {
            Text(this.checkedToday ? '今日已打卡' : '今日运动打卡')
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text(`连续打卡 ${this.checkStreak} 天 · 本周 ${this.weekCount}/${this.weekGoal} 次`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Text(this.checkedToday ? '已完成' : '打卡')
            .fontSize(Theme.type.bodyS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.checkedToday ? Theme.colors().textSecondary : Theme.colors().brandOnPrimary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.checkedToday ? Theme.colors().surfaceSubtle : Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { void this.doCheckin() })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Text('本周数据')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(`${this.weekRangeLabel} · 仅统计本周一至周日`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')

        Row({ space: Theme.space.s2 }) {
          Column({ space: 4 }) {
            Text(`${this.weekCount}`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('次数')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: 4 }) {
            Text(`${this.weekMinutes}分`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('总时长')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          Column({ space: 4 }) {
            Text(`${this.weekAvg}分`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('平均时长')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: 4 }) {
            Text(`${this.weekMax}分`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('最长单次')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }
        .width('100%')
        .id(`week_stats_${this.homeStatsEpoch}_${this.dataEpoch}`)

        Row({ space: Theme.space.s3 }) {
          Image($r('app.media.empty_calm'))
            .width(72)
            .height(72)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          Column({ space: 4 }) {
            Text('最近一次')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            if (this.hasLatest()) {
              Text(`${this.latestMinutes} 分钟 · ${this.latestDistance} km`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
              Text(DateHelper.displayDate(this.latestDateKey))
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
              if (!this.latestInWeek()) {
                Text('该记录日期不在本周，不计入上方统计')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
              }
            } else {
              Text('暂无记录，开始第一次运动吧')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          if (this.hasLatest()) {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
          }
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onClick((): void => { void this.openLatestDetail() })

        if (!this.hasLatest()) {
          AppEmpty({
            title: '还没有运动记录',
            description: '点击上方卡片或「开始运动」留下第一道痕迹',
            actionLabel: '开始运动',
            onAction: (): void => { this.onStartWorkout() }
          })
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: this.bottomInset
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
