import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { PracticePage } from './PracticePage'
import { GrowthPage } from './GrowthPage'
import { MinePage } from './MinePage'
import { QuizOverlay } from '../components/math/QuizOverlay'
import { ResultOverlay } from '../components/math/ResultOverlay'
import { WrongBookOverlay } from '../components/math/WrongBookOverlay'
import { CatalogDetailPane } from '../components/detail/CatalogDetailPane'
import { CatalogItem, MathQuestion, PracticeSession, QuizState, WrongItem } from '../models/MathModels'
import { MathBizService } from '../services/MathBizService'
import { MathCatalog } from '../services/MathCatalog'
import { MathEngine } from '../services/MathEngine'
import { MathLocalStore } from '../services/MathLocalStore'
import { MathDetailNav } from '../services/MathDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem(); t0.index = 0; t0.name = 'home'; t0.label = '智慧闯关'; tabs.push(t0)
    const t1 = new TabItem(); t1.index = 1; t1.name = 'biz'; t1.label = '趣味训练'; tabs.push(t1)
    const t2 = new TabItem(); t2.index = 2; t2.name = 'chart'; t2.label = '成长徽章'; tabs.push(t2)
    const t3 = new TabItem(); t3.index = 3; t3.name = 'user'; t3.label = '智慧设置'; tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State homeTick: number = 0
  @State showQuiz: boolean = false
  @State showResult: boolean = false
  @State showWrong: boolean = false
  @State quiz: QuizState = new QuizState()
  @State question: MathQuestion = new MathQuestion()
  @State misses: WrongItem[] = []
  @State session: PracticeSession = new PracticeSession()
  @State detailItem: CatalogItem = new CatalogItem()
  @State detailCta: string = '开始练习'
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('mathDetailOpen') @Watch('onDetailFlag') detailOpen: boolean = false
  @StorageLink('mathDetailKind') detailKind: string = 'mode'
  @StorageLink('mathDetailId') detailId: string = ''
  @Prop appName: string = '趣味算学'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  onDetailFlag(): void {
    if (this.detailOpen) {
      this.openDetail()
    }
  }

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private bump(): void {
    this.homeTick += 1
  }

  private startQuiz(kind: string, mode: string, preset?: MathQuestion[]): void {
    const settings = MathLocalStore.settings()
    let count = settings.dailyCount
    if (kind === 'practice' || kind === 'challenge' || kind === 'wrong') {
      count = settings.practiceCount
    }
    const questions = preset !== undefined && preset.length > 0 ?
      preset : MathEngine.generate(mode, count, settings.difficulty)
    const state = new QuizState()
    state.kind = kind
    state.mode = mode
    state.questions = questions
    state.index = 0
    state.correct = 0
    state.startedAt = Date.now()
    this.quiz = state
    this.question = questions[0]
    this.misses = []
    this.showResult = false
    this.showWrong = false
    this.showQuiz = true
    this.hideBar(true)
  }

  private async onAnswer(ok: boolean, typed: string): Promise<void> {
    const nextQuiz = new QuizState()
    nextQuiz.kind = this.quiz.kind
    nextQuiz.mode = this.quiz.mode
    nextQuiz.questions = this.quiz.questions
    nextQuiz.index = this.quiz.index
    nextQuiz.correct = this.quiz.correct
    nextQuiz.startedAt = this.quiz.startedAt
    if (ok) {
      nextQuiz.correct += 1
    } else {
      const w = new WrongItem()
      w.id = MathLocalStore.newId('wrong')
      w.expression = this.question.expression
      w.userAnswer = typed
      w.correctAnswer = `${this.question.answer}`
      w.lastAt = MathLocalStore.today()
      w.left = this.question.left
      w.right = this.question.right
      w.op = this.question.op
      const next: WrongItem[] = []
      for (const m of this.misses) {
        next.push(m)
      }
      next.push(w)
      this.misses = next
    }
    const nextIndex = nextQuiz.index + 1
    if (nextIndex >= nextQuiz.questions.length) {
      const sess = await MathBizService.recordSession(
        nextQuiz.kind,
        nextQuiz.mode,
        nextQuiz.questions,
        nextQuiz.correct,
        Date.now() - nextQuiz.startedAt,
        this.misses
      )
      this.session = sess
      this.quiz = nextQuiz
      this.showQuiz = false
      this.showResult = true
      this.bump()
      return
    }
    nextQuiz.index = nextIndex
    this.quiz = nextQuiz
    this.question = nextQuiz.questions[nextIndex]
  }

  private closeOverlays(): void {
    this.showQuiz = false
    this.showResult = false
    this.showWrong = false
    MathDetailNav.close()
    this.hideBar(false)
  }

  private openDetail(): void {
    let list: CatalogItem[] = []
    if (this.detailKind === 'mode') {
      list = MathCatalog.modes()
      this.detailCta = '开始练习'
    } else if (this.detailKind === 'challenge') {
      list = MathCatalog.challenges()
      this.detailCta = '开始闯关'
    } else if (this.detailKind === 'medal') {
      list = MathCatalog.medals()
      this.detailCta = '去练习'
    } else {
      list = MathCatalog.tips()
      this.detailCta = '开始计算'
    }
    this.detailItem = MathBizService.findCatalog(this.detailId, list)
    if (this.detailItem.id.length === 0 && this.detailKind === 'mode') {
      this.detailItem = MathBizService.findMode(this.detailId, list)
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.homeTick,
            onStartDaily: () => this.startQuiz('daily', 'mix'),
            onQuick: (mode: string) => this.startQuiz('practice', mode)
          }).layoutWeight(1)
        } else if (this.current === 1) {
          PracticePage({
            refreshToken: this.homeTick,
            onOpenWrong: () => { this.showWrong = true; this.hideBar(true) }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          GrowthPage({ refreshToken: this.homeTick }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.homeTick,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => this.onLogout()
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (tab: TabItem) => {
              Column({ space: 4 }) {
                Column() {
                  AppIcon({
                    name: tab.name,
                    iconSize: 24,
                    color: this.current === tab.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
                  })
                }
                .width(44)
                .height(28)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.current === tab.index ? Theme.colors().brandPrimaryContainer : Color.Transparent)
                .borderRadius(Theme.radius.pill)
                Text(tab.label)
                  .fontSize(10)
                  .fontWeight(this.current === tab.index ? FontWeight.Medium : FontWeight.Normal)
                  .fontColor(this.current === tab.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .height(56)
              .justifyContent(FlexAlign.Center)
              .onClick(() => { this.current = tab.index })
            }, (tab: TabItem) => `${tab.index}`)
          }
          .width('100%')
          .padding({ left: 8, right: 8, bottom: 6 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showQuiz) {
        QuizOverlay({
          title: this.quiz.kind === 'daily' ? '今日智慧挑战' : (this.quiz.kind === 'challenge' ? '闯关挑战' : '趣味训练'),
          total: this.quiz.questions.length,
          index: this.quiz.index,
          question: this.question,
          motion: MathLocalStore.settings().motion,
          timedMode: MathLocalStore.settings().timedMode,
          onClose: () => this.closeOverlays(),
          onAnswer: (ok: boolean, typed: string) => { void this.onAnswer(ok, typed) }
        })
      }
      if (this.showResult) {
        ResultOverlay({
          session: this.session,
          onAgain: () => this.startQuiz('challenge', this.quiz.mode),
          onHome: () => { this.closeOverlays(); this.current = 0 }
        })
      }
      if (this.showWrong) {
        WrongBookOverlay({
          items: MathLocalStore.snapshot().wrongs,
          onClose: () => this.closeOverlays(),
          onRetryOne: (item: WrongItem) => this.startQuiz('wrong', item.op, MathEngine.fromWrong([item])),
          onRetryAll: () => {
            const items = MathLocalStore.snapshot().wrongs
            this.startQuiz('wrong', 'mix', MathEngine.fromWrong(items))
          }
        })
      }
      if (this.detailOpen) {
        CatalogDetailPane({
          item: this.detailItem,
          ctaLabel: this.detailCta,
          onClose: () => MathDetailNav.close(),
          onAction: () => {
            MathDetailNav.close()
            if (this.detailKind === 'mode') {
              this.startQuiz('practice', this.detailItem.operator.length > 0 ? this.detailItem.operator : 'mix')
            } else if (this.detailKind === 'challenge') {
              this.startQuiz(this.detailId === 'km_ch_daily' ? 'daily' : 'challenge', 'mix')
            } else {
              this.startQuiz('daily', 'mix')
            }
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
