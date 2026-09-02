import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { PracticePage } from './PracticePage'
import { GrowthPage } from './GrowthPage'
import { MinePage } from './MinePage'
import { QuizOverlay } from '../components/math/QuizOverlay'
import { ResultOverlay } from '../components/math/ResultOverlay'
import { WrongBookOverlay } from '../components/math/WrongBookOverlay'
import { TimesTableOverlay } from '../components/math/TimesTableOverlay'
import { CustomSetListOverlay } from '../components/math/CustomSetListOverlay'
import { CustomSetEditorOverlay } from '../components/math/CustomSetEditorOverlay'
import { PackListOverlay } from '../components/math/PackListOverlay'
import { TimelineOverlay } from '../components/math/TimelineOverlay'
import { CheckInOverlay } from '../components/math/CheckInOverlay'
import { GoalOverlay } from '../components/math/GoalOverlay'
import { ReviewOverlay } from '../components/math/ReviewOverlay'
import { CatalogDetailPane } from '../components/detail/CatalogDetailPane'
import { CatalogItem, CustomSet, MathQuestion, PracticeSession, QuizState, StudyPack, WrongItem } from '../models/MathModels'
import { MathBizService } from '../services/MathBizService'
import { MathCatalog } from '../services/MathCatalog'
import { MathEngine } from '../services/MathEngine'
import { MathLocalStore } from '../services/MathLocalStore'
import { MathQuizLaunch } from '../services/MathQuizLaunch'
import { MathDetailNav } from '../services/MathDetailNav'
import { MathRefresh } from '../services/MathRefresh'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem(); t0.index = 0; t0.name = 'home'; t0.label = '首页'; tabs.push(t0)
    const t1 = new TabItem(); t1.index = 1; t1.name = 'biz'; t1.label = '练习'; tabs.push(t1)
    const t2 = new TabItem(); t2.index = 2; t2.name = 'chart'; t2.label = '成长'; tabs.push(t2)
    const t3 = new TabItem(); t3.index = 3; t3.name = 'user'; t3.label = '我的'; tabs.push(t3)
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
  @State showFav: boolean = false
  @State showTable: boolean = false
  @State showCustomList: boolean = false
  @State showCustomEdit: boolean = false
  @State showPack: boolean = false
  @State showTimeline: boolean = false
  @State showCheckIn: boolean = false
  @State showGoal: boolean = false
  @State showReview: boolean = false
  @State editSetId: string = ''
  @State quiz: QuizState = new QuizState()
  @State question: MathQuestion = new MathQuestion()
  @State quizKey: string = ''
  @State quizExpr: string = ''
  @State quizStory: string = ''
  @State quizHint: string = ''
  @State quizType: string = 'fill'
  @State quizChoiceA: string = ''
  @State quizChoiceB: string = ''
  @State quizChoiceC: string = ''
  @State quizFav: boolean = false
  @State misses: WrongItem[] = []
  @State session: PracticeSession = new PracticeSession()
  @State detailItem: CatalogItem = new CatalogItem()
  @State detailCta: string = '开始练习'
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('mathDetailOpen') @Watch('onDetailFlag') detailOpen: boolean = false
  @StorageLink('mathDetailKind') detailKind: string = 'mode'
  @StorageLink('mathDetailId') detailId: string = ''
  @Prop appName: string = '童趣算坊'
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

  private refreshHome(): void {
    MathRefresh.bump()
    this.homeTick += 1
  }

  private pickQuestion(list: MathQuestion[], index: number): MathQuestion {
    let i = 0
    for (const q of list) {
      if (i === index) {
        return q
      }
      i += 1
    }
    return new MathQuestion()
  }

  private applyQuestion(q: MathQuestion): void {
    this.question = q
    this.quizKey = q.id
    this.quizExpr = q.expression
    this.quizStory = q.story
    this.quizHint = q.hint
    this.quizType = q.qType
    this.quizChoiceA = q.choiceA
    this.quizChoiceB = q.choiceB
    this.quizChoiceC = q.choiceC
    this.quizFav = MathBizService.isFavorite(q.expression)
  }

  private async onToggleFav(): Promise<void> {
    const w = new WrongItem()
    w.expression = this.question.expression
    w.correctAnswer = MathEngine.displayAnswer(this.question)
    w.left = this.question.left
    w.right = this.question.right
    w.op = this.question.op
    w.qType = this.question.qType
    w.story = this.question.story
    w.answerLabel = this.question.answerLabel
    w.choiceA = this.question.choiceA
    w.choiceB = this.question.choiceB
    w.choiceC = this.question.choiceC
    w.tag = MathBizService.tagOfOp(this.question.op)
    this.quizFav = await MathBizService.toggleFavorite(w)
  }

  private startQuiz(kind: string, mode: string, preset: MathQuestion[] = [], challengeId: string = '',
    countOverride: number = 0, limitSec: number = 0): void {
    const state = MathQuizLaunch.build(kind, mode, preset, challengeId, countOverride, limitSec)
    if (state.questions.length === 0) {
      return
    }
    this.quiz = state
    this.applyQuestion(this.pickQuestion(state.questions, 0))
    this.misses = []
    this.showResult = false
    this.showWrong = false
    this.showFav = false
    this.showTable = false
    this.showCustomList = false
    this.showCustomEdit = false
    this.showPack = false
    this.showTimeline = false
    this.showCheckIn = false
    this.showGoal = false
    this.showReview = false
    this.showQuiz = true
    this.hideBar(true)
  }

  private launchPlan(): void {
    void MathBizService.startPlan().then(() => {
      this.startQuiz('plan', MathQuizLaunch.planMode(), [], '', 8)
      this.refreshHome()
    })
  }

  private launchWeak(): void {
    this.startQuiz('weak', MathBizService.weakHint().mode, [], '', 8)
  }

  private async onAnswer(ok: boolean, typed: string): Promise<void> {
    const nextQuiz = new QuizState()
    nextQuiz.kind = this.quiz.kind
    nextQuiz.mode = this.quiz.mode
    nextQuiz.questions = this.quiz.questions
    nextQuiz.index = this.quiz.index
    nextQuiz.correct = this.quiz.correct
    nextQuiz.startedAt = this.quiz.startedAt
    nextQuiz.limitSec = this.quiz.limitSec
    nextQuiz.challengeId = this.quiz.challengeId
    if (ok) {
      nextQuiz.correct += 1
    } else {
      const w = new WrongItem()
      w.id = MathLocalStore.newId('wrong')
      w.expression = this.question.expression
      w.userAnswer = typed
      w.correctAnswer = MathEngine.displayAnswer(this.question)
      w.lastAt = MathLocalStore.today()
      w.left = this.question.left
      w.right = this.question.right
      w.op = this.question.op
      w.qType = this.question.qType
      w.story = this.question.story
      w.answerLabel = MathEngine.displayAnswer(this.question)
      w.choiceA = this.question.choiceA
      w.choiceB = this.question.choiceB
      w.choiceC = this.question.choiceC
      w.tag = MathBizService.tagOfOp(this.question.op)
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
        this.misses,
        nextQuiz.challengeId
      )
      this.session = sess
      this.quiz = nextQuiz
      this.showQuiz = false
      this.showResult = true
      this.refreshHome()
      return
    }
    nextQuiz.index = nextIndex
    this.quiz = nextQuiz
    this.applyQuestion(this.pickQuestion(nextQuiz.questions, nextIndex))
  }

  private closeOverlays(): void {
    this.showQuiz = false
    this.showResult = false
    this.showWrong = false
    this.showFav = false
    this.showTable = false
    this.showCustomList = false
    this.showCustomEdit = false
    this.showPack = false
    this.showTimeline = false
    this.showCheckIn = false
    this.showGoal = false
    this.showReview = false
    MathDetailNav.close()
    this.hideBar(false)
    this.refreshHome()
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
    void MathBizService.pushRecent(this.detailId)
  }

  build() {
    Stack() {
      Column() {
        Stack() {
        HomePage({
          refreshToken: this.homeTick,
          onStartDaily: () => this.startQuiz('daily', 'mix'),
          onQuick: (mode: string) => this.startQuiz('practice', mode),
          onWarm: () => this.startQuiz('warm', 'age68', [], '', 5),
          onStory: () => this.startQuiz('story', 'story', [], '', 8),
          onWeak: () => this.launchWeak(),
          onPlan: () => this.launchPlan(),
          onFav: () => { this.showFav = true; this.hideBar(true) },
          onTable: () => { this.showTable = true; this.hideBar(true) },
          onCustom: () => { this.showCustomList = true; this.hideBar(true) },
          onPack: () => { this.showPack = true; this.hideBar(true) },
          onCheckIn: () => { this.showCheckIn = true; this.hideBar(true) },
          onTimeline: () => { this.showTimeline = true; this.hideBar(true) },
          onGoal: () => { this.showGoal = true; this.hideBar(true) },
          onReview: () => { this.showReview = true; this.hideBar(true) }
        })
          .width('100%')
          .height('100%')
          .visibility(this.current === 0 ? Visibility.Visible : Visibility.None)
        PracticePage({
          refreshToken: this.homeTick,
          onOpenWrong: () => { this.showWrong = true; this.hideBar(true) },
          onOpenFav: () => { this.showFav = true; this.hideBar(true) },
          onOpenTable: () => { this.showTable = true; this.hideBar(true) },
          onOpenCustom: () => { this.showCustomList = true; this.hideBar(true) },
          onOpenPack: () => { this.showPack = true; this.hideBar(true) }
        })
          .width('100%')
          .height('100%')
          .visibility(this.current === 1 ? Visibility.Visible : Visibility.None)
        GrowthPage({
          refreshToken: this.homeTick,
          onPlan: () => this.launchPlan(),
          onWeak: () => this.launchWeak(),
          onTimeline: () => { this.showTimeline = true; this.hideBar(true) },
          onGoal: () => { this.showGoal = true; this.hideBar(true) },
          onReview: () => { this.showReview = true; this.hideBar(true) }
        })
          .width('100%')
          .height('100%')
          .visibility(this.current === 2 ? Visibility.Visible : Visibility.None)
        MinePage({
          appName: this.appName,
          refreshToken: this.homeTick,
          onOpenLogin: () => this.onOpenLogin(),
          onLogout: () => this.onLogout()
        })
          .width('100%')
          .height('100%')
          .visibility(this.current === 3 ? Visibility.Visible : Visibility.None)
        }
        .layoutWeight(1)
        .width('100%')
        .height('100%')

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
              .onClick(() => {
                this.current = tab.index
                if (tab.index === 0) {
                  this.refreshHome()
                }
              })
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
          title: MathQuizLaunch.title(this.quiz.kind),
          total: this.quiz.questions.length,
          index: this.quiz.index,
          quizKey: this.quizKey,
          question: this.question,
          expression: this.quizExpr,
          story: this.quizStory,
          hint: this.quizHint,
          qType: this.quizType,
          choiceA: this.quizChoiceA,
          choiceB: this.quizChoiceB,
          choiceC: this.quizChoiceC,
          favOn: this.quizFav,
          motion: MathLocalStore.settings().motion,
          sound: MathLocalStore.settings().sound,
          limitSec: this.quiz.limitSec,
          onClose: () => this.closeOverlays(),
          onAnswer: (ok: boolean, typed: string) => { void this.onAnswer(ok, typed) },
          onToggleFav: () => { void this.onToggleFav() }
        })
      }
      if (this.showResult) {
        ResultOverlay({
          session: this.session,
          onAgain: () => this.startQuiz(this.quiz.kind, this.quiz.mode, [], '',
            this.quiz.questions.length, this.quiz.limitSec),
          onHome: (): void => {
            this.closeOverlays()
            this.current = 0
            this.refreshHome()
          }
        })
      }
      if (this.showTable) {
        TimesTableOverlay({
          onClose: () => this.closeOverlays(),
          onDrill: (n: number) => this.startQuiz('table', 'table_mul', MathEngine.tableDrill(n, 8))
        })
      }
      if (this.showCustomList) {
        CustomSetListOverlay({
          onClose: () => this.closeOverlays(),
          onCreate: () => { this.editSetId = ''; this.showCustomList = false; this.showCustomEdit = true },
          onEdit: (set: CustomSet) => {
            this.editSetId = set.id
            this.showCustomList = false
            this.showCustomEdit = true
          },
          onPractice: (set: CustomSet) => this.startQuiz('custom', 'add', MathEngine.fromCustom(set.items))
        })
      }
      if (this.showCustomEdit) {
        CustomSetEditorOverlay({
          editId: this.editSetId,
          onClose: () => { this.showCustomEdit = false; this.showCustomList = true },
          onSaved: (set: CustomSet) => {
            this.showCustomEdit = false
            this.startQuiz('custom', 'add', MathEngine.fromCustom(set.items))
          }
        })
      }
      if (this.showPack) {
        PackListOverlay({
          onClose: () => this.closeOverlays(),
          onPractice: (pack: StudyPack) => {
            const ops = MathBizService.packOps(pack)
            this.startQuiz('pack', 'mix', MathEngine.generateOps(ops, 10, MathLocalStore.settings().difficulty))
          }
        })
      }
      if (this.showTimeline) {
        TimelineOverlay({ onClose: () => this.closeOverlays() })
      }
      if (this.showCheckIn) {
        CheckInOverlay({ onClose: () => this.closeOverlays() })
      }
      if (this.showGoal) {
        GoalOverlay({ onClose: () => this.closeOverlays() })
      }
      if (this.showReview) {
        ReviewOverlay({ onClose: () => this.closeOverlays() })
      }
      if (this.showWrong) {
        WrongBookOverlay({
          bookKind: 'wrong',
          onClose: () => this.closeOverlays(),
          onRetryOne: (item: WrongItem) => this.startQuiz('wrong', item.op, MathEngine.fromWrong([item])),
          onRetryAll: () => {
            const items = MathLocalStore.snapshot().wrongs
            this.startQuiz('wrong', 'mix', MathEngine.fromWrong(items))
          }
        })
      }
      if (this.showFav) {
        WrongBookOverlay({
          bookKind: 'fav',
          title: '数学收藏夹',
          emptyHint: '答题时点「收藏本题」，会出现在这里',
          onClose: () => this.closeOverlays(),
          onRetryOne: (item: WrongItem) => this.startQuiz('fav', item.op, MathEngine.fromWrong([item])),
          onRetryAll: () => {
            const items = MathLocalStore.snapshot().favorites
            this.startQuiz('fav', 'mix', MathEngine.fromWrong(items))
          }
        })
      }
      if (this.detailOpen) {
        CatalogDetailPane({
          item: this.detailItem,
          ctaLabel: this.detailCta,
          onClose: (): void => {
            MathDetailNav.close()
          },
          onAction: (): void => {
            MathDetailNav.close()
            if (this.detailKind === 'mode') {
              this.startQuiz('practice', this.detailItem.operator.length > 0 ? this.detailItem.operator : 'mix')
            } else if (this.detailKind === 'challenge') {
              if (this.detailId === 'km_ch_daily') {
                this.startQuiz('daily', 'mix')
              } else {
                this.startQuiz('challenge', 'mix', [], this.detailId)
              }
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
