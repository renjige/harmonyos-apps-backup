import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppBarChart, AppRingChart, BarChartItem } from '../components/design-system/AppChart'
import { AchievementItem, CategoryStatItem, TimelineEvent, TopicPack, WeeklyReview } from '../models/GrowthModels'
import { PuzzleItem } from '../models/PuzzleModels'
import { GrowthService } from '../services/GrowthService'
import { ProgressStore } from '../services/ProgressStore'
import { QuizBizService } from '../services/QuizBizService'
import { QuizNav } from '../services/QuizNav'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State puzzles: PuzzleItem[] = []
  @State timeline: TimelineEvent[] = []
  @State achievements: AchievementItem[] = []
  @State categoryStats: CategoryStatItem[] = []
  @State topicPack: TopicPack = new TopicPack()
  @State weeklyDots: number[] = []
  @State checkIns: number[] = []
  @State weekCorrect: number = 0
  @State weekFamily: number = 0
  @State planCorrectTarget: number = 15
  @State planFamilyTarget: number = 1
  @StorageLink('doneCount') doneCount: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @StorageLink('wrongCount') wrongCount: number = 0
  @StorageLink('favoriteCount') favoriteCount: number = 0
  @StorageLink('quizTick') @Watch('onTick') tick: number = 0
  @StorageLink('accountEpoch') @Watch('onTick') accountEpoch: number = 0
  @State barChartItems: BarChartItem[] = []
  @StorageLink('windowIsWide') isWide: boolean = false

  aboutToAppear(): void {
    this.refreshLocal()
    void this.reload()
  }

  onTick(): void {
    this.refreshLocal()
  }

  private async reload(): Promise<void> {
    this.puzzles = await QuizBizService.loadPuzzles()
    this.refreshLocal()
  }

  private refreshLocal(): void {
    ProgressStore.sync()
    this.timeline = GrowthService.timeline(12)
    this.achievements = GrowthService.achievements()
    this.categoryStats = GrowthService.categoryStats(this.puzzles)
    this.topicPack = GrowthService.topicPack(this.puzzles)
    this.weeklyDots = ProgressStore.weeklyDots()
    this.checkIns = GrowthService.monthlyCheckIns()
    this.weekCorrect = GrowthService.weekCorrectCount()
    this.weekFamily = GrowthService.weekFamilyCount()
    const plan = GrowthService.planGoal()
    this.planCorrectTarget = plan.targetCorrect
    this.planFamilyTarget = plan.targetFamily
    this.barChartItems = this.buildBarItems()
  }

  private buildBarItems(): BarChartItem[] {
    const out: BarChartItem[] = []
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '今']
    for (let i = 0; i < this.weeklyDots.length; i++) {
      const item = new BarChartItem()
      item.value = this.weeklyDots[i]
      item.label = labels[i] ?? ''
      out.push(item)
    }
    return out
  }

  private weekPlanPercent(): number {
    if (this.planCorrectTarget <= 0) {
      return 0
    }
    const pct = this.weekCorrect / this.planCorrectTarget
    return pct > 1 ? 1 : pct
  }

  private openReview(): void {
    QuizNav.openReview()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('成长中心')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Row({ space: 10 }) {
          this.StatCard('累计完成', `${this.doneCount}`)
          this.StatCard('连续天数', `${this.streakDays}`)
          this.StatCard('错题', `${this.wrongCount}`)
          this.StatCard('收藏', `${this.favoriteCount}`)
        }
        .width('100%')

        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Text('本周计划')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(`答对 ${this.weekCorrect}/${this.planCorrectTarget} · 亲子 ${this.weekFamily}/${this.planFamilyTarget}`)
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            AppButton({ label: '查看周回顾', variant: 'secondary', onTap: () => this.openReview() })
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(22)
          AppRingChart({ title: '本周进度', percent: this.weekPlanPercent() })
            .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        AppBarChart({ title: '近 7 天答对题数', items: this.barChartItems })

        this.TopicBlock()
        this.CheckInBlock()
        this.TimelineBlock()
        this.AchievementBlock()
        this.CategoryBlock()
      }
      .padding({
        left: this.isWide ? 36 : Theme.space.pageX,
        right: this.isWide ? 36 : Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s10
      })
      .constraintSize({ maxWidth: 840 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .align(Alignment.Top)
  }

  @Builder
  StatCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(label)
        .fontSize(11)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(18)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  TopicBlock() {
    Column({ space: 8 }) {
      Text(this.topicPack.title)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`本周主题进度 ${this.topicPack.done}/${this.topicPack.total}`)
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row({ space: 8 }) {
        Column()
          .layoutWeight(this.topicPack.total > 0 ? this.topicPack.done : 1)
          .height(8)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
        Column()
          .layoutWeight(this.topicPack.total > this.topicPack.done ?
            (this.topicPack.total - this.topicPack.done) : 1)
          .height(8)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')
      AppButton({
        label: '去主题闯关',
        variant: 'secondary',
        onTap: () => {
          AppStorage.setOrCreate('mainTab', 1)
          AppStorage.setOrCreate('puzzleCategory', this.topicPack.categoryId)
          QuizNav.bump()
        }
      })
    }
    .padding(18)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(22)
    .width('100%')
  }

  @Builder
  CheckInBlock() {
    Column({ space: 10 }) {
      Text('本月打卡')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.checkIns, (n: number, idx: number) => {
          Column()
            .width(10)
            .height(10)
            .margin({ right: 4, bottom: 4 })
            .borderRadius(5)
            .backgroundColor(n > 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .opacity(n > 2 ? 1 : (n > 0 ? 0.65 : 0.35))
        }, (n: number, idx: number) => `ci-${idx}`)
      }
      .width('100%')
      Text('圆点表示当天答对题数，越深代表越多')
        .fontSize(12)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .padding(18)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(22)
    .width('100%')
  }

  @Builder
  TimelineBlock() {
    Column({ space: 10 }) {
      Text('最近动态')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.timeline.length === 0) {
        Text('完成一题或收藏后，这里会留下足迹')
          .fontSize(14)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.timeline, (e: TimelineEvent) => {
          Row({ space: 10 }) {
            Column()
              .width(8)
              .height(8)
              .borderRadius(4)
              .backgroundColor(Theme.colors().brandPrimary)
              .margin({ top: 6 })
            Column({ space: 2 }) {
              Text(e.title)
                .fontSize(15)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(`${e.at}${e.subtitle.length > 0 ? ' · ' + e.subtitle : ''}`)
                .fontSize(12)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
        }, (e: TimelineEvent) => e.id)
      }
    }
    .padding(18)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(22)
    .width('100%')
  }

  @Builder
  AchievementBlock() {
    Column({ space: 10 }) {
      Text('成就墙')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.achievements, (a: AchievementItem) => {
        Row({ space: 10 }) {
          Column()
            .width(36)
            .height(36)
            .borderRadius(18)
            .backgroundColor(a.unlocked ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
          Column({ space: 2 }) {
            Text(a.title)
              .fontSize(15)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(`${a.rule} · ${a.current}/${a.target}`)
              .fontSize(12)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Text(a.unlocked ? '已达成' : '进行中')
            .fontSize(12)
            .fontColor(a.unlocked ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      }, (a: AchievementItem) => a.id)
    }
    .padding(18)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(22)
    .width('100%')
  }

  @Builder
  CategoryBlock() {
    Column({ space: 10 }) {
      Text('分类掌握度')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.categoryStats, (c: CategoryStatItem) => {
        Column({ space: 6 }) {
          Row() {
            Text(c.label)
              .fontSize(14)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text(`${c.done}/${c.total}`)
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          Row({ space: 8 }) {
            Column()
              .layoutWeight(c.total > 0 ? c.done : 1)
              .height(6)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
            Column()
              .layoutWeight(c.total > c.done ? (c.total - c.done) : 1)
              .height(6)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
          }
          .width('100%')
        }
        .width('100%')
      }, (c: CategoryStatItem) => c.id)
    }
    .padding(18)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(22)
    .width('100%')
  }
}
