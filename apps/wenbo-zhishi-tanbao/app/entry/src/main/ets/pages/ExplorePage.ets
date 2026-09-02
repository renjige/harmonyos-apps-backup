import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { CardListCard } from '../components/treasure/TreasureCards'
import {
  TreasureCard, TreasureMatch, TreasureQuestion, TreasureTheme
} from '../models/TreasureModels'
import { TreasureBizService } from '../services/TreasureBizService'
import { TreasureMedia } from '../services/TreasureMedia'
import { TreasureNav } from '../services/TreasureNav'
import { VaultStore } from '../services/VaultStore'

class ThemeChip {
  key: string = ''
  label: string = ''

  static all(): ThemeChip[] {
    const chips: ThemeChip[] = []
    const keys: string[] = ['', 'history', 'science', 'literature', 'art', 'philosophy', 'general']
    const labels: string[] = ['全部', '历史', '科学', '文学', '艺术', '哲学', '综合']
    for (let i = 0; i < keys.length; i++) {
      const c = new ThemeChip()
      c.key = keys[i]
      c.label = labels[i]
      chips.push(c)
    }
    return chips
  }
}

@Component
export struct ExplorePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State themes: TreasureTheme[] = []
  @State cards: TreasureCard[] = []
  @State questions: TreasureQuestion[] = []
  @State matches: TreasureMatch[] = []
  @State selectedCategory: string = ''
  @State loading: boolean = true
  @State failed: boolean = false
  @State matchLeft: string = ''
  @State matchRight: string = ''
  @State matchToast: string = ''
  @State matchDone: number = 0
  private chips: ThemeChip[] = ThemeChip.all()

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    this.themes = await TreasureBizService.loadThemes()
    this.cards = await TreasureBizService.loadCards(this.selectedCategory)
    this.questions = await TreasureBizService.loadQuestions(this.selectedCategory, false)
    this.matches = await TreasureBizService.loadMatches(this.selectedCategory)
    this.loading = false
    this.failed = this.cards.length === 0 && this.questions.length === 0
    this.matchLeft = ''
    this.matchRight = ''
  }

  private clearMatchSelection(): void {
    this.matchLeft = ''
    this.matchRight = ''
  }

  private selectCategory(key: string): void {
    this.selectedCategory = key
    void this.reload()
  }

  private startThemeQuiz(): void {
    const ids: string[] = []
    let n = 0
    for (const q of this.questions) {
      if (n >= 5) {
        break
      }
      ids.push(q.id)
      n++
    }
    if (ids.length === 0) {
      return
    }
    TreasureNav.openQuiz(ids, 0)
  }

  private pickLeft(text: string): void {
    this.matchLeft = text
    this.tryMatch()
  }

  private pickRight(text: string): void {
    this.matchRight = text
    this.tryMatch()
  }

  private async tryMatch(): Promise<void> {
    if (this.matchLeft.length === 0 || this.matchRight.length === 0) {
      return
    }
    let matched = false
    for (const m of this.matches) {
      if (m.pairLeft === this.matchLeft && m.pairRight === this.matchRight) {
        matched = true
        await VaultStore.recordMatchComplete(m.id)
        this.matchDone = this.matchDone + 1
        this.matchToast = '配对成功 +5 积分'
        break
      }
    }
    if (!matched) {
      this.matchToast = '再试一次，左右要对应哦'
    }
    setTimeout(() => { this.matchToast = '' }, 1800)
    this.clearMatchSelection()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('智慧探索')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(this.chips, (c: ThemeChip) => {
              Text(c.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.selectedCategory === c.key ?
                  Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.selectedCategory === c.key ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick((): void => { this.selectCategory(c.key) })
            }, (c: ThemeChip) => c.key)
          }
          .padding({ right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        if (this.failed && !this.loading) {
          AppError({
            title: '暂无探索内容',
            message: '切换主题或稍后重试',
            retryLabel: '刷新',
            onRetry: (): void => { void this.reload() }
          })
        } else if (this.loading) {
          Text('加载探索内容…')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        } else {
          this.ThemeSection()
          this.CardsSection()
          this.QuizSection()
          this.MatchSection()
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  ThemeSection() {
    if (this.themes.length > 0) {
      Text('探宝主题')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        ForEach(this.themes.slice(0, 3), (t: TreasureTheme) => {
          Column({ space: 6 }) {
            Text(t.title)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(t.summary)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(2)
          }
          .layoutWeight(1)
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .alignItems(HorizontalAlign.Start)
          .onClick((): void => { this.selectCategory(t.category) })
        }, (t: TreasureTheme) => t.id)
      }
      .width('100%')
    }
  }

  @Builder
  CardsSection() {
    Text('知识卡片')
      .fontSize(Theme.type.subhead)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .width('100%')
    if (this.cards.length === 0) {
      AppEmpty({ title: '该主题暂无卡片', description: '' })
    } else {
      Column({ space: Theme.space.s3 }) {
        ForEach(this.cards, (c: TreasureCard) => {
          CardListCard({
            categoryLabel: c.categoryLabel,
            category: c.category,
            title: c.title,
            summary: c.summary,
            cover: TreasureMedia.resource(c.coverKey.length > 0 ? c.coverKey : c.category),
            onOpen: (): void => { TreasureNav.openCard(c.id) }
          })
        }, (c: TreasureCard) => c.id)
      }
      .width('100%')
    }
  }

  @Builder
  QuizSection() {
    Column({ space: Theme.space.s3 }) {
      Text('主题闯关')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`当前主题 ${this.questions.length} 道题，最多 5 题一组`)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      AppButton({
        label: '开始主题闯关',
        disabled: this.questions.length === 0,
        onTap: (): void => { this.startThemeQuiz() }
      })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
  }

  @Builder
  MatchSection() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('智慧配对')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text(`已完成 ${this.matchDone}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandAccent)
      }
      .width('100%')
      Text('先点左侧概念，再点右侧解释完成配对')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      if (this.matchToast.length > 0) {
        Text(this.matchToast)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
      }
      Row({ space: Theme.space.s3 }) {
        Column({ space: Theme.space.s2 }) {
          ForEach(this.matches, (m: TreasureMatch) => {
            Text(m.pairLeft)
              .fontSize(Theme.type.body)
              .fontColor(this.matchLeft === m.pairLeft ?
                Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .backgroundColor(this.matchLeft === m.pairLeft ?
                Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .width('100%')
              .onClick((): void => { this.pickLeft(m.pairLeft) })
          }, (m: TreasureMatch) => `l-${m.id}`)
        }
        .layoutWeight(1)
        Column({ space: Theme.space.s2 }) {
          ForEach(this.matches, (m: TreasureMatch) => {
            Text(m.pairRight)
              .fontSize(Theme.type.body)
              .fontColor(this.matchRight === m.pairRight ?
                Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .backgroundColor(this.matchRight === m.pairRight ?
                Theme.colors().brandAccent : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .width('100%')
              .onClick((): void => { this.pickRight(m.pairRight) })
          }, (m: TreasureMatch) => `r-${m.id}`)
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.xl)
  }
}
