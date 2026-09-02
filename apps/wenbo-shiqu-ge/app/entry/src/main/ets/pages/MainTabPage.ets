import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { DailyPage } from './DailyPage'
import { FavoritesPage } from './FavoritesPage'
import { MinePage } from './MinePage'
import { ArticleDetailPane } from '../components/detail/ArticleDetailPane'
import { DailyDetailPane } from '../components/detail/DailyDetailPane'
import { SearchPane } from '../components/detail/SearchPane'
import { HistoryPane } from '../components/detail/HistoryPane'
import { MessagesPane } from '../components/detail/MessagesPane'
import { QuizPane } from '../components/detail/QuizPane'
import { NotesPane } from '../components/detail/NotesPane'
import { CollectionsPane } from '../components/detail/CollectionsPane'
import { TasksPane } from '../components/detail/TasksPane'
import { ProfilePane } from '../components/detail/ProfilePane'
import { CardsPane } from '../components/detail/CardsPane'
import { AlbumsPane } from '../components/detail/AlbumsPane'
import { ExploreLogPane } from '../components/detail/ExploreLogPane'
import { DailyFindPane } from '../components/detail/DailyFindPane'
import { WishlistPane } from '../components/detail/WishlistPane'
import { AuthService } from '../services/AuthService'
import { PavilionDetailNav } from '../services/PavilionDetailNav'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AIAssistantPage } from './AIAssistantPage'

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
    t1.name = 'sparkle'
    t1.label = '每日'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'heart'
    t2.label = '收藏'
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
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @StorageLink('detailToken') detailToken: number = 0
  @StorageLink('showMineSettings') showMineSettings: boolean = false
  @StorageLink('pavilionRefresh') pavilionRefresh: number = 0
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '魏文波'
  @Prop appName: string = '识趣阁'
  @Prop tagline: string = '发现生活中有趣的知识与智慧'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  onDarkChange(): void {
    ThemeAppearance.bumpEpoch()
  }

  onTabLink(): void {
    this.current = this.mainTabIndex
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            tagline: this.tagline,
            refreshToken: this.pavilionRefresh
          }).layoutWeight(1)
        } else if (this.current === 1) {
          DailyPage({ refreshToken: this.pavilionRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          FavoritesPage({ refreshToken: this.pavilionRefresh }).layoutWeight(1)
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
          .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.hairline(this.themeEpoch, this.darkModeOn) })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.pageBg(this.themeEpoch, this.darkModeOn))

      if (this.detailRoute.length > 0) {
        if (PavilionDetailNav.routeKind(this.detailRoute) === 'article') {
          ArticleDetailPane({
            itemId: PavilionDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'daily') {
          DailyDetailPane({
            itemId: PavilionDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'search') {
          SearchPane({ refreshToken: this.detailToken })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'history') {
          HistoryPane({ refreshToken: this.detailToken })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'messages') {
          MessagesPane({ refreshToken: this.detailToken })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'diagnose') {
          AIAssistantPage({
            overlayMode: true,
            onClose: (): void => { PavilionDetailNav.close() },
            onBookFromAi: (_c: string): void => {
              PavilionDetailNav.close()
              PavilionDetailNav.switchTab(0)
            }
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'quiz') {
          QuizPane({
            articleId: PavilionDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'notes' ||
          PavilionDetailNav.routeKind(this.detailRoute) === 'notewrite') {
          NotesPane({
            articleId: PavilionDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'collections' ||
          PavilionDetailNav.routeKind(this.detailRoute) === 'collection') {
          CollectionsPane({
            collectionId: PavilionDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'tasks') {
          TasksPane({ refreshToken: this.detailToken })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'profile') {
          ProfilePane({ refreshToken: this.detailToken })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'cards') {
          CardsPane({ refreshToken: this.detailToken })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'albums') {
          AlbumsPane({
            articleId: PavilionDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'logs') {
          ExploreLogPane({ refreshToken: this.detailToken })
            .width('100%').height('100%').zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'finds') {
          DailyFindPane({ refreshToken: this.detailToken })
            .width('100%').height('100%').zIndex(18)
        } else if (PavilionDetailNav.routeKind(this.detailRoute) === 'wish') {
          WishlistPane({ refreshToken: this.detailToken })
            .width('100%').height('100%').zIndex(18)
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
          onCloseOverlay: (): void => { PavilionDetailNav.closeSettings() }
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
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ? Theme.brandInk(this.themeEpoch, this.darkModeOn) : Theme.textSub(this.themeEpoch, this.darkModeOn),
          active: this.current === t.index
        })
      }
      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
      .backgroundColor(this.current === t.index ? Theme.brandBox(this.themeEpoch, this.darkModeOn) : Color.Transparent)
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(10)
        .fontColor(this.current === t.index ? Theme.brandInk(this.themeEpoch, this.darkModeOn) : Theme.textSub(this.themeEpoch, this.darkModeOn))
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
