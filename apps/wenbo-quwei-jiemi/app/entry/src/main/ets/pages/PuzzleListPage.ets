import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { PuzzleListCard } from '../components/design-system/PuzzleCards'
import { CategoryChip, PuzzleItem } from '../models/PuzzleModels'
import { QuizBizService } from '../services/QuizBizService'
import { QuizMedia } from '../services/QuizMedia'
import { QuizNav } from '../services/QuizNav'

@Component
export struct PuzzleListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State puzzles: PuzzleItem[] = []
  @State filtered: PuzzleItem[] = []
  @State chips: CategoryChip[] = []
  @State active: string = 'all'
  @State failed: boolean = false
  @StorageLink('windowIsWide') isWide: boolean = false

  aboutToAppear(): void {
    this.chips = PuzzleListPage.allChips()
    void this.reload()
  }

  static allChips(): CategoryChip[] {
    const out: CategoryChip[] = []
    const ids: string[] = ['all', 'riddle', 'math', 'visual', 'life', 'logic', 'animal']
    const labels: string[] = ['全部', '脑筋急转弯', '趣味数学', '图形观察', '生活常识', '逻辑推理', '动物世界']
    for (let i = 0; i < ids.length; i++) {
      const c = new CategoryChip()
      c.id = ids[i]
      c.label = labels[i]
      out.push(c)
    }
    return out
  }

  async reload(): Promise<void> {
    const list = await QuizBizService.loadPuzzles()
    this.puzzles = list
    this.failed = list.length === 0
    this.applyFilter()
  }

  private applyFilter(): void {
    const out: PuzzleItem[] = []
    for (const p of this.puzzles) {
      if (this.active === 'all' || p.category === this.active) {
        out.push(p)
      }
    }
    this.filtered = out
  }

  private setChip(id: string): void {
    this.active = id
    this.applyFilter()
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Text('题库')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({
          left: this.isWide ? 36 : Theme.space.pageX,
          right: this.isWide ? 36 : Theme.space.pageX,
          top: Theme.space.s4
        })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.chips, (c: CategoryChip) => {
            Text(c.label)
              .fontSize(14)
              .fontColor(this.active === c.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.active === c.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => this.setChip(c.id))
          }, (c: CategoryChip) => c.id)
        }
        .padding({ left: this.isWide ? 36 : Theme.space.pageX, right: this.isWide ? 36 : Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      if (this.failed) {
        AppError({
          title: '题库还没准备好',
          message: '请稍后重试。',
          retryLabel: '重试',
          onRetry: () => { void this.reload() }
        })
      } else if (this.filtered.length === 0) {
        AppEmpty({
          title: '这一类暂时没有谜题',
          description: '换一个分类看看吧',
          actionLabel: '看全部',
          onAction: () => this.setChip('all')
        })
      } else if (this.isWide) {
        this.WideList()
      } else {
        this.PhoneList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  PhoneList() {
    Scroll() {
      Column({ space: 12 }) {
        ForEach(this.filtered, (p: PuzzleItem) => {
          PuzzleListCard({
            typeLabel: p.categoryLabel,
            title: p.title,
            summary: p.summary,
            difficulty: p.difficulty,
            pointsLabel: `+${QuizBizService.wisdomPointsOf(p)}`,
            cover: QuizMedia.cover(p.coverKey),
            onStart: () => QuizNav.openQuiz([p.id], 0)
          })
        }, (p: PuzzleItem) => p.id)
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
    }
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  WideList() {
    Scroll() {
      Column({ space: 12 }) {
        ForEach(this.filtered, (p: PuzzleItem) => {
          PuzzleListCard({
            typeLabel: p.categoryLabel,
            title: p.title,
            summary: p.summary,
            difficulty: p.difficulty,
            pointsLabel: `+${QuizBizService.wisdomPointsOf(p)}`,
            cover: QuizMedia.cover(p.coverKey),
            onStart: () => QuizNav.openQuiz([p.id], 0)
          })
        }, (p: PuzzleItem) => p.id)
      }
      .padding({ left: 36, right: 36, bottom: Theme.space.s10 })
      .constraintSize({ maxWidth: 920 })
      .width('100%')
    }
    .layoutWeight(1)
    .width('100%')
  }
}
