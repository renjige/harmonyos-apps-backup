import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { LibraryPage } from './LibraryPage'
import { AIAssistantPage } from './AIAssistantPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { DashboardPage } from './DashboardPage'
import { FavoritesPage } from './FavoritesPage'
import { HistoryPage } from './HistoryPage'
import { TriesPage } from './TriesPage'
import { AboutPage } from './AboutPage'
import { DrinkDetailPane } from '../components/detail/DrinkDetailPane'
import { TipDetailPane } from '../components/detail/TipDetailPane'
import { AuthService } from '../services/AuthService'
import { DrinkDetailNav } from '../services/DrinkDetailNav'

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
    t1.name = 'biz'
    t1.label = '饮品库'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'ai'
    t2.label = '配饮'
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
  @StorageLink('switchTabIndex') @Watch('onSwitchTab') switchTabIndex: number = -1
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '消暑饮品'
  @Prop tagline: string = '按体感温度与时段智慧推荐自制消暑饮，看配方、收藏、记下试做'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private kind(): string {
    return DrinkDetailNav.kind()
  }

  private detailId(): string {
    return DrinkDetailNav.parseId()
  }

  onDetailRouteChange(): void {
    if (this.detailRoute.length === 0) {
      this.contentRefresh += 1
    }
  }

  onSwitchTab(): void {
    if (this.switchTabIndex >= 0 && this.switchTabIndex <= 3) {
      this.current = this.switchTabIndex
      this.switchTabIndex = -1
    }
  }

  private openMatchedDrink(drinkId: string): void {
    DrinkDetailNav.openDrink(drinkId)
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.contentRefresh
          }).layoutWeight(1)
        } else if (this.current === 1) {
          LibraryPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          AIAssistantPage({
            onRequireAuth: (): void => this.onRequireAuth(),
            onBookFromAi: (drinkId: string): void => this.openMatchedDrink(drinkId)
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onOpenLogin: (): void => this.onOpenLogin(),
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
          .height(Theme.nav.tabHeight + Theme.nav.lift)
          .padding({ bottom: Theme.nav.lift })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.detailRoute.length > 0 && this.kind() === 'drink') {
        DrinkDetailPane({
          drinkId: this.detailId(),
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'tip') {
        TipDetailPane({ tipId: this.detailId(), refreshToken: this.detailToken })
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
      } else if (this.detailRoute.length > 0 && this.kind() === 'history') {
        HistoryPage({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'tries') {
        TriesPage({ refreshToken: this.detailToken })
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
      } else if (this.detailRoute.length > 0 && this.kind() === 'dashboard') {
        DashboardPage({ refreshToken: this.detailToken })
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
    })
  }
}
