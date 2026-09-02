import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ActionLog, StudyHabit, StudyPlan } from '../models/ZhixingModels'
import { ZhixingMedia } from '../services/ZhixingMedia'
import { ZhixingStore } from '../services/ZhixingStore'

@Component
export struct ActionPage {
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State plans: StudyPlan[] = []
  @State habits: StudyHabit[] = []
  @State logs: ActionLog[] = []
  @State rate: number = 0
  @State toastText: string = ''
  @State paintTick: number = 0
  onOpenPlan: (id: string) => void = (_id: string) => {}
  onOpenHabit: (id: string) => void = (_id: string) => {}
  onOpenLog: (id: string) => void = (_id: string) => {}
  onCreate: (kind: string) => void = (_k: string) => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onDataEpochChange(): void {
    void this.load()
  }

  private todayKey(): string {
    return ActionLog.formatDate(Date.now())
  }

  private isCheckedToday(h: StudyHabit): boolean {
    return h.lastCheckDate === this.todayKey()
  }

  private async load(): Promise<void> {
    const plans = await ZhixingStore.loadPlans()
    const habits = await ZhixingStore.loadHabits()
    const logs = await ZhixingStore.loadLogs()
    const nextPlans: StudyPlan[] = []
    for (const p of plans) {
      nextPlans.push(p.clone())
    }
    const nextHabits: StudyHabit[] = []
    for (const h of habits) {
      nextHabits.push(h.clone())
    }
    const nextLogs: ActionLog[] = []
    for (const l of logs) {
      nextLogs.push(l.clone())
    }
    this.plans = nextPlans
    this.habits = nextHabits
    this.logs = nextLogs
    this.rate = await ZhixingStore.planRate()
    this.paintTick = this.paintTick + 1
  }

  private async quickCheck(id: string): Promise<void> {
    const ok = await ZhixingStore.checkHabit(id)
    await this.load()
    this.onChanged()
    this.toastText = ok ? '打卡成功' : '今日已打卡'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  build() {
    Stack() {
      Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.themeEpoch >= 0 ? '行录' : '行录')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
            .padding({ top: Theme.space.s4 })

          Stack({ alignContent: Alignment.Center }) {
            Image(ZhixingMedia.image('banner_act'))
              .width('100%')
              .height(150)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(150)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,42,108,0.2)', 0], ['rgba(26,42,108,0.78)', 1]]
              })
            Column({ space: 8 }) {
              Progress({ value: this.rate, total: 100, type: ProgressType.Ring })
                .width(72)
                .height(72)
                .color(Theme.colors().brandAccent)
                .backgroundColor('rgba(255,255,255,0.2)')
              Text(`计划完成率 ${this.rate}%`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .opacity(this.paintTick >= 0 ? 1 : 1)
            }
          }
          .width('100%')
          .height(150)
          .clip(true)
          .borderRadius(Theme.radius.lg)

          Row() {
            Text('学习计划')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('新建')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.onCreate('plan') })
          }
          .width('100%')

          if (this.plans.length === 0) {
            AppEmpty({
              title: '还没有学习计划',
              description: '把一张知识卡片转化成可跟踪的目标',
              actionLabel: '新建计划',
              onAction: (): void => { this.onCreate('plan') }
            })
          } else {
            ForEach(this.plans, (p: StudyPlan) => {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(p.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`${p.progress}% · ${p.statusLabel()}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.onOpenPlan(p.id) })
            }, (p: StudyPlan) => `${p.id}_${p.progress}_${p.status}_${this.paintTick}`)
          }

          Text('习惯打卡')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          ForEach(this.habits, (h: StudyHabit) => {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Text(h.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                Text(this.isCheckedToday(h) ? `今日已打卡 · 连续 ${h.streak} 天` : `连续 ${h.streak} 天`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.isCheckedToday(h) ? Theme.colors().success : Theme.colors().textSecondary)
                this.WeekDots(h)
              }
              .layoutWeight(1)
              Column() {
                AppIcon({
                  name: this.isCheckedToday(h) ? 'check' : 'add',
                  iconSize: 18,
                  color: Theme.colors().brandOnPrimary
                })
              }
              .width(36)
              .height(36)
              .borderRadius(18)
              .backgroundColor(this.isCheckedToday(h) ? Theme.colors().success : Theme.colors().brandPrimary)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { void this.quickCheck(h.id) })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { this.onOpenHabit(h.id) })
          }, (h: StudyHabit) => `${h.id}_${h.streak}_${h.lastCheckDate}_${h.totalChecks}_${this.paintTick}`)

          this.AppButtonLike('新建习惯', (): void => { this.onCreate('habit') })

          Row() {
            Text('行动日志')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('写一条')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.onCreate('log') })
          }
          .width('100%')

          ForEach(this.logs, (l: ActionLog) => {
            Column({ space: 4 }) {
              Text(`${l.dateKey}  ${l.title}`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
              Text(l.body.length > 0 ? l.body : '无正文')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .maxLines(2)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { this.onOpenLog(l.id) })
          }, (l: ActionLog) => l.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 16 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .onVisibleAreaChange([0.4], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 0.4) {
        void this.load()
      }
    })
  }

  @Builder
  WeekDots(h: StudyHabit) {
    Row({ space: 5 }) {
      ForEach([0, 1, 2, 3, 4, 5, 6], (d: number) => {
        Column()
          .width(8)
          .height(8)
          .borderRadius(4)
          .backgroundColor(h.checkedAgo(6 - d) ? Theme.colors().success : Theme.colors().strokeStrong)
      }, (d: number) => `${h.id}_d${d}_${h.lastCheckDate}_${h.streak}`)
    }
  }

  @Builder
  AppButtonLike(label: string, tap: () => void) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(Theme.colors().brandPrimary)
      .width('100%')
      .textAlign(TextAlign.Center)
      .padding(12)
      .borderRadius(Theme.radius.md)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .onClick(tap)
  }
}
