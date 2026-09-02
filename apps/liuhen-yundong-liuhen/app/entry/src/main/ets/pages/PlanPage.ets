import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { PrepList, SportChallenge, SportPlan, TipNote } from '../models/HabitModels'
import { DateHelper } from '../services/DateHelper'
import { HabitStore } from '../services/HabitStore'
import { StatsService } from '../services/StatsService'
import { WorkoutStore } from '../services/WorkoutStore'
import { PrepTipsBlock } from '../components/habit/PrepTipsBlock'
import { BodyLogBlock } from '../components/habit/BodyLogBlock'

@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 88
  @State checkedToday: boolean = false
  @State checkStreak: number = 0
  @State monthCount: number = 0
  @State monthTarget: number = 20
  @State weekCount: number = 0
  @State weekGoal: number = 3
  @State plans: SportPlan[] = []
  @State challenges: SportChallenge[] = []
  @State lists: PrepList[] = []
  @State tips: TipNote[] = []
  @State planTitle: string = ''
  @State planKind: string = 'weekly'
  @State planTarget: string = '3'
  @State toastText: string = ''
  @State weekendCount: number = 0
  @State streakDays: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onPageShow(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataEpochChange(): void {
    void this.reload()
  }

  private listRevisionKey(): string {
    let key = ''
    for (const list of this.lists) {
      key += `${list.id}:${list.checks}|`
    }
    return key
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.checkedToday = await HabitStore.hasCheckin(DateHelper.todayKey())
    this.checkStreak = await HabitStore.checkinStreak()
    this.streakDays = await StatsService.streakDays()
    const month = await StatsService.monthStats()
    this.monthCount = month.count
    const week = await StatsService.weekStats()
    this.weekCount = week.count
    const settings = await WorkoutStore.loadSettings()
    this.monthTarget = settings.monthTarget
    this.weekGoal = settings.weeklyGoal
    this.weekendCount = await StatsService.weekendSessionsThisMonth()
    this.plans = await HabitStore.loadPlans()
    this.challenges = await HabitStore.loadChallenges()
    this.lists = await HabitStore.loadLists()
    this.tips = await HabitStore.loadTips()
  }

  private planDone(p: SportPlan): number {
    if (p.kind === 'weekly') {
      return this.weekCount
    }
    if (p.kind === 'month') {
      return this.monthCount
    }
    return this.streakDays
  }

  private challengeProgress(c: SportChallenge): string {
    if (c.kind === 'd7') {
      return `${Math.min(this.streakDays, 7)} / 7 天`
    }
    if (c.kind === 'd21') {
      return `${Math.min(this.streakDays, 21)} / 21 天`
    }
    return `${this.weekendCount} 次周末运动`
  }

  private async doCheckin(): Promise<void> {
    const ok = await HabitStore.checkInToday()
    this.showToast(ok ? '今日打卡已记下' : '今天已经打过卡了')
    await this.reload()
  }

  private async addPlan(): Promise<void> {
    const t = parseInt(this.planTarget, 10)
    if (this.planTitle.trim().length < 2 || t !== t || t < 1) {
      this.showToast('请填写计划名称和目标次数')
      return
    }
    await HabitStore.savePlan(SportPlan.make(this.planTitle.trim(), this.planKind, t))
    this.planTitle = ''
    this.showToast('运动计划已创建')
    await this.reload()
  }

  private async startChallenge(c: SportChallenge): Promise<void> {
    c.started = DateHelper.todayKey()
    c.done = 0
    await HabitStore.saveChallenge(c)
    this.showToast('挑战已开始')
    await this.reload()
  }

  private async finishChallenge(c: SportChallenge): Promise<void> {
    c.done = 1
    await HabitStore.saveChallenge(c)
    this.showToast('挑战已完成')
    await this.reload()
  }

  @Builder
  KindChip(label: string, kind: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.planKind === kind ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.planKind === kind ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.planKind = kind })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('计划与习惯')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              Text(this.checkedToday ? '今日已打卡' : '今日还未打卡')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(`连续打卡 ${this.checkStreak} 天`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            AppButton({
              label: this.checkedToday ? '已完成' : '立即打卡',
              variant: this.checkedToday ? 'secondary' : 'primary',
              onTap: (): void => { void this.doCheckin() }
            })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: 6 }) {
            Text(`本月目标 ${this.monthCount} / ${this.monthTarget} 次`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(`本周 ${this.weekCount} / ${this.weekGoal} 次 · 连续运动 ${this.streakDays} 天`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          BodyLogBlock({
            onChanged: (): void => { void this.reload() }
          })

          Text('运动计划')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          TextInput({ text: this.planTitle, placeholder: '例如：每周拉伸 3 次' })
            .onChange((v: string): void => { this.planTitle = v })
          Row({ space: Theme.space.s2 }) {
            this.KindChip('每周', 'weekly')
            this.KindChip('每月', 'month')
            this.KindChip('连续天', 'streak')
          }
          TextInput({ text: this.planTarget, placeholder: '目标次数' })
            .onChange((v: string): void => { this.planTarget = v })
          AppButton({ label: '创建计划', variant: 'secondary', onTap: (): void => { void this.addPlan() } })

          if (this.plans.length === 0) {
            AppEmpty({ title: '还没有计划', description: '设一个可执行的小目标，比空喊坚持更有用' })
          } else {
            Column({ space: Theme.space.s2 }) {
              ForEach(this.plans, (p: SportPlan) => {
                Row() {
                  Column({ space: 2 }) {
                    Text(p.title)
                      .fontSize(Theme.type.body)
                      .fontColor(Theme.colors().textPrimary)
                    Text(`${p.kindLabel()} · ${this.planDone(p)} / ${p.target}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  Text('删除')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick((): void => { void HabitStore.deletePlan(p.id).then((): void => { void this.reload() }) })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
              }, (p: SportPlan) => p.id)
            }
          }

          Text('运动挑战')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Column({ space: Theme.space.s2 }) {
            ForEach(this.challenges, (c: SportChallenge) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text(c.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(c.done === 1 ? '已完成' : this.challengeProgress(c))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                if (c.done === 1) {
                  AppIcon({ name: 'check', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                } else if (c.isStarted()) {
                  Text('完成')
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick((): void => { void this.finishChallenge(c) })
                } else {
                  Text('开始')
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick((): void => { void this.startChallenge(c) })
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
            }, (c: SportChallenge) => c.id)
          }

          PrepTipsBlock({
            lists: this.lists,
            tips: this.tips,
            onChanged: (): void => { void this.reload() }
          })
          .key(`prep_${this.dataEpoch}_${this.listRevisionKey()}`)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: this.bottomInset
        })
      }
      .scrollBar(BarState.Off)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.88)')
          .borderRadius(Theme.radius.pill)
          .position({ top: 48 })
          .zIndex(80)
      }
    }
    .width('100%')
    .height('100%')
  }
}
