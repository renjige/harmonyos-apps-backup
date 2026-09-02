import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { GrowthPage } from './GrowthPage'
import { ExplorePage } from './ExplorePage'
import { MinePage } from './MinePage'
import { ComposePage } from './ComposePage'
import { WeeklyPage } from './WeeklyPage'
import { FocusListPage } from './FocusListPage'
import { LibraryPage } from './LibraryPage'
import { DailyKnowPage } from './DailyKnowPage'
import { AllCapturesPage } from './AllCapturesPage'
import { TimelinePage } from './TimelinePage'
import { ReviewPage } from './ReviewPage'
import { AchievementPage } from './AchievementPage'
import { PlanEditorPage } from './PlanEditorPage'
import { KnowledgeCatalogPage } from './KnowledgeCatalogPage'
import { ReviewDeckPage } from './ReviewDeckPage'
import { InboxPage } from './InboxPage'
import { LearningPathPage } from './LearningPathPage'
import { CaptureDetailPane } from '../components/detail/CaptureDetailPane'
import { QuoteDetailPane } from '../components/detail/QuoteDetailPane'
import { AuthService } from '../services/AuthService'
import { FeatureTourOverlay } from '../components/workbench/FeatureTourOverlay'
import { ZhiweiStore } from '../services/ZhiweiStore'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '工作台'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'chart'
    t1.label = '成长'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'book'
    t2.label = '探索'
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
  @State composeToken: number = 0
  @State captureToken: number = 0
  @State quoteToken: number = 0
  @State focusToken: number = 0
  @State showTour: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('zwShowCompose') @Watch('onComposeFlag') showCompose: boolean = false
  @StorageLink('zwShowCapture') @Watch('onCaptureFlag') showCapture: boolean = false
  @StorageLink('zwShowQuote') @Watch('onQuoteFlag') showQuote: boolean = false
  @StorageLink('zwShowWeekly') showWeekly: boolean = false
  @StorageLink('zwComposeId') composeId: string = ''
  @StorageLink('zwComposeVoice') composeVoice: boolean = false
  @StorageLink('zwCaptureId') captureId: string = ''
  @StorageLink('zwQuoteId') quoteId: string = ''
  @StorageLink('zwShowFocus') @Watch('onFocusFlag') showFocus: boolean = false
  @StorageLink('zwShowLibrary') showLibrary: boolean = false
  @StorageLink('zwShowDaily') showDaily: boolean = false
  @StorageLink('zwShowAllCaptures') showAllCaptures: boolean = false
  @StorageLink('zwShowTimeline') showTimeline: boolean = false
  @StorageLink('zwShowReview') showReview: boolean = false
  @StorageLink('zwShowAchievement') showAchievement: boolean = false
  @StorageLink('zwShowPlan') showPlan: boolean = false
  @StorageLink('zwShowKnowledgeCatalog') showKnowledgeCatalog: boolean = false
  @StorageLink('zwShowReviewDeck') showReviewDeck: boolean = false
  @StorageLink('zwShowInbox') showInbox: boolean = false
  @StorageLink('zwShowLearningPath') showLearningPath: boolean = false
  @StorageLink('zwDailyId') dailyId: string = ''
  @StorageLink('zwRev') storeRev: number = 0
  @StorageLink('zwOpenMineSettings') @Watch('onMineJump') mineJump: boolean = false
  @StorageLink('zwTabJump') @Watch('onTabJump') tabJump: number = -1
  @Prop company: string = '魏文波'
  @Prop appName: string = '知微集'
  @Prop tagline: string = '把微知识收进来，分类整理、每日一知、建成个人知识库'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.showTour = ZhiweiStore.needsTour()
  }

  onComposeFlag(): void {
    if (this.showCompose) {
      this.composeToken += 1
    }
  }

  onCaptureFlag(): void {
    if (this.showCapture) {
      this.captureToken += 1
    }
  }

  onQuoteFlag(): void {
    if (this.showQuote) {
      this.quoteToken += 1
    }
  }

  onFocusFlag(): void {
    if (this.showFocus) {
      this.focusToken += 1
    }
  }

  onMineJump(): void {
    if (this.mineJump) {
      this.current = 3
    }
  }

  onTabJump(): void {
    if (this.tabJump >= 0 && this.tabJump <= 3) {
      this.current = this.tabJump
      AppStorage.setOrCreate('zwTabJump', -1)
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            tagline: this.tagline,
            refreshToken: this.storeRev
          }).layoutWeight(1)
        } else if (this.current === 1) {
          GrowthPage({ refreshToken: this.storeRev }).layoutWeight(1)
        } else if (this.current === 2) {
          ExplorePage({ refreshToken: this.storeRev }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
            }
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
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colorOf(this.themeEpoch).strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showCompose) {
        ComposePage({
          editId: this.composeId,
          voiceMode: this.composeVoice,
          refreshToken: this.composeToken
        })
          .width('100%')
          .height('100%')
          .zIndex(21)
      }

      if (this.showCapture) {
        CaptureDetailPane({
          itemId: this.captureId,
          refreshToken: this.captureToken
        })
          .width('100%')
          .height('100%')
          .zIndex(22)
      }

      if (this.showQuote) {
        QuoteDetailPane({
          itemId: this.quoteId,
          refreshToken: this.quoteToken
        })
          .width('100%')
          .height('100%')
          .zIndex(22)
      }

      if (this.showWeekly) {
        WeeklyPage()
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showFocus) {
        FocusListPage()
          .width('100%')
          .height('100%')
          .zIndex(20)
      }

      if (this.showLibrary) {
        LibraryPage()
          .width('100%')
          .height('100%')
          .zIndex(19)
      }

      if (this.showDaily) {
        DailyKnowPage()
          .width('100%')
          .height('100%')
          .zIndex(19)
      }

      if (this.showAllCaptures) {
        AllCapturesPage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showTimeline) {
        TimelinePage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showReview) {
        ReviewPage()
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showAchievement) {
        AchievementPage()
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showPlan) {
        PlanEditorPage()
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showKnowledgeCatalog) {
        KnowledgeCatalogPage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showReviewDeck) {
        ReviewDeckPage()
          .width('100%')
          .height('100%')
          .zIndex(20)
      }

      if (this.showInbox) {
        InboxPage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showLearningPath) {
        LearningPathPage()
          .width('100%')
          .height('100%')
          .zIndex(19)
      }

      if (this.showTour) {
        FeatureTourOverlay({
          onDone: (): void => { this.showTour = false }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .id(`main_${this.themeEpoch}`)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colorOf(this.themeEpoch).brandPrimary : Theme.colorOf(this.themeEpoch).textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colorOf(this.themeEpoch).brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colorOf(this.themeEpoch).brandPrimary : Theme.colorOf(this.themeEpoch).textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
