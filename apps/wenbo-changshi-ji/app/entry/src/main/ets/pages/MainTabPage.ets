import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { HomePage } from './HomePage'
import { BrowsePage } from './BrowsePage'
import { FavoritesPage } from './FavoritesPage'
import { MinePage } from './MinePage'
import { FactDetailPane } from '../components/detail/FactDetailPane'
import { NoteSheet } from '../components/detail/NoteSheet'
import { AuthService } from '../services/AuthService'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CommonSenseStore } from '../services/CommonSenseStore'
import { CommonSenseStats } from '../models/CommonSenseModels'
import { AIAssistantPage } from './AIAssistantPage'
import { QuizPage } from './QuizPage'
import { ScenesPage } from './ScenesPage'
import { ChecklistPage } from './ChecklistPage'
import { ToolsPage } from './ToolsPage'
import { RemindPage } from './RemindPage'
import { HistoryPage } from './HistoryPage'
import { SearchPage } from './SearchPage'
import { ShareCardPane } from '../components/detail/ShareCardPane'
import { SceneGuideDetailPane } from '../components/detail/SceneGuideDetailPane'
import { MessagesPage } from './MessagesPage'
import { PlanPage } from './PlanPage'
import { TimelinePage } from './TimelinePage'
import { AchievementsPage } from './AchievementsPage'
import { ReviewPage } from './ReviewPage'
import { GrowthDashboardPage } from './GrowthDashboardPage'
import { TopicsPage } from './TopicsPage'
import { UserNotesPage } from './UserNotesPage'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '今日常识'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'grid'
    t1.label = '分类浏览'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'heart'
    t2.label = '我的收藏'
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
  @State stats: CommonSenseStats = new CommonSenseStats()
  @State checkInToast: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') @Watch('onRouteChange') detailRoute: string = ''
  @StorageLink('detailToken') detailToken: number = 0
  @StorageLink('showMineSettings') showMineSettings: boolean = false
  @StorageLink('csRefresh') @Watch('onCsRefresh') csRefresh: number = 0
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '魏文波'
  @Prop appName: string = '常识集'
  @Prop tagline: string = '每日一条精选常识，按日历积累、分类检索、收藏笔记，让生活智慧触手可及。'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.stats = CommonSenseStore.stats()
  }

  onDarkChange(): void {
    const mode = this.darkModeOn ? 'dark' : 'light'
    ThemeAppearance.apply(mode)
  }

  onTabLink(): void {
    this.current = this.mainTabIndex
  }

  onCsRefresh(): void {
    this.refreshStats()
  }

  onRouteChange(): void {
    const kind = CommonSenseDetailNav.routeKind(this.detailRoute)
    if (kind === 'stats' || kind === 'checkin') {
      this.refreshStats()
    }
  }

  private refreshStats(): void {
    this.stats = CommonSenseStore.stats()
  }

  private showCheckInToast(message: string): void {
    this.checkInToast = message
    setTimeout((): void => { this.checkInToast = '' }, 2200)
  }

  private async handleCheckIn(): Promise<void> {
    const ok = await CommonSenseStore.checkInToday()
    this.refreshStats()
    if (ok) {
      this.showCheckInToast('打卡成功，已连续积累常识')
    } else {
      this.showCheckInToast('今日已打卡')
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.csRefresh
          }).layoutWeight(1)
        } else if (this.current === 1) {
          BrowsePage({ refreshToken: this.csRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          FavoritesPage({ refreshToken: this.csRefresh }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => { this.onLogout() }
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
          .margin({ left: 12, right: 12, bottom: 8 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.detailRoute.length > 0) {
        if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'fact') {
          FactDetailPane({
            itemId: CommonSenseDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'note') {
          NoteSheet({
            factId: CommonSenseDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'stats') {
          this.StatsOverlay()
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'checkin') {
          this.CheckInOverlay()
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'diagnose') {
          AIAssistantPage({
            overlayMode: true,
            onClose: (): void => { CommonSenseDetailNav.close() },
            onBookFromAi: (_c: string): void => {
              CommonSenseDetailNav.close()
              CommonSenseDetailNav.switchTab(1)
            }
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'quiz') {
          QuizPage()
            .width('100%').height('100%').zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'scenes') {
          ScenesPage()
            .width('100%').height('100%').zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'lists') {
          ChecklistPage({ refreshToken: this.detailToken })
            .width('100%').height('100%').zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'list') {
          ChecklistPage({
            listId: CommonSenseDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%').height('100%').zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'tools') {
          ToolsPage()
            .width('100%').height('100%').zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'remind') {
          RemindPage()
            .width('100%').height('100%').zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'history') {
          HistoryPage()
            .width('100%').height('100%').zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'search') {
          SearchPage()
            .width('100%').height('100%').zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'share') {
          ShareCardPane({ itemId: CommonSenseDetailNav.parseRouteId(this.detailRoute) })
            .width('100%').height('100%').zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'sceneGuide') {
          SceneGuideDetailPane({ sceneKey: CommonSenseDetailNav.parseRouteId(this.detailRoute) })
            .width('100%').height('100%').zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'messages') {
          Column() {
            MessagesPage()
          }
          .width('100%').height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(18)
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'plan') {
          PlanPage()
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'timeline') {
          TimelinePage()
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'achievements') {
          AchievementsPage()
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'review') {
          ReviewPage()
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'growth') {
          GrowthDashboardPage()
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'topics') {
          TopicsPage()
        } else if (CommonSenseDetailNav.routeKind(this.detailRoute) === 'usernotes') {
          UserNotesPage()
        }
      }

      if (this.showMineSettings) {
        MinePage({
          appName: this.appName,
          overlayMode: true,
          settingsOnly: true,
          onOpenLogin: (): void => { this.onOpenLogin() },
          onLogout: (): void => {
            void AuthService.logout()
            this.onLogout()
          },
          onCloseOverlay: (): void => { CommonSenseDetailNav.closeSettings() }
        })
          .width('100%')
          .height('100%')
          .zIndex(19)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatsOverlay() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { CommonSenseDetailNav.close() })
        Text('学习统计')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Row({ space: Theme.space.s3 }) {
        this.StatBlock('打卡天数', `${this.stats.readDays}`)
        this.StatBlock('收藏', `${this.stats.favorites}`)
        this.StatBlock('连续打卡', `${this.stats.checkInStreak}`)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Row({ space: Theme.space.s3 }) {
        this.StatBlock('已阅读', `${this.stats.readCount}`)
        this.StatBlock('已掌握', `${this.stats.mastered}`)
        this.StatBlock('清单', `${this.stats.lists}`)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      AppButton({
        label: '刷新统计',
        variant: 'secondary',
        onTap: (): void => { this.refreshStats() }
      })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(18)
  }

  @Builder
  StatBlock(label: string, value: string) {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(12)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }

  @Builder
  CheckInOverlay() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { CommonSenseDetailNav.close() })
          Text('每日打卡')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Column({ space: Theme.space.s3 }) {
          Text(`已连续打卡 ${this.stats.checkInStreak} 天`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('读完今日常识后打卡，日历条会亮起标记。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '今日打卡',
            onTap: (): void => { void this.handleCheckIn() }
          })
        }
        .padding(Theme.space.s5)
        .width('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.checkInToast.length > 0) {
        Text(this.checkInToast)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(18)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary,
          active: this.current === t.index
        })
      }
      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : Color.Transparent)
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(10)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick((): void => {
      this.current = t.index
      AppStorage.setOrCreate('mainTabIndex', t.index)
    })
  }
}
