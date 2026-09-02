import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { WeekActivityStrip } from '../components/fitness/WeekActivityStrip'
import { WeekCompareCard } from '../components/fitness/WeekCompareCard'
import { QuickTemplate } from '../models/TrainingModels'
import { UserProfile, WeekCompareSnapshot, WorkoutTypeOption } from '../models/WorkoutModels'
import { DateHelper } from '../services/DateHelper'
import { PlanStore } from '../services/PlanStore'
import { StatsService } from '../services/StatsService'
import { TemplateStore } from '../services/TemplateStore'
import { TrainingStore } from '../services/TrainingStore'
import { WisdomService } from '../services/WisdomService'
import { WorkoutStore } from '../services/WorkoutStore'

class HomeShot {
  key: string = ''
  label: string = ''
  icon: AppIconName = 'check'

  static all(): HomeShot[] {
    const out: HomeShot[] = []
    const rows: string[][] = [
      ['log', '训练记录', 'check'],
      ['atlas', '动作图鉴', 'search'],
      ['challenge', '挑战中心', 'ai'],
      ['growth', '成长报告', 'chart']
    ]
    for (const row of rows) {
      const s = new HomeShot()
      s.key = row[0]
      s.label = row[1]
      s.icon = row[2] as AppIconName
      out.push(s)
    }
    return out
  }
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('fitDataEpoch') @Watch('onDataEpochChange') fitDataEpoch: number = 0
  @Link @Watch('onRefreshTokenChange') refreshToken: number
  @Prop bottomInset: number = 76
  onRecord: () => void = () => {}
  onOpenDetail: (id: string) => void = () => {}
  onOpenWeekPlan: () => void = () => {}
  onGoPlan: () => void = () => {}
  onGoAtlas: () => void = () => {}
  onGoGrowth: () => void = () => {}
  onOpenHistory: () => void = () => {}
  onOpenDay: (dateKey: string) => void = () => {}
  onQuickTemplate: (typeKey: string, minutes: number, title: string) => void = () => {}
  @State nickname: string = '运动达人'
  @State totalWorkouts: number = 0
  @State streakDays: number = 0
  @State goalsDone: number = 0
  @State statTick: number = 0
  @State todayTitle: string = '尚未安排今日主题'
  @State todayProgress: number = 0
  @State todayMinutes: number = 0

  @State advice: string = ''
  @State recentId: string = ''
  @State recentLine: string = ''
  @State weekKeys: string[] = []
  @State weekActive: string[] = []
  @State weekSnap: WeekCompareSnapshot = new WeekCompareSnapshot()
  @State templates: QuickTemplate[] = []
  @State lastRepeatLine: string = ''
  @State hasLastWorkout: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataEpochChange(): void {
    void this.reload()
  }

  private async reloadStats(): Promise<void> {
    const totals = await StatsService.totals()
    this.totalWorkouts = totals.totalWorkouts
    this.streakDays = totals.streakDays
    this.todayMinutes = totals.todayMinutes
    const unlocked = await WorkoutStore.loadUnlockedAchievements()
    const ch = await TrainingStore.loadChallenges()
    let chDone = 0
    for (const c of ch) {
      if (c.done) {
        chDone++
      }
    }
    this.goalsDone = unlocked.length + chDone
    this.statTick++
  }

  private async reloadTodayProgress(): Promise<void> {
    const slot = await PlanStore.todaySlot()
    if (slot !== undefined && slot.enabled) {
      this.todayTitle = `${WorkoutTypeOption.labelFor(slot.typeKey)} · ${slot.targetMinutes} 分钟`
      const t = slot.targetMinutes > 0 ? slot.targetMinutes : 30
      const p = Math.round((this.todayMinutes / t) * 100)
      this.todayProgress = p > 100 ? 100 : p
    } else {
      this.todayTitle = '去计划中心安排今天'
      this.todayProgress = this.todayMinutes > 0 ? 40 : 0
    }
  }

  private async reload(): Promise<void> {
    await TrainingStore.ensureTemplates()
    await this.reloadStats()
    const profile: UserProfile = await WorkoutStore.loadProfile()
    this.nickname = profile.nickname
    await this.reloadTodayProgress()
    this.advice = await WisdomService.adviceLine()
    const today = await WorkoutStore.workoutsForDate(DateHelper.todayKey())
    if (today.length > 0) {
      this.recentId = today[0].id
      const title = today[0].sessionTitle.length > 0 ? today[0].sessionTitle : WorkoutTypeOption.labelFor(today[0].typeKey)
      this.recentLine = `${title} · ${today[0].durationMinutes} 分钟`
    } else {
      this.recentId = ''
      this.recentLine = ''
    }
    this.weekKeys = DateHelper.weekDateKeys(DateHelper.todayKey())
    this.weekActive = []
    for (const k of this.weekKeys) {
      const day = await WorkoutStore.workoutsForDate(k)
      if (day.length > 0) {
        this.weekActive.push(k)
      }
    }
    this.weekSnap = await StatsService.weekCompareSnapshot()
    this.templates = await TemplateStore.list()
    const last = await TemplateStore.lastWorkout()
    if (last !== undefined) {
      this.hasLastWorkout = true
      const name = last.sessionTitle.length > 0 ?
        last.sessionTitle : WorkoutTypeOption.labelFor(last.typeKey)
      this.lastRepeatLine = `${name} · ${last.durationMinutes} 分钟`
    } else {
      this.hasLastWorkout = false
      this.lastRepeatLine = ''
    }
  }

  private tapShot(key: string): void {
    if (key === 'log') {
      this.onRecord()
      return
    }
    if (key === 'atlas') {
      this.onGoAtlas()
      return
    }
    if (key === 'challenge') {
      this.onGoPlan()
      return
    }
    this.onGoGrowth()
  }

  private async repeatLast(): Promise<void> {
    const last = await TemplateStore.lastWorkout()
    if (last === undefined) {
      return
    }
    const name = last.sessionTitle.length > 0 ?
      last.sessionTitle : WorkoutTypeOption.labelFor(last.typeKey)
    this.onQuickTemplate(last.typeKey, last.durationMinutes, name)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_workout'))
            .width('100%')
            .height(176)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Column()
            .width('100%')
            .height(176)
            .borderRadius(Theme.radius.lg)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,35,50,0.08)', 0], ['rgba(26,35,50,0.82)', 1]]
            })
          Column({ space: Theme.space.s1 }) {
            Text('体能图志')
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
            Text('今天保持活力了吗？')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(`${this.nickname} · 连续训练 ${this.streakDays} 天`)
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
          }
          .padding({ left: Theme.space.s4, bottom: Theme.space.s4, right: Theme.space.s4 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          Column({ space: 4 }) {
            Text(`${this.totalWorkouts}`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
            Text('累计训练')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .alignItems(HorizontalAlign.Center)

          Column({ space: 4 }) {
            Text(`${this.streakDays}`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
            Text('坚持天数')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .alignItems(HorizontalAlign.Center)

          Column({ space: 4 }) {
            Text(`${this.goalsDone}`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
            Text('完成目标')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .key(`home-stats-${this.statTick}`)

        WeekActivityStrip({
          dayKeys: this.weekKeys,
          activeKeys: this.weekActive,
          onDayTap: (dateKey: string): void => { this.onOpenDay(dateKey) }
        })
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

        WeekCompareCard({
          thisMinutes: this.weekSnap.thisMinutes,
          lastMinutes: this.weekSnap.lastMinutes,
          thisDays: this.weekSnap.thisDays
        })
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

        Column({ space: Theme.space.s2 }) {
          Image($r('app.media.ambient_chart'))
            .width('100%')
            .height(56)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          Text('今日计划')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.todayTitle)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`完成进度 ${this.todayProgress}% · 已练 ${this.todayMinutes} 分钟`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppButton({
                label: '记录训练',
                variant: 'primary',
                onTap: (): void => this.onRecord()
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '编排周训',
                variant: 'secondary',
                onTap: (): void => this.onOpenWeekPlan()
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Column({ space: Theme.space.s2 }) {
          Text('智慧训练助手')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.advice)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(20)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.lg)

        Column({ space: Theme.space.s2 }) {
          Text('快捷再练')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.hasLastWorkout) {
            Row() {
              Text(`重复上次：${this.lastRepeatLine}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
              AppIcon({ name: 'refresh', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
            }
            .width('100%')
            .constraintSize({ minHeight: 44 })
            .onClick((): void => {
              void this.repeatLast()
            })
          }
          if (this.templates.length > 0) {
            ForEach(this.templates, (t: QuickTemplate) => {
              Row() {
                Text(t.displayLine())
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .constraintSize({ minHeight: 44 })
              .onClick((): void => {
                this.onQuickTemplate(t.typeKey, t.durationMinutes,
                  t.sessionTitle.length > 0 ? t.sessionTitle : t.title)
              })
            }, (t: QuickTemplate) => t.id)
          } else if (!this.hasLastWorkout) {
            Text('保存训练后会自动生成快捷模板，一键复练常见项目。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          Text('浏览全部训练日志')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
            .constraintSize({ minHeight: 44 })
            .onClick((): void => { this.onOpenHistory() })
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Text('快捷入口')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(HomeShot.all(), (s: HomeShot) => {
            Column({ space: Theme.space.s2 }) {
              AppIcon({ name: s.icon, iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
              Text(s.label)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textPrimary)
            }
            .width('47%')
            .padding(Theme.space.s4)
            .margin({ bottom: Theme.space.s3 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .constraintSize({ minHeight: 88 })
            .onClick((): void => { this.tapShot(s.key) })
          }, (s: HomeShot) => s.key)
        }
        .width('100%')

        if (this.recentId.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('今日日志')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Row() {
              Text(this.recentLine)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
            }
            .width('100%')
            .onClick((): void => { this.onOpenDetail(this.recentId) })
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }

        Row().height(this.bottomInset)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
