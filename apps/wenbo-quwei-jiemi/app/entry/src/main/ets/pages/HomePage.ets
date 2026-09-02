import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppError } from '../components/design-system/AppError'
import { PuzzleListCard } from '../components/design-system/PuzzleCards'
import { PuzzleItem } from '../models/PuzzleModels'
import { QuizBizService } from '../services/QuizBizService'
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
  @StorageLink('quizTick') tick: number = 0
  @StorageLink('doneCount') doneCount: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @StorageLink('todayCount') todayCount: number = 0
  @StorageLink('wisdomPointsTotal') wisdomPointsTotal: number = 0
  @StorageLink('wisdomPointsWeek') wisdomPointsWeek: number = 0
  @StorageLink('windowIsWide') isWide: boolean = false

  aboutToAppear(): void {
    this.greeting = ProgressStore.greeting()
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    const list = await QuizBizService.loadPuzzles()
    this.puzzles = list
    this.loading = false
    this.failed = list.length === 0
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

  private startOne(id: string): void {
    QuizNav.openQuiz([id], 0)
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
          Text('正在准备今日挑战…')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        } else {
          this.ChallengeCard()
          this.ProgressRow()
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
        Image(QuizMedia.cover('hero_space'))
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
    Row({ space: 10 }) {
      this.MiniStat('今日进度', `${this.todayCount}/5`)
      this.MiniStat('智慧值', `${this.wisdomPointsTotal}`)
      this.MiniStat('连续挑战', `${this.streakDays} 天`)
    }
    .width('100%')
    Text(`本周已获 ${this.wisdomPointsWeek} 智慧值 · 答对越多排名越靠前`)
      .fontSize(13)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
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
    Text('精选推荐')
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
          pointsLabel: `+${QuizBizService.wisdomPointsOf(p)}`,
          cover: QuizMedia.cover(p.coverKey),
          onStart: () => this.startOne(p.id)
        })
      }, (p: PuzzleItem) => p.id)
    }
    .width('100%')
  }
}
