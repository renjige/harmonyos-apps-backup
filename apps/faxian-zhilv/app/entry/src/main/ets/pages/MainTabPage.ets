import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { RoutesPage } from './RoutesPage'
import { JournalListPage } from './JournalListPage'
import { MinePage } from './MinePage'
import { ChecklistPage } from './ChecklistPage'
import { FavoritesPage } from './FavoritesPage'
import { AboutPage } from './AboutPage'
import { FeedbackPage } from './FeedbackPage'
import { SearchPage } from './SearchPage'
import { MessagesPage } from './MessagesPage'
import { AIAssistantPage } from './AIAssistantPage'
import { RouteDetailPane } from '../components/detail/RouteDetailPane'
import { InspirationDetailPane } from '../components/detail/InspirationDetailPane'
import { JournalDetailPane } from '../components/detail/JournalDetailPane'
import { JournalFormPane } from '../components/journal/JournalFormPane'
import { AuthService } from '../services/AuthService'
import { WanderDetailNav } from '../services/WanderDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '发现'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '探索目录'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'book'
    t2.label = '旅记'
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
  @State contentRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') @Watch('onDetailRouteChange') detailRoute: string = ''
  @StorageLink('detailToken') detailToken: number = 0
  @Prop company: string = '发现科技'
  @Prop appName: string = '发现之旅'
  @Prop tagline: string = '让每一次出行，都成为发现之旅'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private kind(): string {
    const route = this.detailRoute
    const idx = route.indexOf(':')
    if (idx < 0) {
      return route
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

  private bump(): void {
    this.contentRefresh += 1
  }

  onDetailRouteChange(): void {
    if (this.detailRoute.length === 0) {
      this.bump()
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onOpenRoutes: (): void => { this.current = 1 }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          RoutesPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          JournalListPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onOpenLogin: (): void => this.onOpenLogin(),
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
            },
            onSwitchTab: (index: number): void => { this.current = index }
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

      if (this.detailRoute.length > 0 && this.kind() === 'route') {
        RouteDetailPane({ routeId: this.detailId(), refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'insp') {
        InspirationDetailPane({ itemId: this.detailId(), refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'journal') {
        JournalDetailPane({ journalId: this.detailId(), refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'jedit') {
        JournalFormPane({ editId: this.detailId(), refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'jnew') {
        JournalFormPane({ editId: '', refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'checklist') {
        ChecklistPage({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'favorites') {
        FavoritesPage({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'about') {
        AboutPage()
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'feedback') {
        FeedbackPage()
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'messages') {
        MessagesPage({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'search') {
        SearchPage({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'diagnose') {
        Column() {
          Row() {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick(() => WanderDetailNav.close())
            Text('适合今天')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
          }
          .width('100%')
          .padding({ left: 12, right: Theme.space.pageX, top: 8 })
          AIAssistantPage({
            onBookFromAi: (routeId: string): void => {
              WanderDetailNav.openRoute(routeId)
            }
          }).layoutWeight(1)
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
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      this.bump()
    })
  }
}
