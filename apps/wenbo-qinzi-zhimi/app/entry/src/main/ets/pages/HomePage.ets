import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppError } from '../components/design-system/AppError'
import { PuzzleListCard } from '../components/design-system/PuzzleCards'
import { GuideItem, PuzzleItem } from '../models/PuzzleModels'
import { TimelineEvent, TopicPack } from '../models/GrowthModels'
import { CategoryStat, QuizBizService } from '../services/QuizBizService'
import { GrowthService } from '../services/GrowthService'
import { QuizMedia } from '../services/QuizMedia'
import { QuizNav } from '../services/QuizNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State puzzles: PuzzleItem[] = []
  @State loading: boolean = true
  @State failed: boolean = false
  @State greeting: string = ''
  @State weeklyDots: number[] = []
  @State categoryStats: CategoryStat[] = []
  @State dailyTip: GuideItem = new GuideItem()
  @State recentEvents: TimelineEvent[] = []
  @State topicPack: TopicPack = new TopicPack()
  @State weekCorrect: number = 0
  @State planTarget: number = 15
  @StorageLink('doneCount') doneCount: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @StorageLink('todayCount') @Watch('onProgressChanged') todayCount: number = 0
  @StorageLink('familyMatch') familyMatch: number = 0
  @StorageLink('wrongCount') wrongCount: number = 0
  @StorageLink('favoriteCount') favoriteCount: number = 0
  @StorageLink('quizTick') @Watch('onQuizTick') tick: number = 0
  @StorageLink('quizRoute') @Watch('onQuizRoute') quizRoute: string = ''
  @StorageLink('accountEpoch') @Watch('onAccount') accountEpoch: number = 0
  @StorageLink('windowIsWide') isWide: boolean = false

  aboutToAppear(): void {
    this.greeting = ProgressStore.greeting()
    ProgressStore.sync()
    this.refreshExtras()
    void this.reload()
  }

  onQuizTick(): void {
    this.refreshExtras()
  }

  onQuizRoute(): void {
    if (this.quizRoute.length === 0) {
      ProgressStore.sync()
      this.refreshExtras()
    }
  }

  onAccount(): void {
    ProgressStore.sync()
    this.refreshExtras()
    void this.reload()
  }

  onProgressChanged(): void {
    this.refreshExtras()
  }

  private refreshExtras(): void {
    this.weeklyDots = ProgressStore.weeklyDots()
    this.categoryStats = QuizBizService.categoryStats(this.puzzles)
    this.recentEvents = GrowthService.timeline(5)
    this.topicPack = GrowthService.topicPack(this.puzzles)
    this.weekCorrect = GrowthService.weekCorrectCount()
    this.planTarget = GrowthService.planGoal().targetCorrect
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    const list = await QuizBizService.loadPuzzles()
    this.puzzles = list
    const guides = await QuizBizService.loadGuides()
    this.dailyTip = QuizBizService.dailyTip(guides)
    this.loading = false
    this.failed = list.length === 0
    this.refreshExtras()
  }

  private featured(): PuzzleItem {
    const ids = QuizBizService.dailyIds(this.puzzles, 5)
    if (ids.length === 0) {
      return new PuzzleItem()
    }
    const found = QuizBizService.find(this.puzzles, ids[0])
    return found !== undefined ? found : new PuzzleItem()
  }

  private startDaily(): void {
    const ids = QuizBizService.dailyIds(this.puzzles, 5)
    if (ids.length === 0) {
      return
    }
    QuizNav.openQuiz(ids, 0)
  }

  private startRandom(): void {
    const id = QuizBizService.randomId(this.puzzles)
    if (id.length === 0) {
      return
    }
    QuizNav.openQuiz([id], 0)
  }

  private openDetail(id: string): void {
    QuizNav.openDetail(id)
  }

  private progressPercent(): number {
    const goal = ProgressStore.dailyGoal()
    if (goal <= 0) {
      return 0
    }
    const pct = Math.round((this.todayCount * 100) / goal)
    return pct > 100 ? 100 : pct
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text(this.greeting)
          .fontSize(this.isWide ? 28 : 24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .lineHeight(34)

        if (this.failed && !this.loading) {
          AppError({
            title: '暂时没有谜题',
            message: '请检查网络后重试，或稍后再来。',
            retryLabel: '重试',
            onRetry: () => { void this.reload() }
          })
        } else if (this.puzzles.length === 0 && this.loading) {
          Text('正在准备今日谜题…')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        } else {
          this.ChallengeCard()
          this.ProgressRow()
          this.PlanSummary()
          this.QuickActions()
          if (this.recentEvents.length > 0) {
            this.RecentBlock()
          }
          this.TopicPackBlock()
          this.AgeRow()
          this.WeeklyRow()
          if (this.dailyTip.title.length > 0) {
            this.TipCard()
          }
          this.CategoryRow()
          this.RecommendBlock()
        }
      }
      .padding({
        left: this.isWide ? 36 : Theme.space.pageX,
        right: this.isWide ? 36 : Theme.space.pageX,
        top: Theme.space.s5,
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
  ChallengeCard() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.hero_desk'))
          .width('100%')
          .height(168)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(168)
          .linearGradient({
            angle: 180,
            colors: [['rgba(30,42,58,0.05)', 0], ['rgba(30,42,58,0.72)', 1]]
          })
        Column({ space: 6 }) {
          Text('今日挑战')
            .fontSize(13)
            .fontColor('#FFFFFF')
          Text(this.featured().question.length > 0 ? this.featured().question : '打开就能玩一题')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .maxLines(2)
        }
        .padding({ left: 20, right: 20, bottom: 18 })
      }
      .clip(true)
      .borderRadius({ topLeft: 24, topRight: 24 })

      Column({ space: 10 }) {
        Text(this.featured().optionA.length > 0 ? `A  ${this.featured().optionA}` : '')
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(this.featured().optionB.length > 0 ? `B  ${this.featured().optionB}` : '')
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: '开始挑战',
          onTap: () => this.startDaily()
        })
      }
      .padding(20)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(24)
    .shadow({ radius: 16, color: 'rgba(30,42,58,0.06)', offsetY: 4, offsetX: 0 })
    .clip(true)
  }

  @Builder
  ProgressRow() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        this.MiniStat('今日进度', `${this.todayCount}/${ProgressStore.dailyGoal()}`)
        this.MiniStat('已完成', `${this.doneCount} 题`)
        this.MiniStat('连续挑战', `${this.streakDays} 天`)
        this.MiniStat('收藏', `${this.favoriteCount}`)
      }
      .width('100%')
      Row({ space: 8 }) {
        Column()
          .layoutWeight(this.progressPercent() > 0 ? this.progressPercent() : 1)
          .height(8)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
        Column()
          .layoutWeight(this.progressPercent() >= 100 ? 1 : (100 - this.progressPercent()))
          .height(8)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')
        Text(this.familyMatch > 0 ? `亲子默契 ${this.familyMatch}%` : '完成家庭对答后，这里会记下今日默契')
        .fontSize(13)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text('进度只属于当前账号，换号后不会带走上一份记录。')
        .fontSize(12)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
  }

  @Builder
  AgeRow() {
    Text('按年龄选一关')
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .width('100%')
    Row({ space: 8 }) {
      this.AgeBtn('age35', '3-5岁')
      this.AgeBtn('age68', '6-8岁')
      this.AgeBtn('age912', '9-12岁')
    }
    .width('100%')
  }

  @Builder
  AgeBtn(id: string, label: string) {
    Text(label)
      .fontSize(14)
      .fontColor(Theme.colors().textPrimary)
      .padding({ left: 10, right: 10, top: 12, bottom: 12 })
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(16)
      .onClick(() => {
        AppStorage.setOrCreate('mainTab', 1)
        AppStorage.setOrCreate('puzzleAge', id)
        QuizNav.bump()
      })
  }

  private weekdayDotLabel(idx: number): string {
    if (idx === this.weeklyDots.length - 1) {
      return '今'
    }
    const labels: string[] = ['一', '二', '三', '四', '五', '六']
    return labels[idx] ?? ''
  }

  private dotColor(count: number): string {
    if (count <= 0) {
      return Theme.colors().surfaceSubtle
    }
    if (count >= 3) {
      return Theme.colors().brandPrimary
    }
    return Theme.colors().brandPrimaryContainer
  }

  @Builder
  WeeklyRow() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.hero_space'))
          .width('100%')
          .height(56)
          .objectFit(ImageFit.Cover)
          .opacity(0.35)
        Text('本周足迹')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .clip(true)
      .borderRadius(16)
      Row() {
        ForEach(this.weeklyDots, (n: number, idx: number) => {
          Column({ space: 4 }) {
            Column()
              .width(22)
              .height(22)
              .borderRadius(11)
              .backgroundColor(this.dotColor(n))
            Text(this.weekdayDotLabel(idx))
              .fontSize(10)
              .fontColor(Theme.colors().textTertiary)
              .textAlign(TextAlign.Center)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }, (n: number, idx: number) => `dot-${idx}`)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      Text('圆点越深，表示当天答对的题越多')
        .fontSize(12)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(22)
    .width('100%')
  }

  @Builder
  PlanSummary() {
    Row({ space: 10 }) {
      Column({ space: 4 }) {
        Text('本周计划')
          .fontSize(14)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(`${this.weekCorrect}/${this.planTarget} 题`)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Column({ space: 4 }) {
        Text('错题待练')
          .fontSize(14)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(`${this.wrongCount} 题`)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text('看成长')
        .fontSize(14)
        .fontColor(Theme.colors().brandPrimary)
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.pill)
        .onClick(() => {
          AppStorage.setOrCreate('mainTab', 3)
          QuizNav.bump()
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(22)
  }

  @Builder
  RecentBlock() {
    Column({ space: 8 }) {
      Text('最近动态')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.recentPreview(), (e: TimelineEvent) => {
        Text(`${e.at} · ${e.title}${e.subtitle.length > 0 ? ' · ' + e.subtitle : ''}`)
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }, (e: TimelineEvent) => e.id)
    }
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(22)
    .width('100%')
  }

  private recentPreview(): TimelineEvent[] {
    const out: TimelineEvent[] = []
    let n = 0
    for (const e of this.recentEvents) {
      if (n >= 3) {
        break
      }
      out.push(e)
      n++
    }
    return out
  }

  @Builder
  TopicPackBlock() {
    Column({ space: 8 }) {
      Text(this.topicPack.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`进度 ${this.topicPack.done}/${this.topicPack.total}`)
        .fontSize(13)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      AppButton({
        label: '进入主题包',
        variant: 'secondary',
        onTap: () => {
          AppStorage.setOrCreate('mainTab', 1)
          AppStorage.setOrCreate('puzzleCategory', this.topicPack.categoryId)
          QuizNav.bump()
        }
      })
    }
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(22)
    .width('100%')
  }

  @Builder
  QuickActions() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        AppButton({
          label: '随机一题',
          variant: 'secondary',
          onTap: () => this.startRandom()
        })
          .layoutWeight(1)
        AppButton({
          label: '亲子对答',
          variant: 'secondary',
          onTap: () => {
            AppStorage.setOrCreate('mainTab', 2)
            QuizNav.bump()
          }
        })
          .layoutWeight(1)
      }
      .width('100%')
      AppButton({
        label: '查看本周回顾',
        variant: 'ghost',
        onTap: () => QuizNav.openReview()
      })
    }
    .width('100%')
  }

  @Builder
  TipCard() {
    Column({ space: 8 }) {
      Text('今日谜思')
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .width('100%')
      Text(this.dailyTip.title)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.dailyTip.body)
        .fontSize(14)
        .lineHeight(22)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding(18)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(22)
    .width('100%')
  }

  @Builder
  CategoryRow() {
    Text('分类探索')
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .width('100%')
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.categoryStats, (c: CategoryStat) => {
          Column({ space: 6 }) {
            Text(c.label)
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .maxLines(1)
            Text(`${c.done}/${c.total}`)
              .fontSize(12)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width(96)
          .padding(12)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(18)
          .onClick(() => {
            AppStorage.setOrCreate('mainTab', 1)
            AppStorage.setOrCreate('puzzleCategory', c.id)
            QuizNav.bump()
          })
        }, (c: CategoryStat) => c.id)
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  MiniStat(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RecommendBlock() {
    Text('今日推荐')
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .width('100%')
    Column({ space: 12 }) {
      ForEach(QuizBizService.recommend(this.puzzles), (p: PuzzleItem) => {
        PuzzleListCard({
          typeLabel: p.categoryLabel,
          title: p.title,
          summary: p.summary,
          difficulty: p.difficulty,
          cover: QuizMedia.cover(p.coverKey),
          onTap: (): void => { this.openDetail(p.id) },
          onStart: (): void => { QuizNav.openQuiz([p.id], 0) }
        })
      }, (p: PuzzleItem) => p.id)
    }
    .width('100%')
  }
}
