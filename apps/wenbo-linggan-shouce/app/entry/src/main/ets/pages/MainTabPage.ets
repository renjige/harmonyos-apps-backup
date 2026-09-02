import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { RecordPage } from './RecordPage'
import { BoardPage } from './BoardPage'
import { PlanPage } from './PlanPage'
import { MinePage } from './MinePage'
import { FavoritesPage } from './FavoritesPage'
import { OrganizePage } from './OrganizePage'
import { GrowthCenterPage } from './GrowthCenterPage'
import { TimelinePage } from './TimelinePage'
import { TopicsPage } from './TopicsPage'
import { MessagesPage } from './MessagesPage'
import { WeeklyReviewPage } from './WeeklyReviewPage'
import { TopicDetailPane } from '../components/detail/TopicDetailPane'
import { FeaturedDetailPane } from '../components/detail/FeaturedDetailPane'
import { InspirationDetailPane } from '../components/detail/InspirationDetailPane'
import { BoardDetailPane } from '../components/detail/BoardDetailPane'
import { PlanDetailPane } from '../components/detail/PlanDetailPane'
import { AuthService } from '../services/AuthService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'

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
    t1.name = 'book'
    t1.label = '记录'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'photo'
    t2.label = '画板'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'calendar'
    t3.label = '计划'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

/** 5 Tab：灵感 | 记录 | 画板 | 计划 | 我的；详情 Overlay 顶层 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailRefresh: number = 0
  @StorageLink('detailToken') detailToken: number = 0
  @State contentRefresh: number = 0
  @State recordCreateTrigger: number = 0
  @State boardCreateTrigger: number = 0
  @State planRefresh: number = 0
  @State favoritesRefresh: number = 0
  @State showFavorites: boolean = false
  @State showOrganize: boolean = false
  @State showGrowth: boolean = false
  @State showTimeline: boolean = false
  @State showTopics: boolean = false
  @State showMessages: boolean = false
  @State growthRefresh: number = 0
  @State timelineRefresh: number = 0
  @State topicsRefresh: number = 0
  @State showWeeklyReview: boolean = false
  @State weeklyRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @Prop company: string = '魏文波'
  @Prop appName: string = '灵感手册'
  @Prop tagline: string = '一款用于记录、整理和管理个人创意灵感的智慧应用，数字手账与创意杂志美学并存'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
    this.planRefresh += 1
  }

  private closeAllOverlays(): void {
    this.showFavorites = false
    this.showOrganize = false
    this.showGrowth = false
    this.showTimeline = false
    this.showTopics = false
    this.showMessages = false
    this.showWeeklyReview = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private openOverlay(kind: string): void {
    this.closeAllOverlays()
    AppStorage.setOrCreate('tabBarHidden', true)
    if (kind === 'favorites') {
      this.showFavorites = true
      this.favoritesRefresh += 1
    } else if (kind === 'organize') {
      this.showOrganize = true
    } else if (kind === 'growth') {
      this.showGrowth = true
      this.growthRefresh += 1
    } else if (kind === 'timeline') {
      this.showTimeline = true
      this.timelineRefresh += 1
    } else if (kind === 'topics') {
      this.showTopics = true
      this.topicsRefresh += 1
    } else if (kind === 'messages') {
      this.showMessages = true
    } else if (kind === 'weekly') {
      this.showWeeklyReview = true
      this.weeklyRefresh += 1
    }
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
              this.current = 1
              this.recordCreateTrigger += 1
            },
            onOpenGrowth: (): void => { this.openOverlay('growth') },
            onOpenTimeline: (): void => { this.openOverlay('timeline') },
            onOpenOrganize: (): void => { this.openOverlay('organize') },
            onSwitchTab: (index: number): void => { this.current = index }
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
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onBoardCreated: (): void => { this.bumpContentRefresh() }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          PlanPage({
            refreshToken: this.planRefresh,
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => this.onOpenLogin(),
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
            onRequireAuth: (): void => this.onRequireAuth(),
            onSwitchTab: (index: number): void => {
              if (InspirationDetailNav.isOpen()) {
                InspirationDetailNav.close()
              }
              this.current = index
            },
            onOpenFavorites: (): void => { this.openOverlay('favorites') },
            onOpenOrganize: (): void => { this.openOverlay('organize') },
            onOpenGrowth: (): void => { this.openOverlay('growth') },
            onOpenTimeline: (): void => { this.openOverlay('timeline') },
            onOpenTopics: (): void => { this.openOverlay('topics') },
            onOpenMessages: (): void => { this.openOverlay('messages') },
            onOpenWeeklyReview: (): void => { this.openOverlay('weekly') }
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
          .shadow({ radius: 16, color: 'rgba(27,42,65,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showFavorites) {
        FavoritesPage({
          refreshToken: this.favoritesRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => { this.closeAllOverlays() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showOrganize) {
        OrganizePage({
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => { this.closeAllOverlays() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showGrowth) {
        GrowthCenterPage({
          refreshToken: this.growthRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onOpenWeeklyReview: (): void => { this.openOverlay('weekly') },
          onClose: (): void => { this.closeAllOverlays() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showTimeline) {
        TimelinePage({
          refreshToken: this.timelineRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => { this.closeAllOverlays() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showTopics) {
        TopicsPage({
          refreshToken: this.topicsRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => { this.closeAllOverlays() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showMessages) {
        MessagesPage({
          onClose: (): void => { this.closeAllOverlays() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showWeeklyReview) {
        WeeklyReviewPage({
          refreshToken: this.weeklyRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => { this.closeAllOverlays() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.detailRoute.length > 0) {
        Column() {
          this.DetailOverlay()
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  private detailKind(): string {
    const route = this.detailRoute
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  private detailId(): string {
    const route = this.detailRoute
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }

  @Builder
  DetailOverlay() {
    if (this.detailKind() === 'featured') {
      FeaturedDetailPane({
        itemId: this.detailId(),
        refreshToken: this.detailToken,
        onRequireAuth: (): void => this.onRequireAuth()
      })
        .key(`detail_${this.detailRoute}_${this.detailToken}`)
        .width('100%')
        .height('100%')
    } else if (this.detailKind() === 'inspiration') {
      InspirationDetailPane({
        itemId: this.detailId(),
        refreshToken: this.detailToken,
        onRequireAuth: (): void => this.onRequireAuth(),
        onInspirationChanged: (): void => { this.bumpContentRefresh() }
      })
        .key(`detail_${this.detailRoute}_${this.detailToken}`)
        .width('100%')
        .height('100%')
    } else if (this.detailKind() === 'board') {
      BoardDetailPane({
        itemId: this.detailId(),
        refreshToken: this.detailToken,
        onRequireAuth: (): void => this.onRequireAuth(),
        onCreateBoard: (): void => {
          this.current = 2
          this.boardCreateTrigger += 1
        },
        onBoardChanged: (): void => { this.bumpContentRefresh() }
      })
        .key(`detail_${this.detailRoute}_${this.detailToken}`)
        .width('100%')
        .height('100%')
    } else if (this.detailKind() === 'plan') {
      PlanDetailPane({
        itemId: this.detailId(),
        refreshToken: this.detailToken,
        onRequireAuth: (): void => this.onRequireAuth(),
        onPlanUpdated: (): void => { this.planRefresh += 1 }
      })
        .key(`detail_${this.detailRoute}_${this.detailToken}`)
        .width('100%')
        .height('100%')
    } else if (this.detailKind() === 'topic') {
      TopicDetailPane({
        itemId: this.detailId(),
        refreshToken: this.detailToken,
        onRequireAuth: (): void => this.onRequireAuth(),
        onTopicChanged: (): void => { this.bumpContentRefresh() }
      })
        .key(`detail_${this.detailRoute}_${this.detailToken}`)
        .width('100%')
        .height('100%')
    }
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
    .onClick(() => {
      if (InspirationDetailNav.isOpen()) {
        InspirationDetailNav.close()
      }
      this.closeAllOverlays()
      this.current = t.index
    })
  }
}
