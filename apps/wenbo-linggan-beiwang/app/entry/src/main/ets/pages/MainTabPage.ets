import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { RecordPage } from './RecordPage'
import { BoardPage } from './BoardPage'
import { OrganizePage } from './OrganizePage'
import { MinePage } from './MinePage'
import { FavoritesPage } from './FavoritesPage'
import { TimelinePage } from './TimelinePage'
import { WeeklyReviewPage } from './WeeklyReviewPage'
import { PlanPage } from './PlanPage'
import { MessagesPage } from './MessagesPage'
import { GrowthStatsPage } from './GrowthStatsPage'
import { AchievementPage } from './AchievementPage'
import { TopicListPage } from './TopicListPage'
import { TopicDetailPage } from './TopicDetailPage'
import { CheckInSheet } from '../components/inspiration/CheckInSheet'
import { ProductGuideSheet } from '../components/inspiration/ProductGuideSheet'
import { ConvertReadinessSheet } from '../components/inspiration/ConvertReadinessSheet'
import { FeaturedDetailPane } from '../components/detail/FeaturedDetailPane'
import { InspirationDetailPane } from '../components/detail/InspirationDetailPane'
import { BoardDetailPane } from '../components/detail/BoardDetailPane'
import { PlanDetailPane } from '../components/detail/PlanDetailPane'
import { AuthService } from '../services/AuthService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { DailyPromptService } from '../services/DailyPromptService'
import { FavoriteSync } from '../services/FavoriteSync'
import { GuideStore } from '../services/GuideStore'
import { ConversionPipelineService, PipelineSnapshot } from '../services/ConversionPipelineService'
import { ContentSync } from '../services/ContentSync'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '转化台'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'book'
    t1.label = '捕捉'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'photo'
    t2.label = '画板'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'search'
    t3.label = '归档'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

/** 5 Tab：转化台 | 捕捉 | 画板 | 归档 | 我的（与灵感手册 Tab 结构不同） */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @State current: number = 0
  @State detailRefresh: number = 0
  @State contentRefresh: number = 0
  @State recordCreateTrigger: number = 0
  @State boardCreateTrigger: number = 0
  @State favoritesRefresh: number = 0
  @State timelineRefresh: number = 0
  @State showFavorites: boolean = false
  @State showTimeline: boolean = false
  @State showWeeklyReview: boolean = false
  @State showPlans: boolean = false
  @State showMessages: boolean = false
  @State showCheckIn: boolean = false
  @State showStats: boolean = false
  @State showAchievements: boolean = false
  @State showTopics: boolean = false
  @State showTopicDetail: boolean = false
  @State topicId: string = ''
  @State topicListRefresh: number = 0
  @State planRefresh: number = 0
  @State planCreateTrigger: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') @Watch('onDetailRouteChange') detailRoute: string = ''
  @StorageLink('detailToken') @Watch('onDetailTokenChange') navDetailToken: number = 0
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '转化工作台'
  @Prop tagline: string = '创意转化工作台：捕捉后钉板对照，再拆成计划与专题回顾'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State showProductGuide: boolean = false
  @State showReadiness: boolean = false
  @State readinessPipeline: PipelineSnapshot = PipelineSnapshot.empty()
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    void this.tryShowProductGuide()
  }

  private async tryShowProductGuide(): Promise<void> {
    const show = await GuideStore.shouldShow()
    if (show) {
      this.showProductGuide = true
      AppStorage.setOrCreate('tabBarHidden', true)
    }
  }

  private closeProductGuide(): void {
    this.showProductGuide = false
    void GuideStore.markSeen()
    this.restoreTabBarIfNeeded()
  }

  private openProductGuide(): void {
    this.showProductGuide = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
    this.timelineRefresh += 1
    ContentSync.bump()
  }

  private selectTab(index: number): void {
    if (InspirationDetailNav.isOpen()) {
      InspirationDetailNav.close()
    }
    this.showFavorites = false
    this.showTimeline = false
    this.showWeeklyReview = false
    this.showPlans = false
    this.showMessages = false
    this.closeGrowthOverlays()
    AppStorage.setOrCreate('tabBarHidden', false)
    this.current = index
    if (index === 0) {
      this.bumpContentRefresh()
    }
  }

  private closeGrowthOverlays(): void {
    this.showCheckIn = false
    this.showStats = false
    this.showAchievements = false
    this.showTopics = false
    this.showTopicDetail = false
  }

  private openOverlay(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeOverlay(): void {
    this.closeGrowthOverlays()
    this.showProductGuide = false
    this.showReadiness = false
    this.showFavorites = false
    this.showTimeline = false
    this.showWeeklyReview = false
    this.showPlans = false
    this.showMessages = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  onDetailTokenChange(): void {
    this.detailRefresh = this.navDetailToken
  }

  onDetailRouteChange(): void {
    if (this.detailRoute.length === 0) {
      this.restoreTabBarIfNeeded()
      if (this.current === 0) {
        this.bumpContentRefresh()
      } else {
        ContentSync.bump()
      }
    }
  }

  private hasBlockingOverlay(): boolean {
    return this.showProductGuide || this.showReadiness || this.showFavorites || this.showTimeline || this.showWeeklyReview || this.showPlans ||
      this.showMessages || this.showCheckIn || this.showStats || this.showAchievements ||
      this.showTopics || this.showTopicDetail
  }

  private restoreTabBarIfNeeded(): void {
    if (this.hasBlockingOverlay()) {
      AppStorage.setOrCreate('tabBarHidden', true)
      return
    }
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async openReadiness(): Promise<void> {
    if (AuthService.isLoggedIn()) {
      this.readinessPipeline = await ConversionPipelineService.load(this.currentUsername)
    } else {
      this.readinessPipeline = PipelineSnapshot.empty()
    }
    this.showReadiness = true
    this.openOverlay()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            refreshToken: this.contentRefresh,
            onCaptureInspiration: (): void => {
              DailyPromptService.requestOpenForm()
              this.current = 1
              this.recordCreateTrigger += 1
            },
            onOpenFavorites: (): void => {
              this.showFavorites = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.favoritesRefresh += 1
            },
            onOpenOrganize: (): void => { this.current = 3 },
            onOpenTimeline: (): void => {
              this.showTimeline = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.timelineRefresh += 1
            },
            onOpenWeeklyReview: (): void => {
              this.showWeeklyReview = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenPlans: (): void => {
              this.showPlans = true
              this.openOverlay()
              this.planRefresh += 1
            },
            onOpenCheckIn: (): void => {
              this.showCheckIn = true
              this.openOverlay()
            },
            onOpenStats: (): void => {
              this.showStats = true
              this.openOverlay()
            },
            onOpenAchievements: (): void => {
              this.showAchievements = true
              this.openOverlay()
            },
            onOpenTopics: (): void => {
              this.showTopics = true
              this.openOverlay()
            },
            onOpenReadiness: (): void => { void this.openReadiness() },
            onSwitchTab: (index: number): void => { this.selectTab(index) },
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          RecordPage({
            createTrigger: this.recordCreateTrigger,
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onInspirationCreated: (): void => { this.bumpContentRefresh() }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          BoardPage({
            createTrigger: this.boardCreateTrigger,
            onRequireAuth: (): void => this.onRequireAuth(),
            onBoardCreated: (): void => { this.bumpContentRefresh() }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          OrganizePage({
            embedded: true,
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onClose: (): void => {},
            onOpenStats: (): void => {
              this.showStats = true
              this.openOverlay()
            },
            onOpenAchievements: (): void => {
              this.showAchievements = true
              this.openOverlay()
            },
            onOpenTopics: (): void => {
              this.showTopics = true
              this.openOverlay()
            },
            onOpenReview: (): void => {
              this.showWeeklyReview = true
              this.openOverlay()
            }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onOpenLogin: (): void => this.onOpenLogin(),
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
            onRequireAuth: (): void => this.onRequireAuth(),
            onSwitchTab: (index: number): void => { this.selectTab(index) },
            onOpenFavorites: (): void => {
              this.showFavorites = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.favoritesRefresh += 1
            },
            onOpenOrganize: (): void => { this.current = 3 },
            onOpenTimeline: (): void => {
              this.showTimeline = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.timelineRefresh += 1
            },
            onOpenWeeklyReview: (): void => {
              this.showWeeklyReview = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenPlans: (): void => {
              this.showPlans = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.planRefresh += 1
            },
            onOpenMessages: (): void => {
              this.showMessages = true
              this.openOverlay()
            },
            onOpenTopics: (): void => {
              this.showTopics = true
              this.openOverlay()
            },
            onOpenAchievements: (): void => {
              this.showAchievements = true
              this.openOverlay()
            },
            onOpenStats: (): void => {
              this.showStats = true
              this.openOverlay()
            },
            onOpenProductGuide: (): void => { this.openProductGuide() }
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
          .shadow({ radius: 16, color: 'rgba(51,65,85,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showProductGuide) {
        ProductGuideSheet({
          onClose: (): void => { this.closeProductGuide() }
        })
      }

      if (this.showReadiness) {
        ConvertReadinessSheet({
          pipeline: this.readinessPipeline,
          onClose: (): void => {
            this.showReadiness = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showCheckIn) {
        Column() {
          CheckInSheet({
            onClose: (): void => {
              this.showCheckIn = false
              AppStorage.setOrCreate('tabBarHidden', false)
            },
            onSaved: (): void => { this.bumpContentRefresh() },
            onRequireAuth: (): void => this.onRequireAuth()
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(16)
      }

      if (this.showStats) {
        Column() {
          GrowthStatsPage({
            onClose: (): void => {
              this.showStats = false
              AppStorage.setOrCreate('tabBarHidden', false)
            },
            onRequireAuth: (): void => this.onRequireAuth()
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(16)
      }

      if (this.showAchievements) {
        Column() {
          AchievementPage({
            onClose: (): void => {
              this.showAchievements = false
              AppStorage.setOrCreate('tabBarHidden', false)
            },
            onRequireAuth: (): void => this.onRequireAuth()
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(16)
      }

      if (this.showTopics) {
        Column() {
          TopicListPage({
            refreshToken: this.topicListRefresh,
            onClose: (): void => {
              this.showTopics = false
              this.showTopicDetail = false
              AppStorage.setOrCreate('tabBarHidden', false)
              this.bumpContentRefresh()
            },
            onRequireAuth: (): void => this.onRequireAuth(),
            onOpenTopic: (id: string): void => {
              this.topicId = id
              this.showTopicDetail = true
            }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(16)
      }

      if (this.showTopicDetail) {
        Column() {
          TopicDetailPage({
            topicId: this.topicId,
            onClose: (): void => {
              this.showTopicDetail = false
              this.topicListRefresh += 1
              this.bumpContentRefresh()
            },
            onRequireAuth: (): void => this.onRequireAuth(),
            onTopicChanged: (): void => { this.topicListRefresh += 1 }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(17)
      }

      if (this.showFavorites) {
        FavoritesPage({
          refreshToken: this.favoritesRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => {
            this.showFavorites = false
            AppStorage.setOrCreate('tabBarHidden', false)
            FavoriteSync.bump()
            this.bumpContentRefresh()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showTimeline) {
        TimelinePage({
          refreshToken: this.timelineRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => {
            this.showTimeline = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showWeeklyReview) {
        WeeklyReviewPage({
          onClose: (): void => {
            this.showWeeklyReview = false
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onUsePrompt: (): void => {
            DailyPromptService.requestOpenForm()
            this.showWeeklyReview = false
            this.current = 1
            this.recordCreateTrigger += 1
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onOpenOrganize: (): void => {
            this.showWeeklyReview = false
            this.current = 3
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showPlans) {
        PlanPage({
          showBack: true,
          refreshToken: this.planRefresh,
          createTrigger: this.planCreateTrigger,
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => {
            this.showPlans = false
            AppStorage.setOrCreate('tabBarHidden', false)
            this.bumpContentRefresh()
          },
          onPlanCreated: (): void => { this.bumpContentRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showMessages) {
        MessagesPage({
          showBack: true,
          onClose: (): void => {
            this.showMessages = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      // 详情 Overlay 用独立 if（不用 @Builder 内 if/else），避免从灵感切到计划时复用旧组件导致「灵感不存在」卡死
      if (this.detailRoute.indexOf('featured:') === 0) {
        Column() {
          FeaturedDetailPane({
            itemId: InspirationDetailNav.parseId(),
            refreshToken: this.detailRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onContentChanged: (): void => { this.bumpContentRefresh() },
            onWriteLike: (): void => {
              DailyPromptService.requestOpenForm()
              this.current = 1
              this.recordCreateTrigger += 1
            }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(20)
      }
      if (this.detailRoute.indexOf('inspiration:') === 0) {
        Column() {
          InspirationDetailPane({
            itemId: InspirationDetailNav.parseId(),
            refreshToken: this.detailRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onContentChanged: (): void => { this.bumpContentRefresh() },
            onEditInspiration: (): void => {
              DailyPromptService.requestOpenForm()
              this.current = 1
              this.recordCreateTrigger += 1
            }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(20)
      }
      if (this.detailRoute.indexOf('board:') === 0) {
        Column() {
          BoardDetailPane({
            itemId: InspirationDetailNav.parseId(),
            refreshToken: this.detailRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onCreateBoard: (): void => {
              this.current = 2
              this.boardCreateTrigger += 1
            }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(20)
      }
      if (this.detailRoute.indexOf('plan:') === 0) {
        Column() {
          PlanDetailPane({
            itemId: InspirationDetailNav.parseId(),
            refreshToken: this.detailRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onPlanUpdated: (): void => { this.bumpContentRefresh() }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 4 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandPrimaryPressed : Theme.colors().textPrimary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.caption)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimaryPressed : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 6, bottom: 6 })
    .onClick((): void => { this.selectTab(t.index) })
  }
}
