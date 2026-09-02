import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ChallengeMapPage } from './ChallengeMapPage'
import { ReportPage } from './ReportPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AIAssistantPage } from './AIAssistantPage'
import { QuizOverlay } from '../components/kingdom/QuizOverlay'
import { ResultOverlay } from '../components/kingdom/ResultOverlay'
import { CollectionOverlay } from '../components/kingdom/CollectionOverlay'
import { SettingsOverlay } from '../components/kingdom/SettingsOverlay'
import { ParentGateOverlay } from '../components/kingdom/ParentGateOverlay'
import { CatalogDetailPane } from '../components/detail/CatalogDetailPane'
import { CatalogItem, QuizQuestion, QuizState, RelicView } from '../models/KingdomModels'
import { KingdomBizService } from '../services/KingdomBizService'
import { KingdomDetailNav } from '../services/KingdomDetailNav'
import { ParentGateService } from '../services/ParentGateService'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '大厅'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '闯关'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '报告'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State tick: number = 0
  @State levels: CatalogItem[] = []
  @State questions: CatalogItem[] = []
  @State dailies: CatalogItem[] = []
  @State relics: CatalogItem[] = []
  @State guides: CatalogItem[] = []
  @State relicViews: RelicView[] = []
  @State showQuiz: boolean = false
  @State showResult: boolean = false
  @State showCollect: boolean = false
  @State showSettings: boolean = false
  @State showGate: boolean = false
  @State showDiagnose: boolean = false
  @State showMessages: boolean = false
  @State quiz: QuizState = new QuizState()
  @State question: QuizQuestion = new QuizQuestion()
  @State resultTitle: string = '本关完成'
  @State resultStars: number = 1
  @State resultCorrect: number = 0
  @State resultTotal: number = 4
  @State detailItem: CatalogItem = new CatalogItem()
  @State detailCta: string = '开始闯关'
  @State gateTarget: string = 'report'
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('kkDetailOpen') @Watch('onDetailFlag') detailOpen: boolean = false
  @StorageLink('kkDetailKind') detailKind: string = 'level'
  @StorageLink('kkDetailId') detailId: string = ''
  @StorageLink('kkDetailCta') detailCtaLink: string = '开始闯关'
  @Prop appName: string = '益智王国'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    void this.bootstrap()
  }

  onDetailFlag(): void {
    if (this.detailOpen) {
      this.resolveDetail()
    }
  }

  private async bootstrap(): Promise<void> {
    this.levels = await KingdomBizService.loadLevels()
    this.questions = await KingdomBizService.loadQuestions()
    this.dailies = await KingdomBizService.loadDailies()
    this.relics = await KingdomBizService.loadRelics()
    this.guides = await KingdomBizService.loadGuides()
    this.relicViews = KingdomBizService.relicViews(this.relics)
    this.tick += 1
  }

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private bump(): void {
    this.relicViews = KingdomBizService.relicViews(this.relics)
    this.tick += 1
  }

  private showToast(text: string): void {
    this.toastText = text
    setTimeout(() => {
      this.toastText = ''
    }, 2400)
  }

  private startLevel(level: CatalogItem): void {
    if (level.id.length === 0) {
      this.showToast('关卡还在路上，请稍后重试')
      return
    }
    const qs = KingdomBizService.questionsForLevel(level.id, this.questions)
    if (qs.length === 0) {
      this.showToast('这一关题目还没备好')
      return
    }
    const state = new QuizState()
    state.kind = 'level'
    state.levelId = level.id
    state.questions = qs
    state.index = 0
    state.correct = 0
    state.startedAt = Date.now()
    this.quiz = state
    this.question = qs[0]
    this.showResult = false
    this.showQuiz = true
    this.hideBar(true)
  }

  private startDaily(): void {
    const item = KingdomBizService.todayDaily(this.dailies)
    if (item.id.length === 0) {
      this.showToast('今日题目还在路上')
      return
    }
    const q = KingdomBizService.toQuestion(item)
    q.levelId = item.id
    const qs: QuizQuestion[] = []
    qs.push(q)
    const state = new QuizState()
    state.kind = 'daily'
    state.levelId = item.id
    state.questions = qs
    state.index = 0
    state.correct = 0
    state.startedAt = Date.now()
    this.quiz = state
    this.question = q
    this.showResult = false
    this.showQuiz = true
    this.hideBar(true)
  }

  private onAnswer(ok: boolean): void {
    setTimeout(() => {
      this.advance(ok)
    }, 700)
  }

  private advance(ok: boolean): void {
    const nextQuiz = new QuizState()
    nextQuiz.kind = this.quiz.kind
    nextQuiz.levelId = this.quiz.levelId
    nextQuiz.questions = this.quiz.questions
    nextQuiz.index = this.quiz.index
    nextQuiz.correct = this.quiz.correct
    nextQuiz.startedAt = this.quiz.startedAt
    if (ok) {
      nextQuiz.correct += 1
    }
    const nextIndex = nextQuiz.index + 1
    if (nextIndex >= nextQuiz.questions.length) {
      void this.finishQuiz(nextQuiz)
      return
    }
    nextQuiz.index = nextIndex
    this.quiz = nextQuiz
    this.question = nextQuiz.questions[nextIndex]
  }

  private async finishQuiz(state: QuizState): Promise<void> {
    let stars = 1
    if (state.kind === 'daily') {
      const item = KingdomBizService.findById(state.levelId, this.dailies)
      stars = await KingdomBizService.recordDaily(item, state.correct > 0)
      this.resultTitle = '每日益智完成'
    } else {
      const level = KingdomBizService.findById(state.levelId, this.levels)
      stars = await KingdomBizService.recordLevel(
        level.id,
        level.kind,
        level.skill,
        state.correct,
        state.questions.length
      )
      this.resultTitle = '本关完成'
    }
    this.quiz = state
    this.resultStars = stars
    this.resultCorrect = state.correct
    this.resultTotal = state.questions.length
    this.showQuiz = false
    this.showResult = true
    this.bump()
  }

  private closeOverlays(): void {
    this.showQuiz = false
    this.showResult = false
    this.showCollect = false
    this.showSettings = false
    this.showGate = false
    this.showDiagnose = false
    this.showMessages = false
    KingdomDetailNav.close()
    this.hideBar(false)
  }

  private resolveDetail(): void {
    this.detailCta = this.detailCtaLink
    let list: CatalogItem[] = this.levels
    if (this.detailKind === 'daily') {
      list = this.dailies
    } else if (this.detailKind === 'relic') {
      list = this.relics
    } else if (this.detailKind === 'guide') {
      list = this.guides
    } else if (this.detailKind === 'question') {
      list = this.questions
    }
    this.detailItem = KingdomBizService.findById(this.detailId, list)
  }

  private onDetailAction(): void {
    const kind = this.detailKind
    const item = this.detailItem
    KingdomDetailNav.close()
    if (kind === 'level') {
      this.startLevel(item)
      return
    }
    if (kind === 'daily') {
      this.startDaily()
      return
    }
    if (kind === 'guide') {
      this.startLevel(KingdomBizService.nextPlayable(this.levels))
    }
  }

  private requestReport(): void {
    if (ParentGateService.isVerified()) {
      this.current = 2
      return
    }
    this.gateTarget = 'report'
    this.showGate = true
    this.hideBar(true)
  }

  private requestSettings(): void {
    if (ParentGateService.isVerified()) {
      this.showSettings = true
      this.hideBar(true)
      return
    }
    this.gateTarget = 'settings'
    this.showGate = true
    this.hideBar(true)
  }

  private onGatePass(): void {
    this.showGate = false
    if (this.gateTarget === 'settings') {
      this.showSettings = true
      this.hideBar(true)
      return
    }
    this.current = 2
    this.hideBar(false)
  }

  private playAgain(): void {
    this.showResult = false
    if (this.quiz.kind === 'daily') {
      this.startDaily()
      return
    }
    this.startLevel(KingdomBizService.nextPlayable(this.levels))
  }

  private tapTab(t: TabItem): void {
    if (t.index === 2) {
      this.requestReport()
      return
    }
    this.current = t.index
    this.hideBar(false)
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.tick,
            levels: this.levels,
            dailies: this.dailies,
            guides: this.guides,
            onStepStone: () => this.startLevel(KingdomBizService.nextPlayable(this.levels)),
            onOpenChallenge: () => { this.current = 1 },
            onOpenDaily: () => this.startDaily(),
            onOpenReport: () => this.requestReport(),
            onOpenCollection: () => {
              this.showCollect = true
              this.hideBar(true)
            }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          ChallengeMapPage({
            refreshToken: this.tick,
            levels: this.levels,
            onLocked: () => this.showToast('先点亮前面的石阶')
          }).layoutWeight(1)
        } else if (this.current === 2) {
          ReportPage({
            refreshToken: this.tick,
            onOpenDiagnose: () => {
              this.showDiagnose = true
              this.hideBar(true)
            }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.tick,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => this.onLogout(),
            onOpenCollection: () => {
              this.showCollect = true
              this.hideBar(true)
            },
            onOpenMessages: () => {
              this.showMessages = true
              this.hideBar(true)
            },
            onOpenPracticeSettings: () => this.requestSettings()
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showQuiz) {
        QuizOverlay({
          question: this.question,
          questionId: this.question.id,
          index: this.quiz.index,
          total: this.quiz.questions.length,
          onAnswer: (ok: boolean) => this.onAnswer(ok),
          onClose: () => this.closeOverlays()
        })
          .width('100%')
          .height('100%')
      }
      if (this.showResult) {
        ResultOverlay({
          title: this.resultTitle,
          stars: this.resultStars,
          correct: this.resultCorrect,
          total: this.resultTotal,
          onAgain: () => this.playAgain(),
          onHome: () => {
            this.closeOverlays()
            this.current = 0
          }
        })
          .width('100%')
          .height('100%')
      }
      if (this.showCollect) {
        CollectionOverlay({
          relics: this.relicViews,
          onClose: () => this.closeOverlays()
        })
          .width('100%')
          .height('100%')
      }
      if (this.showSettings) {
        SettingsOverlay({ onClose: () => this.closeOverlays() })
          .width('100%')
          .height('100%')
      }
      if (this.showGate) {
        ParentGateOverlay({
          onPass: () => this.onGatePass(),
          onClose: () => this.closeOverlays()
        })
          .width('100%')
          .height('100%')
      }
      if (this.showDiagnose) {
        AIAssistantPage({
          onClose: () => this.closeOverlays(),
          onBookFromAi: (_c: string) => {
            this.closeOverlays()
            this.current = 1
          }
        })
          .width('100%')
          .height('100%')
      }
      if (this.showMessages) {
        MessagesPage({ onBack: () => this.closeOverlays() })
          .width('100%')
          .height('100%')
      }
      if (this.detailOpen) {
        CatalogDetailPane({
          item: this.detailItem,
          ctaLabel: this.detailCta,
          onClose: () => KingdomDetailNav.close(),
          onAction: () => this.onDetailAction()
        })
          .width('100%')
          .height('100%')
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => this.tapTab(t))
  }
}
