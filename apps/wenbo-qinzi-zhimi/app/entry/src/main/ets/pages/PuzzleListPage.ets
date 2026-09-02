import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { AppButton } from '../components/design-system/AppButton'
import { PuzzleListCard } from '../components/design-system/PuzzleCards'
import { CollectionPanel } from '../components/growth/CollectionPanel'
import { CategoryChip, PuzzleItem } from '../models/PuzzleModels'
import { TopicPack } from '../models/GrowthModels'
import { CategoryStat, QuizBizService } from '../services/QuizBizService'
import { GrowthService } from '../services/GrowthService'
import { QuizMedia } from '../services/QuizMedia'
import { QuizNav } from '../services/QuizNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct PuzzleListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State puzzles: PuzzleItem[] = []
  @State filtered: PuzzleItem[] = []
  @State chips: CategoryChip[] = []
  @State ageChips: CategoryChip[] = []
  @State statusChips: CategoryChip[] = []
  @State active: string = 'all'
  @State ageBand: string = 'all'
  @State statusFilter: string = 'all'
  @State sortMode: string = 'default'
  @State keyword: string = ''
  @State failed: boolean = false
  @State categoryStats: CategoryStat[] = []
  @State topicPack: TopicPack = new TopicPack()
  @State showCollections: boolean = false
  @StorageLink('windowIsWide') isWide: boolean = false
  @StorageLink('quizTick') @Watch('onQuizTick') tick: number = 0
  @StorageLink('accountEpoch') @Watch('onAccount') accountEpoch: number = 0
  @StorageLink('puzzleCategory') puzzleCategory: string = 'all'

  aboutToAppear(): void {
    this.chips = PuzzleListPage.allChips()
    this.ageChips = QuizBizService.ageChips()
    this.statusChips = PuzzleListPage.statusChips()
    this.ageBand = ProgressStore.snapshot().agePref
    if (this.puzzleCategory.length > 0 && this.puzzleCategory !== 'all') {
      this.active = this.puzzleCategory
      AppStorage.setOrCreate('puzzleCategory', 'all')
    }
    const fromHome = AppStorage.get<string>('puzzleAge') ?? 'all'
    if (fromHome.length > 0 && fromHome !== 'all') {
      this.ageBand = fromHome
      AppStorage.setOrCreate('puzzleAge', 'all')
    }
    void this.reload()
  }

  onQuizTick(): void {
    this.categoryStats = QuizBizService.categoryStats(this.puzzles)
    this.topicPack = GrowthService.topicPack(this.puzzles)
  }

  static statusChips(): CategoryChip[] {
    const out: CategoryChip[] = []
    const ids: string[] = ['all', 'todo', 'done', 'wrong', 'favorite']
    const labels: string[] = ['全部状态', '未做', '已做', '错题', '收藏']
    for (let i = 0; i < ids.length; i++) {
      const c = new CategoryChip()
      c.id = ids[i]
      c.label = labels[i]
      out.push(c)
    }
    return out
  }

  onAccount(): void {
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
    this.categoryStats = QuizBizService.categoryStats(list)
    this.topicPack = GrowthService.topicPack(list)
    this.applyFilter()
  }

  private applyFilter(): void {
    let out: PuzzleItem[] = []
    for (const p of this.puzzles) {
      if (this.active === 'all' || p.category === this.active) {
        out.push(p)
      }
    }
    out = QuizBizService.filterAge(out, this.ageBand)
    out = QuizBizService.search(out, this.keyword)
    out = this.filterStatus(out)
    out = this.sortList(out)
    this.filtered = out
  }

  private filterStatus(list: PuzzleItem[]): PuzzleItem[] {
    if (this.statusFilter === 'all') {
      return list
    }
    const out: PuzzleItem[] = []
    for (const p of list) {
      if (this.statusFilter === 'todo' && !ProgressStore.isCompleted(p.id)) {
        out.push(p)
      } else if (this.statusFilter === 'done' && ProgressStore.isCompleted(p.id)) {
        out.push(p)
      } else if (this.statusFilter === 'wrong' && ProgressStore.isWrong(p.id)) {
        out.push(p)
      } else if (this.statusFilter === 'favorite' && ProgressStore.isFavorite(p.id)) {
        out.push(p)
      }
    }
    return out
  }

  private sortList(list: PuzzleItem[]): PuzzleItem[] {
    if (this.sortMode !== 'easy') {
      return list
    }
    const out: PuzzleItem[] = []
    for (const p of list) {
      out.push(p)
    }
    for (let i = 0; i < out.length; i++) {
      for (let j = i + 1; j < out.length; j++) {
        const ai = this.difficultyOrder(out[i].difficulty)
        const aj = this.difficultyOrder(out[j].difficulty)
        if (aj < ai) {
          const tmp = out[i]
          out[i] = out[j]
          out[j] = tmp
        }
      }
    }
    return out
  }

  private difficultyOrder(d: string): number {
    if (d === '轻松') {
      return 0
    }
    if (d === '适中') {
      return 1
    }
    return 2
  }

  private setStatus(id: string): void {
    this.statusFilter = id
    this.applyFilter()
  }

  private toggleSort(): void {
    this.sortMode = this.sortMode === 'default' ? 'easy' : 'default'
    this.applyFilter()
  }

  private setChip(id: string): void {
    this.active = id
    this.applyFilter()
  }

  private setAge(id: string): void {
    this.ageBand = id
    void ProgressStore.setAgePref(id)
    this.applyFilter()
  }

  private activeStat(): CategoryStat {
    for (const c of this.categoryStats) {
      if (c.id === this.active) {
        return c
      }
    }
    const all = new CategoryStat()
    all.label = '全部谜题'
    all.done = ProgressStore.snapshot().completedIds.length
    all.total = this.puzzles.length
    return all
  }

  build() {
    if (this.showCollections) {
      CollectionPanel({ onBack: () => { this.showCollections = false } })
    } else {
      this.MainBody()
    }
  }

  @Builder
  MainBody() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('探索中心')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({
            left: this.isWide ? 36 : Theme.space.pageX,
            right: this.isWide ? 36 : Theme.space.pageX,
            top: Theme.space.s4
          })

        this.TopicBanner()
        this.FilterBlock()
        this.ListBlock()
      }
      .width('100%')
      .constraintSize({ maxWidth: this.isWide ? 920 : 840 })
      .padding({ bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.Top)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  FilterBlock() {
    Row({ space: 8 }) {
      TextInput({ text: this.keyword, placeholder: '搜索标题或关键词' })
        .layoutWeight(1)
        .height(44)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
        .padding({ left: 16, right: 16 })
        .onChange((v: string) => {
          this.keyword = v
          this.applyFilter()
        })
      Text(this.sortMode === 'easy' ? '难度↑' : '默认序')
        .fontSize(13)
        .fontColor(Theme.colors().brandPrimary)
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.pill)
        .onClick(() => this.toggleSort())
    }
    .padding({ left: this.isWide ? 36 : Theme.space.pageX, right: this.isWide ? 36 : Theme.space.pageX })
    .width('100%')

    Row({ space: 8 }) {
      AppButton({
        label: '收藏夹',
        variant: 'secondary',
        onTap: () => { this.showCollections = true }
      })
        .layoutWeight(1)
    }
    .padding({ left: this.isWide ? 36 : Theme.space.pageX, right: this.isWide ? 36 : Theme.space.pageX })
    .width('100%')

    if (this.active !== 'all') {
      Text(`${this.activeStat().label} · 已练 ${this.activeStat().done}/${this.activeStat().total}`)
        .fontSize(13)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: this.isWide ? 36 : Theme.space.pageX, right: this.isWide ? 36 : Theme.space.pageX })
    }

    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.ageChips, (c: CategoryChip) => {
          Text(c.label)
            .fontSize(13)
            .fontColor(this.ageBand === c.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor(this.ageBand === c.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.setAge(c.id))
        }, (c: CategoryChip) => `age-${c.id}`)
      }
      .padding({ left: this.isWide ? 36 : Theme.space.pageX, right: this.isWide ? 36 : Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')

    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.statusChips, (c: CategoryChip) => {
          Text(c.label)
            .fontSize(13)
            .fontColor(this.statusFilter === c.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor(this.statusFilter === c.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.setStatus(c.id))
        }, (c: CategoryChip) => `st-${c.id}`)
      }
      .padding({ left: this.isWide ? 36 : Theme.space.pageX, right: this.isWide ? 36 : Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')

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
  }

  @Builder
  ListBlock() {
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
        description: '换一个分类、年龄或状态试试吧',
        actionLabel: '重置筛选',
        onAction: () => {
          this.keyword = ''
          this.statusFilter = 'all'
          this.ageBand = 'all'
          this.active = 'all'
          void ProgressStore.setAgePref('all')
          this.applyFilter()
        }
      })
    } else {
      Column({ space: 12 }) {
        Text(`共 ${this.filtered.length} 题`)
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({
            left: this.isWide ? 36 : Theme.space.pageX,
            right: this.isWide ? 36 : Theme.space.pageX
          })
        ForEach(this.filtered, (p: PuzzleItem) => {
          PuzzleListCard({
            typeLabel: p.ageLabel && p.ageLabel.length > 0 ? `${p.categoryLabel} · ${p.ageLabel}` : p.categoryLabel,
            title: p.title,
            summary: p.summary,
            difficulty: p.difficulty,
            cover: QuizMedia.cover(p.coverKey),
            onTap: (): void => { QuizNav.openDetail(p.id) },
            onStart: (): void => { QuizNav.openQuiz([p.id], 0) }
          })
        }, (p: PuzzleItem) => p.id)
      }
      .padding({
        left: this.isWide ? 36 : Theme.space.pageX,
        right: this.isWide ? 36 : Theme.space.pageX
      })
      .width('100%')
    }
  }

  @Builder
  TopicBanner() {
    Column({ space: 6 }) {
      Text(this.topicPack.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`主题包进度 ${this.topicPack.done}/${this.topicPack.total}`)
        .fontSize(13)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .padding(14)
    .margin({
      left: this.isWide ? 36 : Theme.space.pageX,
      right: this.isWide ? 36 : Theme.space.pageX
    })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(18)
    .width('100%')
  }
}
