import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { HomeMissionBoard } from '../components/math/HomeMissionBoard'
import { HomeStatStrip } from '../components/math/HomeStatStrip'
import { HomeStudioRow } from '../components/math/HomeStudioRow'
import { HomeRecentStrip } from '../components/math/HomeRecentStrip'
import { HomeGoalCard } from '../components/math/HomeGoalCard'
import { HomeQuickGrid } from '../components/math/HomeQuickGrid'
import { HomeGuideCard } from '../components/math/HomeGuideCard'
import { MathBizService } from '../services/MathBizService'
import { MathCatalog } from '../services/MathCatalog'
import { MathLocalStore } from '../services/MathLocalStore'
import { MathDetailNav } from '../services/MathDetailNav'
import { MathRefresh } from '../services/MathRefresh'
import { DayMission, PracticeSession, WeakHint } from '../models/MathModels'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('mathHomeTick') @Watch('onHomeTickChange') dataTick: number = 0
  @StorageLink('mathStatsEpoch') @Watch('onHomeTickChange') statsEpoch: number = 0
  @State done: number = 0
  @State todayStars: number = 0
  @State totalStars: number = 0
  @State todayAcc: number = 0
  @State weekDone: number = 0
  @State weekTarget: number = 50
  @State recentSessions: PracticeSession[] = []
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('mathSettingsTick') @Watch('onSettingsTickChange') settingsTick: number = 0
  @State total: number = 10
  @State gradeName: string = '基础计算 6-8 岁'
  @State planText: string = ''
  @State towerText: string = ''
  @State favCount: number = 0
  @State weak: WeakHint = new WeakHint()
  @State missions: DayMission[] = []
  @State showGuide: boolean = false
  onStartDaily: () => void = () => {}
  onQuick: (mode: string) => void = (_m: string) => {}
  onWarm: () => void = () => {}
  onStory: () => void = () => {}
  onWeak: () => void = () => {}
  onPlan: () => void = () => {}
  onFav: () => void = () => {}
  onTable: () => void = () => {}
  onCustom: () => void = () => {}
  onPack: () => void = () => {}
  onCheckIn: () => void = () => {}
  onTimeline: () => void = () => {}
  onGoal: () => void = () => {}
  onReview: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  onSettingsTickChange(): void {
    this.reload()
  }

  onHomeTickChange(): void {
    this.reload()
  }

  private reload(): void {
    const stats = MathRefresh.readTodayStats()
    this.done = stats.todayDone
    this.todayStars = stats.todayStars
    this.totalStars = stats.totalStars
    this.todayAcc = stats.todayAcc
    this.weekDone = MathBizService.weekAnswered()
    this.weekTarget = MathBizService.goalTarget()
    this.recentSessions = MathBizService.lastSessions(3)
    this.total = MathLocalStore.settings().dailyCount
    this.gradeName = MathBizService.gradeLabel(MathLocalStore.settings().grade)
    this.weak = MathBizService.weakHint()
    this.favCount = MathLocalStore.snapshot().favorites.length
    this.missions = MathBizService.todayMissions()
    this.showGuide = MathLocalStore.snapshot().sessions.length === 0
    const clear = MathLocalStore.snapshot().challengeClear
    this.towerText = `数字认知 → 加减 → 乘除 → 应用题 · 已打通 ${clear} / 4 关`
    const idx = MathBizService.planIndex()
    if (idx < 0) {
      this.planText = '开启七日计划，每天一小步'
    } else if (idx >= 7) {
      this.planText = `已练 ${MathBizService.planDoneDays()} 天，可以再开一轮`
    } else {
      this.planText = `${MathCatalog.planDayTitle(idx)} · 已打卡 ${MathBizService.planDoneDays()} 天`
    }
  }

  private onMission(id: string): void {
    if (id === 'warm') {
      this.onWarm()
      return
    }
    if (id === 'daily') {
      this.onStartDaily()
      return
    }
    this.onTable()
  }

  private greet(): string {
    const h = new Date().getHours()
    if (h < 11) {
      return '早上好，小算术家 👋'
    }
    if (h < 18) {
      return '下午好，小算术家'
    }
    return '晚上好，小算术家'
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Column({ space: Theme.space.s2 }) {
          Text('童趣算坊')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('亲子口算学习工作台')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text(this.greet())
            .fontSize(Theme.type.subtitleM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text(`${this.gradeName}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
        }
        .padding({ top: Theme.space.s2 })
        .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_desk'))
            .width('100%')
            .height(240)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(160)
            .linearGradient({
              angle: 180,
              colors: [['rgba(23,32,51,0)', 0], ['rgba(23,32,51,0.78)', 1]]
            })
          Column({ space: Theme.space.s3 }) {
            Text('今日挑战')
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
              .width('100%')
            Text(`${this.total} 道计算题`)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width('100%')
            Text(`${this.done} / ${this.total}`)
              .fontSize(Theme.type.footnote)
              .fontColor('#FFFFFF')
              .width('100%')
            Stack({ alignContent: Alignment.Start }) {
              Row().width('100%').height(6).backgroundColor('rgba(255,255,255,0.28)').borderRadius(99)
              Row()
                .width(`${this.total > 0 ? Math.floor((this.done / this.total) * 100) : 0}%`)
                .height(6)
                .backgroundColor('#FFD54F')
                .borderRadius(99)
            }
            .width('100%')
            .height(6)
            AppButton({
              label: '开始计算',
              onTap: () => this.onStartDaily()
            })
          }
          .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
          .width('100%')
        }
        .width('100%')
        .height(280)
        .borderRadius(Theme.radius.sheet)
        .clip(true)

        if (this.showGuide) {
          HomeGuideCard({
            onCustom: () => this.onCustom(),
            onGoal: () => this.onGoal(),
            onReview: () => this.onReview()
          })
        }

        HomeMissionBoard({
          missions: this.missions,
          onMission: (id: string) => this.onMission(id)
        })

        HomeGoalCard({
          weekDone: this.weekDone,
          weekTarget: this.weekTarget,
          onOpen: () => this.onGoal()
        })

        HomeStudioRow({
          onCustom: () => this.onCustom(),
          onPack: () => this.onPack(),
          onCheckIn: () => this.onCheckIn(),
          onTimeline: () => this.onTimeline()
        })

        HomeStatStrip({
          todayStars: this.todayStars,
          totalStars: this.totalStars,
          done: this.done,
          todayAcc: this.todayAcc
        })

        HomeRecentStrip({ items: this.recentSessions })

        HomeQuickGrid({
          favCount: this.favCount,
          onWarm: () => this.onWarm(),
          onStory: () => this.onStory(),
          onTable: () => this.onTable(),
          onFav: () => this.onFav(),
          onGame: () => this.onQuick('game'),
          onReview: () => this.onReview(),
          onQuick: (mode: string) => this.onQuick(mode)
        })

        Column({ space: Theme.space.s2 }) {
          Image($r('app.media.cover_challenge'))
            .width('100%')
            .height(88)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          Text('数学闯关')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.towerText)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick(() => MathDetailNav.open('challenge', 'km_ch_cog'))

        Column({ space: Theme.space.s2 }) {
          Text('七日计划')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.planText)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick(() => this.onPlan())

        if (this.weak.count > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('需要加强')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`错题小本里 ${this.weak.title} 出现较多，点这里针对练一组`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .onClick(() => this.onWeak())
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
      .constraintSize({ maxWidth: 720 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .onVisibleAreaChange([0.0, 1.0], (visible: boolean, ratio: number) => {
      if (visible && ratio > 0) {
        this.reload()
      }
    })
  }
}
