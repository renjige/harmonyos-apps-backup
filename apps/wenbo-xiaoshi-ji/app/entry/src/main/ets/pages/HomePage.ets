import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { SceneChipRow } from '../components/moment/SceneChipRow'
import { ActivityEvent, DailyPrompt, HomeDashboard, LifePlan, ScenePreset, UserProfile } from '../models/MomentModels'
import { DateHelper } from '../services/DateHelper'
import { MomentStore } from '../services/MomentStore'
import { MomentNav } from '../services/MomentNav'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onSwitchTab: (index: number) => void = () => {}
  onOpenGrowth: () => void = () => {}
  @State dash: HomeDashboard = new HomeDashboard()
  @State profile: UserProfile = new UserProfile()
  @State activities: ActivityEvent[] = []
  @State plans: LifePlan[] = []
  @State prompt: string = ''
  @State todayLabel: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.todayLabel = DateHelper.displayLong(DateHelper.todayKey())
    this.prompt = DailyPrompt.today()
    this.profile = await MomentStore.loadProfile()
    this.dash = await MomentStore.loadDashboard()
    this.activities = await MomentStore.loadRecentActivities(6)
    const allPlans = await MomentStore.loadPlans()
    this.plans = []
    for (let i = 0; i < allPlans.length && i < 2; i++) {
      if (allPlans[i].status === 'active') {
        this.plans.push(allPlans[i])
      }
    }
  }

  private openScene(s: ScenePreset): void {
    AppStorage.setOrCreate('noteDraftSeed', s.seed)
    AppStorage.setOrCreate('noteDraftTag', s.tag)
    MomentNav.openEditor('')
  }

  private progressBarWidth(): string {
    const pct = this.dash.progressPct
    if (pct <= 0) {
      return '4%'
    }
    if (pct >= 100) {
      return '100%'
    }
    return `${pct}%`
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Column({ space: 4 }) {
            Text(`你好，${this.profile.nickname}`)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text(this.todayLabel)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => MomentNav.openSearch())
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_warm_desk'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius(16)
          Column()
            .width('100%')
            .height(168)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(45,45,45,0.72)', 1]]
            })
            .borderRadius(16)
          Column({ space: Theme.space.s3 }) {
            Text('今日进度')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .width('100%')
            Row() {
              Row()
                .width(this.progressBarWidth())
                .height(8)
                .backgroundColor('#FFFFFF')
                .borderRadius(Theme.radius.pill)
            }
            .width('100%')
            .height(8)
            .backgroundColor('rgba(255,255,255,0.28)')
            .borderRadius(Theme.radius.pill)
            Text(`待办 ${this.dash.todoDoneToday}/${this.dash.todoTotalToday} · ${this.dash.todayDone ? '已打卡' : '未打卡'}${this.dash.todayMood.length > 0 ? ` · ${this.dash.todayMood}` : ''}`)
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
              .width('100%')
            AppButton({
              label: this.dash.todoTotalToday > this.dash.todoDoneToday ? '继续完成待办' : '写今日小事',
              onTap: (): void => {
                if (this.dash.todoTotalToday > this.dash.todoDoneToday) {
                  this.onSwitchTab(2)
                } else {
                  MomentNav.openEditor('')
                }
              }
            })
          }
          .width('100%')
          .padding(16)
        }
        .width('100%')
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s2 }) {
          AppStatCard({ label: '记录', value: `${this.dash.noteCount}`, trend: '条', positive: true }).layoutWeight(1)
          AppStatCard({ label: '今日完成', value: `${this.dash.todoDoneToday}`, trend: '项', positive: true }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s2 }) {
          AppStatCard({ label: '星标', value: `${this.dash.starCount}`, trend: '条', positive: true }).layoutWeight(1)
          AppStatCard({ label: '连续', value: `${this.dash.streak}`, trend: '天', positive: true }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s2 }) {
          AppButton({ label: '记小事', onTap: (): void => MomentNav.openEditor('') }).layoutWeight(1)
          AppButton({ label: '加待办', variant: 'secondary', onTap: (): void => this.onSwitchTab(2) }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s2 }) {
          AppButton({ label: '写收束', variant: 'secondary', onTap: (): void => MomentNav.openDailyWrap() }).layoutWeight(1)
          AppButton({ label: '看成长', variant: 'secondary', onTap: (): void => this.onOpenGrowth() }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.calendar_window'))
            .width('100%')
            .height(96)
            .objectFit(ImageFit.Cover)
            .borderRadius(14)
          Column()
            .width('100%')
            .height(96)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(45,45,45,0.55)', 1]]
            })
            .borderRadius(14)
          Column({ space: 4 }) {
            Text('今日一句')
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
            Text(this.prompt)
              .fontSize(Theme.type.body)
              .fontColor('#FFFFFF')
              .lineHeight(22)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .padding(14)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .onClick((): void => {
          AppStorage.setOrCreate('noteDraftSeed', this.prompt)
          MomentNav.openEditor('')
        })

        SceneChipRow({ onPick: (s: ScenePreset): void => this.openScene(s) })

        if (this.plans.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('进行中的计划')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.plans, (p: LifePlan) => {
              Column({ space: 6 }) {
                Text(p.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(`${p.doneCount()}/${p.tasks.length} · ${p.progress()}%`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(12)
              .onClick((): void => MomentNav.openPlan(p.id))
            }, (p: LifePlan) => `${p.id}_${p.updatedAt}`)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column({ space: Theme.space.s2 }) {
          Row() {
            Text('最近动态')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('时光轴')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => this.onOpenGrowth())
          }
          .width('100%')
          if (this.activities.length === 0) {
            Text('记下第一件小事，这里会出现你的生活轨迹')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.activities, (e: ActivityEvent) => {
              Row({ space: Theme.space.s2 }) {
                Text(e.typeLabel())
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandAccent)
                  .width(36)
                Text(e.summary.length > 0 ? e.summary : e.title)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 6, bottom: 6 })
              .onClick((): void => {
                if (e.type === 'note' || e.type === 'star') {
                  MomentNav.openNote(e.refId)
                } else if (e.type === 'todo_done') {
                  MomentNav.openTodo(e.refId)
                }
              })
            }, (e: ActivityEvent) => `${e.id}_${e.createdAt}`)
          }
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(16)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        AppButton({
          label: '新建生活计划',
          variant: 'secondary',
          onTap: (): void => MomentNav.openPlanEditor('')
        })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row().height(this.bottomInset + 16)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
