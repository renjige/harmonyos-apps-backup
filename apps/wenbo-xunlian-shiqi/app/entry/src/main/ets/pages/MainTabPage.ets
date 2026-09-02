import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { RecordPage } from './RecordPage'
import { DiscoverPage } from './DiscoverPage'
import { GrowthPage } from './GrowthPage'
import { MinePage } from './MinePage'
import { PlayTabPage } from './PlayTabPage'
import { FollowAlongPage } from './FollowAlongPage'
import { SportRoulettePage } from './SportRoulettePage'
import { BreathGuidePage } from './BreathGuidePage'
import { WeekPlaybookPage } from './WeekPlaybookPage'
import { RecapQuizPage } from './RecapQuizPage'
import { PlanHubPage } from '../components/practice/PlanHubPage'
import { MoveHubPage } from '../components/practice/MoveHubPage'
import { GoalHubPage } from '../components/practice/GoalHubPage'
import { CheckHubPage } from '../components/practice/CheckHubPage'
import { CardHubPage } from '../components/practice/CardHubPage'
import { TrainingFormOverlay } from '../components/training/TrainingFormOverlay'
import { FunQuestFormOverlay } from '../components/training/FunQuestFormOverlay'
import { TrainingDetailPane } from '../components/detail/TrainingDetailPane'
import { FunQuestDetailPane } from '../components/detail/FunQuestDetailPane'
import { TrainingDraft, FunQuestDraft, AchievementItem } from '../models/TrainingModels'
import { TrainingRecordService } from '../services/TrainingRecordService'
import { FunQuestService } from '../services/FunQuestService'
import { TrainingStore } from '../services/TrainingStore'
import { FunQuestStore } from '../services/FunQuestStore'
import { TrainingDetailNav } from '../services/TrainingDetailNav'
import { PracticeNav } from '../services/PracticeNav'
import { DataRefresh } from '../services/DataRefresh'
import { AchievementEngine } from '../services/AchievementEngine'
import { VitalityService } from '../services/VitalityService'
import { QuoteService } from '../services/QuoteService'
import { FeatureTourOverlay } from '../components/onboarding/FeatureTourOverlay'
import { MoveCatalog } from '../services/MoveCatalog'
import { FollowAlongService } from '../services/FollowAlongService'
import { PracticeHubStore } from '../services/PracticeHubStore'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '首页'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'ai'
    t1.label = '玩法'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'sparkle'
    t2.label = '发现'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'chart'
    t3.label = '成长'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('mainTabIndex') current: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('trainingDetailId') trainingDetailId: string = ''
  @StorageLink('questDetailId') questDetailId: string = ''
  @StorageLink('showTrainingForm') showTrainingForm: boolean = false
  @StorageLink('showQuestForm') showQuestForm: boolean = false
  @StorageLink('showRecap') showRecap: boolean = false
  @StorageLink('practiceHubKind') practiceHubKind: string = ''
  @StorageLink('showFeatureTour') showFeatureTour: boolean = false
  @StorageLink('showFollowAlong') showFollowAlong: boolean = false
  @StorageLink('showSportRoulette') showSportRoulette: boolean = false
  @StorageLink('showBreathGuide') showBreathGuide: boolean = false
  @StorageLink('showWeekPlaybook') showWeekPlaybook: boolean = false
  @State dataRefresh: number = 0
  @State draft: TrainingDraft = TrainingRecordService.emptyDraft()
  @State formError: string = ''
  @State questDraft: FunQuestDraft = FunQuestService.emptyDraft()
  @State questFormError: string = ''
  @State feedbackVisible: boolean = false
  @State feedbackQuote: string = ''
  @State feedbackBadge: AchievementItem = new AchievementItem()
  @State feedbackHasBadge: boolean = false
  private tabs: TabItem[] = TabItem.all()

  private bumpRefresh(): void {
    this.dataRefresh += 1
    DataRefresh.bump()
  }

  private openForm(): void {
    this.draft = TrainingRecordService.emptyDraft()
    this.formError = ''
    this.showTrainingForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openFormWithDraft(draft: TrainingDraft): void {
    this.draft = TrainingRecordService.copy(draft)
    this.formError = ''
    this.showTrainingForm = true
    PracticeNav.closeFollowAlong()
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showTrainingForm = false
    TrainingDetailNav.restoreTabBar()
  }

  private openQuestForm(): void {
    this.questDraft = FunQuestService.emptyDraft()
    this.questFormError = ''
    this.showQuestForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeQuestForm(): void {
    this.showQuestForm = false
    TrainingDetailNav.restoreTabBar()
  }

  private async submitForm(): Promise<void> {
    const beforeIds = AchievementEngine.unlockedIds()
    const res = TrainingRecordService.create(this.draft)
    if (!res.ok) {
      this.formError = res.message
      return
    }
    await TrainingStore.saveItem(res.record)
    await VitalityService.markTrainDone()
    if (res.record.note.length > 0 || res.record.harvest.length > 0) {
      await VitalityService.toggleNote()
    }
    this.closeForm()
    this.bumpRefresh()
    const badge = AchievementEngine.detectNewUnlock(beforeIds)
    this.feedbackQuote = QuoteService.randomQuote()
    this.feedbackHasBadge = badge !== null
    if (badge !== null) {
      this.feedbackBadge = badge
    }
    this.feedbackVisible = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private async submitQuest(): Promise<void> {
    const res = FunQuestService.create(this.questDraft)
    if (!res.ok) {
      this.questFormError = res.message
      return
    }
    await FunQuestStore.saveItem(res.quest)
    await VitalityService.award(5)
    this.closeQuestForm()
    this.bumpRefresh()
  }

  private closeFeedback(): void {
    this.feedbackVisible = false
    TrainingDetailNav.restoreTabBar()
  }

  private handleRecapAction(): void {
    TrainingDetailNav.closeRecap()
    if (this.current !== 2) {
      this.current = 2
      AppStorage.setOrCreate('mainTabIndex', 2)
    }
  }

  private closePlayOverlays(): void {
    AppStorage.setOrCreate('showSportRoulette', false)
    AppStorage.setOrCreate('showBreathGuide', false)
    AppStorage.setOrCreate('showWeekPlaybook', false)
  }

  private async handlePlayAction(action: string): Promise<void> {
    this.closePlayOverlays()
    if (action === 'follow') {
      PracticeNav.openFollowAlong()
      return
    }
    if (action === 'breath') {
      PracticeNav.openBreath()
      return
    }
    if (action === 'discover') {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = 2
      AppStorage.setOrCreate('mainTabIndex', 2)
      return
    }
    if (action === 'growth') {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = 3
      AppStorage.setOrCreate('mainTabIndex', 3)
      return
    }
    if (action === 'challenge') {
      await FunQuestStore.saveItem(FunQuestService.fromHall('d7'))
      await VitalityService.award(5)
      this.bumpRefresh()
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = 2
      AppStorage.setOrCreate('mainTabIndex', 2)
      return
    }
    if (action === 'recap') {
      AppStorage.setOrCreate('tabBarHidden', false)
      TrainingDetailNav.openRecap()
      return
    }
    if (action === 'record') {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.openForm()
      return
    }
    if (action === 'card' || action === 'goal' || action === 'check' || action === 'plan') {
      PracticeNav.openHub(action)
    }
  }

  private async handleScenario(id: string): Promise<void> {
    if (id === 'morning') {
      await MoveCatalog.importZone('热身')
      const moves = PracticeHubStore.listMoves()
      FollowAlongService.clearQueue()
      let added = 0
      for (const m of moves) {
        if (m.category === '热身' && added < 3) {
          await FollowAlongService.addToQueue(m.id)
          added += 1
        }
      }
      DataRefresh.bump()
      PracticeNav.openFollowAlong()
      return
    }
    if (id === 'desk') {
      await MoveCatalog.importZone('拉伸')
      const moves = PracticeHubStore.listMoves()
      FollowAlongService.clearQueue()
      let added = 0
      for (const m of moves) {
        if (m.category === '拉伸' && added < 4) {
          await FollowAlongService.addToQueue(m.id)
          added += 1
        }
      }
      DataRefresh.bump()
      PracticeNav.openFollowAlong()
      return
    }
    if (id === 'evening') {
      PracticeNav.openBreath()
      return
    }
    if (id === 'weekend') {
      await MoveCatalog.importZone('力量')
      await VitalityService.award(4)
      DataRefresh.bump()
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = 2
      AppStorage.setOrCreate('mainTabIndex', 2)
      return
    }
    if (id === 'habit') {
      await FunQuestStore.saveItem(FunQuestService.fromHall('d7'))
      await VitalityService.award(5)
      DataRefresh.bump()
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = 2
      AppStorage.setOrCreate('mainTabIndex', 2)
      return
    }
    if (id === 'journal') {
      PracticeNav.openHub('card')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.dataRefresh,
            onStartTraining: (): void => { this.openForm() },
            onOpenRecords: (): void => { PracticeNav.openHub('record') },
            onOpenPlan: (): void => {
              this.current = 1
              AppStorage.setOrCreate('mainTabIndex', 1)
            },
            onOpenFollowAlong: (): void => { PracticeNav.openFollowAlong() },
            onOpenRoulette: (): void => { PracticeNav.openRoulette() },
            onOpenBreath: (): void => { PracticeNav.openBreath() },
            onOpenWeekPlaybook: (): void => { PracticeNav.openWeekPlaybook() },
            onOpenPlayTab: (): void => {
              this.current = 1
              AppStorage.setOrCreate('mainTabIndex', 1)
            },
            onOpenDiscover: (): void => {
              this.current = 2
              AppStorage.setOrCreate('mainTabIndex', 2)
            },
            onOpenGrowth: (): void => {
              this.current = 3
              AppStorage.setOrCreate('mainTabIndex', 3)
            },
            onOpenHub: (kind: string): void => { PracticeNav.openHub(kind) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          PlayTabPage({
            onOpenRoulette: (): void => { PracticeNav.openRoulette() },
            onOpenBreath: (): void => { PracticeNav.openBreath() },
            onOpenFollowAlong: (): void => { PracticeNav.openFollowAlong() },
            onOpenWeekPlaybook: (): void => { PracticeNav.openWeekPlaybook() },
            onSwitchDiscover: (): void => {
              this.current = 2
              AppStorage.setOrCreate('mainTabIndex', 2)
            },
            onOpenGrowth: (): void => {
              this.current = 3
              AppStorage.setOrCreate('mainTabIndex', 3)
            },
            onOpenHub: (kind: string): void => { PracticeNav.openHub(kind) },
            onScenario: (id: string): void => { void this.handleScenario(id) }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          DiscoverPage({
            refreshToken: this.dataRefresh,
            onCreateQuest: (): void => { this.openQuestForm() },
            onOpenRecap: (): void => { TrainingDetailNav.openRecap() }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          GrowthPage({ refreshToken: this.dataRefresh }).layoutWeight(1)
        } else {
          MinePage({
            refreshToken: this.dataRefresh,
            onDataChanged: (): void => { this.bumpRefresh() }
          }).layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.pageBg(this.themeEpoch))

      if (!this.tabBarHidden) {
        Row() {
          ForEach(this.tabs, (t: TabItem) => {
            this.FloatingTabItem(t)
          }, (t: TabItem) => `${t.index}`)
        }
        .width('100%')
        .margin({ left: 16, right: 16, bottom: 16 })
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceGlass : Theme.colors().surfaceGlass)
        .borderRadius(Theme.radius.pill)
        .border({ width: 1, color: this.themeEpoch >= 0 ? Theme.colors().strokeHairline : Theme.colors().strokeHairline })
        .shadow({ radius: 16, color: 'rgba(15,23,42,0.08)', offsetY: 4 })
      }

      if (this.showTrainingForm) {
        TrainingFormOverlay({
          draft: this.draft,
          formError: this.formError,
          onClose: (): void => { this.closeForm() },
          onSubmit: (): void => { void this.submitForm() },
          onDraftChange: (d: TrainingDraft): void => { this.draft = d }
        })
      }

      if (this.showQuestForm) {
        FunQuestFormOverlay({
          draft: this.questDraft,
          formError: this.questFormError,
          onClose: (): void => { this.closeQuestForm() },
          onSubmit: (): void => { void this.submitQuest() },
          onDraftChange: (d: FunQuestDraft): void => { this.questDraft = d }
        })
      }

      if (this.trainingDetailId.length > 0) {
        TrainingDetailPane({
          recordId: this.trainingDetailId,
          onChanged: (): void => { this.bumpRefresh() }
        })
      }

      if (this.questDetailId.length > 0) {
        FunQuestDetailPane({
          questId: this.questDetailId,
          onChanged: (): void => { this.bumpRefresh() }
        })
      }

      if (this.showRecap) {
        RecapQuizPage({
          onGoAction: (): void => { this.handleRecapAction() }
        })
      }

      if (this.practiceHubKind === 'plan') {
        PlanHubPage({ onClose: (): void => { PracticeNav.closeHub() } })
      } else if (this.practiceHubKind === 'record') {
        RecordPage({
          refreshToken: this.dataRefresh,
          asOverlay: true,
          onClose: (): void => { PracticeNav.closeHub() }
        })
      } else if (this.practiceHubKind === 'move') {
        MoveHubPage({ onClose: (): void => { PracticeNav.closeHub() } })
      } else if (this.practiceHubKind === 'goal') {
        GoalHubPage({ onClose: (): void => { PracticeNav.closeHub() } })
      } else if (this.practiceHubKind === 'check') {
        CheckHubPage({ onClose: (): void => { PracticeNav.closeHub() } })
      } else if (this.practiceHubKind === 'card') {
        CardHubPage({ onClose: (): void => { PracticeNav.closeHub() } })
      }

      if (this.feedbackVisible) {
        this.FeedbackOverlay()
      }

      if (this.showFollowAlong) {
        FollowAlongPage({
          onClose: (): void => { PracticeNav.closeFollowAlong() },
          onSaveRecord: (d: TrainingDraft): void => { this.openFormWithDraft(d) }
        })
      }

      if (this.showSportRoulette) {
        SportRoulettePage({
          onClose: (): void => { PracticeNav.closeRoulette() },
          onAction: (action: string): void => { void this.handlePlayAction(action) }
        })
      }

      if (this.showBreathGuide) {
        BreathGuidePage({
          onClose: (): void => { PracticeNav.closeBreath() }
        })
      }

      if (this.showWeekPlaybook) {
        WeekPlaybookPage({
          onClose: (): void => { PracticeNav.closeWeekPlaybook() },
          onAction: (action: string): void => { void this.handlePlayAction(action) }
        })
      }

      if (this.showFeatureTour && !this.tabBarHidden) {
        FeatureTourOverlay({
          onDismiss: (): void => {
            AppStorage.setOrCreate('showFeatureTour', false)
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FloatingTabItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.themeEpoch >= 0 && this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.themeEpoch >= 0 && this.current === t.index ?
        Theme.colors().brandPrimaryContainer : Color.Transparent)
      .borderRadius(Theme.radius.pill)

      Text(t.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 && this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 6, bottom: 6 })
    .onClick((): void => {
      this.current = t.index
      AppStorage.setOrCreate('mainTabIndex', t.index)
    })
  }

  @Builder
  FeedbackOverlay() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
      Column({ space: Theme.space.s4 }) {
        Text('训练完成')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        Text(this.feedbackQuote)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(22)
          .textAlign(TextAlign.Center)
        if (this.feedbackHasBadge) {
          Column({ space: 8 }) {
            Text(this.feedbackBadge.emoji)
              .fontSize(40)
            Text(`解锁成就：${this.feedbackBadge.title}`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.accentOnSurface())
            Text(this.feedbackBadge.description)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor('rgba(255,107,53,0.08)')
          .borderRadius(Theme.radius.lg)
        }
        Button('太棒了')
          .width('100%')
          .height(48)
          .fontSize(Theme.type.body)
          .fontColor('#FFFFFF')
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { this.closeFeedback() })
      }
      .width('84%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(50)
  }
}
