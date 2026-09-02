import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { DailyPage } from './DailyPage'
import { StudioPage } from './StudioPage'
import { MinePage } from './MinePage'
import { CardDetailPane } from '../components/detail/CardDetailPane'
import { DailyDetailPane } from '../components/detail/DailyDetailPane'
import { SearchPane } from '../components/detail/SearchPane'
import { HotPane } from '../components/detail/HotPane'
import { MessagesPane } from '../components/detail/MessagesPane'
import { PracticeSheet } from '../components/practice/PracticeSheet'
import { PracticeListPane } from '../components/practice/PracticeListPane'
import { FocusTimerPane } from '../components/practice/FocusTimerPane'
import { TrailPane } from '../components/trail/TrailPane'
import { AuthService } from '../services/AuthService'
import { AtelierDetailNav } from '../services/AtelierDetailNav'
import { AIAssistantPage } from './AIAssistantPage'
import { AppToast } from '../components/design-system/AppToast'

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
    t1.name = 'sparkle'
    t1.label = '每日工坊'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'bookmark'
    t2.label = '我的书坊'
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
  @StorageLink('atelierRefresh') atelierRefresh: number = 0
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('gateLogin') @Watch('onGateLogin') gateLogin: boolean = false
  @StorageLink('appToastText') appToastText: string = ''
  @Prop company: string = '魏文波'
  @Prop appName: string = '悦知坊'
  @Prop tagline: string = '悦读片刻，智识日常'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  onTabLink(): void {
    this.current = this.mainTabIndex
  }

  onGateLogin(): void {
    if (this.gateLogin) {
      AppStorage.setOrCreate('gateLogin', false)
      this.onRequireAuth()
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            tagline: this.tagline,
            refreshToken: this.atelierRefresh
          }).layoutWeight(1)
        } else if (this.current === 1) {
          DailyPage({ refreshToken: this.atelierRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          StudioPage({ refreshToken: this.atelierRefresh }).layoutWeight(1)
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
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colorOf(this.themeEpoch).strokeHairline })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)

      this.DetailLayer()

      if (this.showMineSettings) {
        MinePage({
          appName: this.appName,
          overlayMode: true,
          settingsOnly: true,
          onOpenLogin: (): void => { this.onOpenLogin() },
          onLogout: (): void => { this.onLogout() },
          onCloseOverlay: (): void => { AtelierDetailNav.closeSettings() }
        })
          .width('100%')
          .height('100%')
          .zIndex(19)
      }

      if (this.appToastText.length > 0) {
        AppToast({ message: this.appToastText, marginTop: 48 })
          .width('100%')
          .height('100%')
          .zIndex(9999)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailLayer() {
    if (this.detailRoute.length > 0) {
      if (AtelierDetailNav.routeKind(this.detailRoute) === 'card') {
        CardDetailPane({
          itemId: AtelierDetailNav.parseRouteId(this.detailRoute),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (AtelierDetailNav.routeKind(this.detailRoute) === 'daily') {
        DailyDetailPane({
          itemId: AtelierDetailNav.parseRouteId(this.detailRoute),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (AtelierDetailNav.routeKind(this.detailRoute) === 'search') {
        SearchPane({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (AtelierDetailNav.routeKind(this.detailRoute) === 'hot') {
        HotPane({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (AtelierDetailNav.routeKind(this.detailRoute) === 'messages') {
        MessagesPane({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (AtelierDetailNav.routeKind(this.detailRoute) === 'diagnose') {
        AIAssistantPage({
          overlayMode: true,
          onClose: (): void => { AtelierDetailNav.close() },
          onBookFromAi: (_c: string): void => {
            AtelierDetailNav.close()
            AtelierDetailNav.switchTab(0)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (AtelierDetailNav.routeKind(this.detailRoute) === 'worknew') {
        PracticeSheet({
          kind: AtelierDetailNav.parseRouteId(this.detailRoute),
          editId: ''
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (AtelierDetailNav.routeKind(this.detailRoute) === 'workedit') {
        PracticeSheet({
          kind: '',
          editId: AtelierDetailNav.parseRouteId(this.detailRoute)
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (AtelierDetailNav.routeKind(this.detailRoute) === 'works') {
        PracticeListPane({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (AtelierDetailNav.routeKind(this.detailRoute) === 'timer') {
        FocusTimerPane()
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (AtelierDetailNav.routeKind(this.detailRoute) === 'trail') {
        TrailPane({
          trailId: AtelierDetailNav.parseRouteId(this.detailRoute),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }
    }
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ? Theme.colorOf(this.themeEpoch).brandPrimary :
            Theme.colorOf(this.themeEpoch).textSecondary,
          active: this.current === t.index
        })
      }
      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
      .backgroundColor(this.current === t.index ? Theme.colorOf(this.themeEpoch).brandPrimaryContainer : '#00000000')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(10)
        .fontColor(this.current === t.index ? Theme.colorOf(this.themeEpoch).brandPrimary :
          Theme.colorOf(this.themeEpoch).textSecondary)
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
