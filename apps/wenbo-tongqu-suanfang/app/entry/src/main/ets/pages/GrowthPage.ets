import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { CatalogItem, DayMark, MedalView, WeekBar } from '../models/MathModels'
import { MathBizService } from '../services/MathBizService'
import { MathCatalog } from '../services/MathCatalog'
import { MathDetailNav } from '../services/MathDetailNav'
import { MathMedia } from '../services/MathMedia'
import { MathLocalStore } from '../services/MathLocalStore'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('mathHomeTick') @Watch('onHomeTickChange') dataTick: number = 0
  @StorageLink('mathTotalStars') stars: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State sessions: number = 0
  @State accuracy: number = 0
  @State streak: number = 0
  @State bars: WeekBar[] = []
  @State medals: MedalView[] = []
  @State marks: DayMark[] = []
  @State planLine: string = ''
  @State weakLine: string = ''
  @State goalLine: string = ''
  @State archiveLine: string = ''
  onPlan: () => void = () => {}
  onWeak: () => void = () => {}
  onTimeline: () => void = () => {}
  onGoal: () => void = () => {}
  onReview: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
    void this.loadMedals()
  }

  onRefreshTokenChange(): void {
    this.reload()
    void this.loadMedals()
  }

  onHomeTickChange(): void {
    this.reload()
    void this.loadMedals()
  }

  private reload(): void {
    const g = MathBizService.growth()
    this.sessions = g.sessions
    this.accuracy = g.accuracy
    this.streak = g.streak
    this.bars = MathBizService.weekBars()
    this.marks = MathBizService.monthMarks()
    const idx = MathBizService.planIndex()
    if (idx < 0) {
      this.planLine = '还没有七日计划，点这里开启'
    } else if (idx >= 7) {
      this.planLine = `本轮完成 ${MathBizService.planDoneDays()} 天，可以再开一轮`
    } else {
      this.planLine = `${MathCatalog.planDayTitle(idx)} · 已打卡 ${MathBizService.planDoneDays()} / 7`
    }
    const w = MathBizService.weakHint()
    this.weakLine = w.count > 0 ? `最近 ${w.title} 需要多练一练` : '暂时没有待加强的题型'
    const set = MathLocalStore.settings()
    this.goalLine = `本周 ${MathBizService.weekAnswered()} / ${MathBizService.goalTarget()} 题 · ${MathBizService.gradeLabel(set.grade)}`
    this.archiveLine = `累计作答 ${g.answered} 题，答对 ${g.correct} 题`
  }

  private async loadMedals(): Promise<void> {
    let defs: CatalogItem[] = await MathBizService.loadMedals()
    if (defs.length < MathCatalog.medals().length) {
      defs = MathCatalog.medals()
    }
    this.medals = MathBizService.medalViews(defs)
  }

  private maxBar(): number {
    let m = 1
    for (const b of this.bars) {
      if (b.value > m) {
        m = b.value
      }
    }
    return m
  }

  build() {
    Stack() {
      Scroll() {
      Column({ space: Theme.space.s6 }) {
        Text('我的成长')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ top: Theme.space.s2 })

        Column({ space: Theme.space.s2 }) {
          Text('⭐')
            .fontSize(28)
            .width('100%')
            .textAlign(TextAlign.Center)
          Text(`${this.stars}`)
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .textAlign(TextAlign.Center)
          Text('累计星星')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: Theme.space.s4, bottom: Theme.space.s4 })

        if (this.sessions === 0) {
          AppEmpty({
            title: '开始第一次练习',
            description: '完成第一次练习后，这里会记录你的成长。'
          })
        }

        Row({ space: Theme.space.s3 }) {
          this.kpi('练习次数', `${this.sessions}`)
          this.kpi('平均正确率', this.sessions > 0 ? `${this.accuracy}%` : '—')
          this.kpi('连续练习', `${this.streak} 天`)
        }
        .width('100%')

        Column({ space: Theme.space.s2 }) {
          Text('亲子辅导')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.goalLine)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text('今日 / 本周 / 本月回顾，可复制给家长。不排名，不承诺成绩。')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick(() => this.onReview())

        Column({ space: Theme.space.s2 }) {
          Text('学习成长档案')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.archiveLine)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)

        Column({ space: Theme.space.s2 }) {
          Text('本周目标')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.goalLine)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick(() => this.onGoal())

        Column({ space: Theme.space.s2 }) {
          Text('练习时间轴')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('按日期查看挑战、打卡和家长出题')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick(() => this.onTimeline())

        Column({ space: Theme.space.s2 }) {
          Text('七日计划')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.planLine)
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

        Column({ space: Theme.space.s2 }) {
          Text('需要加强')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.weakLine)
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

        Column({ space: Theme.space.s3 }) {
          Text('近四周打卡')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.marks, (d: DayMark) => {
              Column()
                .width(18)
                .height(18)
                .margin({ right: 6, bottom: 6 })
                .borderRadius(6)
                .backgroundColor(d.done ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            }, (d: DayMark) => d.date)
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)

        Column({ space: Theme.space.s3 }) {
          Text('本周练习')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            ForEach(this.bars, (b: WeekBar) => {
              Column({ space: Theme.space.s1 }) {
                Column()
                  .width('100%')
                  .height(8 + 100 * (b.value / this.maxBar()))
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.sm)
                  .opacity(b.value > 0 ? 1 : 0.2)
                Text(b.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.End)
              .height(140)
            }, (b: WeekBar) => b.label)
          }
          .width('100%')
          .alignItems(VerticalAlign.Bottom)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)

        Column({ space: Theme.space.s3 }) {
          Text('我的勋章')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.unlockedCount() === 0) {
            Text('继续挑战，解锁第一枚勋章')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.medals, (m: MedalView) => {
              Column({ space: Theme.space.s2 }) {
                Image(MathMedia.resource(m.coverKey))
                  .width('100%')
                  .height(88)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
                  .opacity(m.unlocked ? 1 : 0.45)
                Text(m.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                  .textAlign(TextAlign.Center)
              }
              .width('48%')
              .margin({ bottom: Theme.space.s3 })
              .onClick(() => MathDetailNav.open('medal', m.id))
            }, (m: MedalView) => m.id)
          }
          .width('100%')
        }
        .width('100%')
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
    }
    .width('100%')
    .height('100%')
  }

  private unlockedCount(): number {
    let n = 0
    for (const m of this.medals) {
      if (m.unlocked) {
        n += 1
      }
    }
    return n
  }

  @Builder
  kpi(label: string, value: string) {
    Column({ space: Theme.space.s1 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .textAlign(TextAlign.Center)
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
    .padding({ top: Theme.space.s4, bottom: Theme.space.s4 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
