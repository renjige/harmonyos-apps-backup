import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { RoutesPage } from './RoutesPage'
import { WeatherPage } from './WeatherPage'
import { MinePage } from './MinePage'
import { FavoritesPage } from './FavoritesPage'
import { AboutPage } from './AboutPage'
import { MessagesPage } from './MessagesPage'
import { PrefsPage } from './PrefsPage'
import { AIAssistantPage } from './AIAssistantPage'
import { RouteDetailPane } from '../components/detail/RouteDetailPane'
import { StopDetailPane } from '../components/detail/StopDetailPane'
import { AdviceDetailPane } from '../components/detail/AdviceDetailPane'
import { CityDetailPane } from '../components/detail/CityDetailPane'
import { AuthService } from '../services/AuthService'
import { CoolDetailNav } from '../services/CoolDetailNav'

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
    t1.name = 'search'
    t1.label = '路线'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '天气'
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
  @Prop company: string = '魏文波'
  @Prop appName: string = '清凉出行'
  @Prop tagline: string = '用清凉指数与树荫路线，帮通勤族在炎热天气里选更舒适的出行方式'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bump(): void {
    this.contentRefresh += 1
  }

  onDetailRouteChange(): void {
    if (this.detailRoute.length === 0) {
      this.bump()
    }
  }

  onSwitchTab(): void {
    if (this.switchTabIndex >= 0) {
      this.current = this.switchTabIndex
      AppStorage.setOrCreate('switchTabIndex', -1)
      this.bump()
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({ appName: this.appName, refreshToken: this.contentRefresh }).layoutWeight(1)
        } else if (this.current === 1) {
          RoutesPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          WeatherPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
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
          .height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.detailRoute.length > 0 && CoolDetailNav.kind() === 'route') {
        RouteDetailPane({
          routeId: CoolDetailNav.parseId(),
          refreshToken: this.detailToken,
          onNeedLogin: (): void => this.onRequireAuth()
        })
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && CoolDetailNav.kind() === 'stop') {
        StopDetailPane({
          stopId: CoolDetailNav.parseId(),
          refreshToken: this.detailToken,
          onNeedLogin: (): void => this.onRequireAuth()
        })
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && CoolDetailNav.kind() === 'advice') {
        AdviceDetailPane({
          adviceId: CoolDetailNav.parseId(),
          refreshToken: this.detailToken
        })
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && CoolDetailNav.kind() === 'city') {
        CityDetailPane({
          cityId: CoolDetailNav.parseId(),
          refreshToken: this.detailToken
        })
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && CoolDetailNav.kind() === 'favorites') {
        FavoritesPage({ refreshToken: this.detailToken }).width('100%').height('100%').zIndex(20)
      } else if (this.detailRoute.length > 0 && CoolDetailNav.kind() === 'about') {
        AboutPage().width('100%').height('100%').zIndex(20)
      } else if (this.detailRoute.length > 0 && CoolDetailNav.kind() === 'messages') {
        MessagesPage({ refreshToken: this.detailToken }).width('100%').height('100%').zIndex(20)
      } else if (this.detailRoute.length > 0 && CoolDetailNav.kind() === 'prefs') {
        PrefsPage().width('100%').height('100%').zIndex(20)
      } else if (this.detailRoute.length > 0 && CoolDetailNav.kind() === 'diagnose') {
        Column() {
          Row() {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44).height(44).justifyContent(FlexAlign.Center).rotate({ angle: 180 })
            .onClick(() => CoolDetailNav.close())
            Text('出行自检')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
          }
          .width('100%')
          .padding({ left: 12, right: Theme.space.pageX, top: 8 })
          AIAssistantPage({
            onBookFromAi: (routeId: string): void => {
              CoolDetailNav.openRoute(routeId)
            }
          }).layoutWeight(1)
        }
        .width('100%').height('100%')
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
