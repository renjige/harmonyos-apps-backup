import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ActionPage } from './ActionPage'
import { WisdomPage } from './WisdomPage'
import { MinePage } from './MinePage'
import { AIAssistantPage } from './AIAssistantPage'
import { KnowledgeEditor } from '../components/zhixing/KnowledgeEditor'
import { ActionEditor } from '../components/zhixing/ActionEditor'
import { KnowledgeGraphPane } from '../components/zhixing/KnowledgeGraphPane'
import { KindListPane } from '../components/zhixing/KindListPane'
import { FavoritesPane } from '../components/zhixing/FavoritesPane'
import { SearchHubPane } from '../components/zhixing/SearchHubPane'
import { TimelinePane } from '../components/zhixing/TimelinePane'
import { AchievementWallPane } from '../components/zhixing/AchievementWallPane'
import { GrowthDashboardPane } from '../components/zhixing/GrowthDashboardPane'
import { ReviewPane } from '../components/zhixing/ReviewPane'
import { ReviewQueuePane } from '../components/zhixing/ReviewQueuePane'
import { FocusSessionPane } from '../components/zhixing/FocusSessionPane'
import { WeeklyGoalPane } from '../components/zhixing/WeeklyGoalPane'
import { KnowledgeDetailPane } from '../components/detail/KnowledgeDetailPane'
import { ActionDetailPane } from '../components/detail/ActionDetailPane'
import { ZhixingStore } from '../services/ZhixingStore'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'book'
    t0.label = '知库'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'clock'
    t1.label = '行录'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'sparkle'
    t2.label = '智慧'
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
  @State current: number = 0
  @State reloadToken: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State knowId: string = ''
  @State editKind: string = ''
  @State editId: string = ''
  @State actionKind: string = ''
  @State actionId: string = ''
  @State showGraph: boolean = false
  @State showDiagnose: boolean = false
  @State listKind: string = ''
  @State showFavorites: boolean = false
  @State showSearch: boolean = false
  @State searchTag: string = ''
  @State showTimeline: boolean = false
  @State showAchievements: boolean = false
  @State showGrowth: boolean = false
  @State showReview: boolean = false
  @State showReviewQueue: boolean = false
  @State showFocus: boolean = false
  @State focusKnowId: string = ''
  @State focusKnowTitle: string = ''
  @State showWeeklyGoal: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '知行页'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bump(): void {
    this.reloadToken++
    ZhixingStore.notifyChanged()
    this.syncBar()
  }

  private switchTab(index: number): void {
    if (this.current === index) {
      void this.refreshVisibleTab()
      return
    }
    this.current = index
    void this.refreshVisibleTab()
  }

  private async refreshVisibleTab(): Promise<void> {
    this.reloadToken++
    ZhixingStore.notifyChanged()
  }

  private overlayOpen(): boolean {
    return this.knowId.length > 0 || this.editKind.length > 0 || this.actionId.length > 0 ||
      this.showGraph || this.showDiagnose || this.listKind.length > 0 ||
      this.showFavorites || this.showSearch || this.showTimeline ||
      this.showAchievements || this.showGrowth || this.showReview ||
      this.showReviewQueue || this.showFocus || this.showWeeklyGoal
  }

  private syncBar(): void {
    AppStorage.setOrCreate('tabBarHidden', this.overlayOpen())
  }

  private closeAll(): void {
    this.knowId = ''
    this.editKind = ''
    this.editId = ''
    this.actionKind = ''
    this.actionId = ''
    this.showGraph = false
    this.showDiagnose = false
    this.listKind = ''
    this.showFavorites = false
    this.showSearch = false
    this.searchTag = ''
    this.showTimeline = false
    this.showAchievements = false
    this.showGrowth = false
    this.showReview = false
    this.showReviewQueue = false
    this.showFocus = false
    this.focusKnowId = ''
    this.focusKnowTitle = ''
    this.showWeeklyGoal = false
    this.bump()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            reloadToken: this.reloadToken,
            onOpenItem: (id: string): void => { this.knowId = id; this.syncBar() },
            onCreate: (kind: string): void => { this.editKind = kind; this.editId = ''; this.syncBar() },
            onOpenGraph: (): void => { this.showGraph = true; this.syncBar() },
            onOpenKind: (kind: string): void => { this.listKind = kind; this.syncBar() },
            onOpenSearch: (): void => { this.searchTag = ''; this.showSearch = true; this.syncBar() },
            onOpenFavorites: (): void => { this.showFavorites = true; this.syncBar() },
            onOpenTimeline: (): void => { this.showTimeline = true; this.syncBar() },
            onOpenAchievements: (): void => { this.showAchievements = true; this.syncBar() },
            onOpenReviewQueue: (): void => { this.showReviewQueue = true; this.syncBar() },
            onOpenFocus: (): void => {
              this.focusKnowId = ''
              this.focusKnowTitle = ''
              this.showFocus = true
              this.syncBar()
            },
            onOpenWeeklyGoal: (): void => { this.showWeeklyGoal = true; this.syncBar() },
            onOpenActionTab: (): void => { this.switchTab(1) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          ActionPage({
            reloadToken: this.reloadToken,
            onOpenPlan: (id: string): void => { this.actionKind = 'plan'; this.actionId = id; this.syncBar() },
            onOpenHabit: (id: string): void => { this.actionKind = 'habit'; this.actionId = id; this.syncBar() },
            onOpenLog: (id: string): void => { this.actionKind = 'log'; this.actionId = id; this.syncBar() },
            onCreate: (kind: string): void => { this.editKind = kind; this.editId = ''; this.syncBar() },
            onChanged: (): void => { this.bump() }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          WisdomPage({
            reloadToken: this.reloadToken,
            onOpenItem: (id: string): void => { this.knowId = id; this.syncBar() },
            onDiagnose: (): void => { this.showDiagnose = true; this.syncBar() },
            onCreateCard: (): void => { this.editKind = 'card'; this.editId = ''; this.syncBar() },
            onOpenActionTab: (): void => { this.switchTab(1) },
            onOpenTag: (tag: string): void => {
              this.searchTag = tag
              this.showSearch = true
              this.syncBar()
            },
            onOpenGrowth: (): void => { this.showGrowth = true; this.syncBar() },
            onOpenAchievements: (): void => { this.showAchievements = true; this.syncBar() },
            onOpenReview: (): void => { this.showReview = true; this.syncBar() },
            onOpenReviewQueue: (): void => { this.showReviewQueue = true; this.syncBar() },
            onOpenFocus: (): void => {
              this.focusKnowId = ''
              this.focusKnowTitle = ''
              this.showFocus = true
              this.syncBar()
            },
            onOpenWeeklyGoal: (): void => { this.showWeeklyGoal = true; this.syncBar() },
            onOpenTimeline: (): void => { this.showTimeline = true; this.syncBar() }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            reloadToken: this.reloadToken,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => { this.onLogout() },
            onOpenFavorites: (): void => { this.showFavorites = true; this.syncBar() },
            onOpenAchievements: (): void => { this.showAchievements = true; this.syncBar() },
            onOpenGrowth: (): void => { this.showGrowth = true; this.syncBar() },
            onOpenTimeline: (): void => { this.showTimeline = true; this.syncBar() },
            onOpenReviewQueue: (): void => { this.showReviewQueue = true; this.syncBar() },
            onOpenWeeklyGoal: (): void => { this.showWeeklyGoal = true; this.syncBar() }
          }).layoutWeight(1)
        }

        if (!this.overlayOpen()) {
          this.TabBar()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.knowId.length > 0) {
        KnowledgeDetailPane({
          itemId: this.knowId,
          onClose: (): void => { this.knowId = ''; this.syncBar() },
          onEdit: (id: string, kind: string): void => {
            this.knowId = ''
            this.editKind = kind
            this.editId = id
            this.syncBar()
          },
          onOpenRelated: (id: string): void => { this.knowId = id },
          onStartFocus: (id: string, title: string): void => {
            this.focusKnowId = id
            this.focusKnowTitle = title
            this.knowId = ''
            this.showFocus = true
            this.syncBar()
          },
          onDeleted: (): void => { this.closeAll() }
        })
      }
      if (this.actionId.length > 0) {
        ActionDetailPane({
          itemId: this.actionId,
          kind: this.actionKind,
          onClose: (): void => { this.actionId = ''; this.syncBar() },
          onEdit: (): void => {
            this.editKind = this.actionKind
            this.editId = this.actionId
            this.actionId = ''
            this.syncBar()
          },
          onChanged: (): void => { this.bump() },
          onOpenKnowledge: (id: string): void => {
            this.actionId = ''
            this.knowId = id
            this.syncBar()
          }
        })
      }
      if (this.editKind === 'note' || this.editKind === 'card' || this.editKind === 'digest') {
        KnowledgeEditor({
          itemId: this.editId,
          kind: this.editKind,
          onClose: (): void => { this.editKind = ''; this.editId = ''; this.syncBar() },
          onSaved: (id: string): void => {
            this.editKind = ''
            this.editId = ''
            this.knowId = id
            this.bump()
          }
        })
      }
      if (this.editKind === 'plan' || this.editKind === 'habit' || this.editKind === 'log') {
        ActionEditor({
          itemId: this.editId,
          kind: this.editKind,
          onClose: (): void => { this.editKind = ''; this.editId = ''; this.syncBar() },
          onSaved: (): void => {
            this.editKind = ''
            this.editId = ''
            this.bump()
          }
        })
      }
      if (this.showGraph) {
        KnowledgeGraphPane({
          reloadToken: this.reloadToken,
          onClose: (): void => { this.showGraph = false; this.syncBar() },
          onOpenItem: (id: string): void => { this.showGraph = false; this.knowId = id; this.syncBar() }
        })
      }
      if (this.listKind.length > 0) {
        KindListPane({
          kind: this.listKind,
          reloadToken: this.reloadToken,
          onClose: (): void => { this.listKind = ''; this.syncBar() },
          onOpen: (id: string): void => { this.listKind = ''; this.knowId = id; this.syncBar() },
          onCreate: (): void => {
            const k = this.listKind
            this.listKind = ''
            this.editKind = k
            this.editId = ''
            this.syncBar()
          }
        })
      }
      if (this.showFavorites) {
        FavoritesPane({
          reloadToken: this.reloadToken,
          onClose: (): void => { this.showFavorites = false; this.syncBar() },
          onOpen: (id: string): void => {
            this.showFavorites = false
            this.knowId = id
            this.syncBar()
          }
        })
      }
      if (this.showSearch) {
        SearchHubPane({
          initialQuery: '',
          initialTag: this.searchTag,
          onClose: (): void => { this.showSearch = false; this.searchTag = ''; this.syncBar() },
          onOpen: (id: string): void => {
            this.showSearch = false
            this.searchTag = ''
            this.knowId = id
            this.syncBar()
          }
        })
      }
      if (this.showTimeline) {
        TimelinePane({
          reloadToken: this.reloadToken,
          onClose: (): void => { this.showTimeline = false; this.syncBar() },
          onOpenKnowledge: (id: string): void => {
            this.showTimeline = false
            this.knowId = id
            this.syncBar()
          },
          onOpenAction: (kind: string, id: string): void => {
            this.showTimeline = false
            this.actionKind = kind
            this.actionId = id
            this.syncBar()
          }
        })
      }
      if (this.showAchievements) {
        AchievementWallPane({
          reloadToken: this.reloadToken,
          onClose: (): void => { this.showAchievements = false; this.syncBar() }
        })
      }
      if (this.showGrowth) {
        GrowthDashboardPane({
          reloadToken: this.reloadToken,
          onClose: (): void => { this.showGrowth = false; this.syncBar() },
          onOpenReview: (): void => {
            this.showGrowth = false
            this.showReview = true
            this.syncBar()
          }
        })
      }
      if (this.showReview) {
        ReviewPane({
          onClose: (): void => { this.showReview = false; this.syncBar() }
        })
      }
      if (this.showReviewQueue) {
        ReviewQueuePane({
          reloadToken: this.reloadToken,
          onClose: (): void => { this.showReviewQueue = false; this.syncBar() },
          onOpen: (id: string): void => {
            this.showReviewQueue = false
            this.knowId = id
            this.syncBar()
          },
          onChanged: (): void => { this.bump() }
        })
      }
      if (this.showFocus) {
        FocusSessionPane({
          knowTitle: this.focusKnowTitle,
          knowId: this.focusKnowId,
          onClose: (): void => {
            this.showFocus = false
            this.focusKnowId = ''
            this.focusKnowTitle = ''
            this.syncBar()
          },
          onChanged: (): void => { this.bump() }
        })
      }
      if (this.showWeeklyGoal) {
        WeeklyGoalPane({
          reloadToken: this.reloadToken,
          onClose: (): void => { this.showWeeklyGoal = false; this.syncBar() }
        })
      }
      if (this.showDiagnose) {
        Column() {
          AIAssistantPage({
            onRequireAuth: (): void => { this.onRequireAuth() },
            onClose: (): void => { this.showDiagnose = false; this.syncBar() },
            onBookFromAi: (_c: string): void => {
              this.showDiagnose = false
              this.current = 0
              this.editKind = 'card'
              this.syncBar()
            }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBar() {
    Row() {
      ForEach(this.tabs, (t: TabItem) => {
        Column({ space: 4 }) {
          Column() {
            AppIcon({
              name: t.name,
              iconSize: 22,
              color: this.current === t.index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary,
              active: this.current === t.index
            })
          }
          .width(44)
          .height(28)
          .justifyContent(FlexAlign.Center)
          .borderRadius(14)
          .backgroundColor(this.current === t.index ? Theme.colors().brandPrimary : 'transparent')
          Text(t.label)
            .fontSize(10)
            .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Regular)
            .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
            .opacity(this.themeEpoch >= 0 ? 1 : 1)
        }
        .layoutWeight(1)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.switchTab(t.index) })
      }, (t: TabItem) => `${t.index}`)
    }
    .width('100%')
    .padding({ left: 8, right: 8, bottom: 12, top: 6 })
    .margin({ left: 12, right: 12, bottom: 8 })
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .shadow({ radius: 16, color: 'rgba(26,42,108,0.12)', offsetX: 0, offsetY: 4 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
