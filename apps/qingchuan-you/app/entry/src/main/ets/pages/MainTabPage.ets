import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ExplorePage } from './ExplorePage'
import { TripListPage } from './TripListPage'
import { CommunityPage } from './CommunityPage'
import { MinePage } from './MinePage'
import { FavoritesPage } from './FavoritesPage'
import { AboutPage } from './AboutPage'
import { SearchPage } from './SearchPage'
import { MessagesPage } from './MessagesPage'
import { DestDetailPane } from '../components/detail/DestDetailPane'
import { InspDetailPane } from '../components/detail/InspDetailPane'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { NoteFormPane } from '../components/detail/NoteFormPane'
import { TripDetailPane } from '../components/detail/TripDetailPane'
import { TripWizardPane } from '../components/detail/TripWizardPane'
import { AIAssistantPage } from './AIAssistantPage'
import { AuthService } from '../services/AuthService'
import { ScenicDetailNav } from '../services/ScenicDetailNav'

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
    t1.label = '探索'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'biz'
    t2.label = '行程'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'message'
    t3.label = '社区'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
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
  @StorageLink('colorDark') @Watch('onColorDarkChange') colorDark: boolean = false
  @Prop company: string = '晴川旅行文化'
  @Prop appName: string = '晴川游'
  @Prop tagline: string = '轻量智慧旅行伴侣，行前发现目的地灵感，行中用智能规划生成每日行程'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private kind(): string {
    return ScenicDetailNav.kind()
  }

  private detailId(): string {
    return ScenicDetailNav.parseId()
  }

  private bump(): void {
    this.contentRefresh += 1
  }

  onDetailRouteChange(): void {
    if (this.detailRoute.length === 0) {
      this.bump()
    }
  }

  onColorDarkChange(): void {
    Theme.setColorMode(this.colorDark ? 'dark' : 'light')
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({ appName: this.appName, refreshToken: this.contentRefresh }).layoutWeight(1)
        } else if (this.current === 1) {
          ExplorePage({ refreshToken: this.contentRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          TripListPage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 3) {
          CommunityPage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onOpenLogin: (): void => this.onOpenLogin(),
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
            },
            onSwitchTab: (index: number): void => {
              this.current = index
              this.bump()
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

      if (this.detailRoute.length > 0 && this.kind() === 'dest') {
        DestDetailPane({
          destId: this.detailId(),
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'insp') {
        InspDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'note') {
        NoteDetailPane({
          noteId: this.detailId(),
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'nnew') {
        NoteFormPane({
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'trip') {
        TripDetailPane({ tripId: this.detailId(), refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'tnew') {
        TripWizardPane({
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'favorites') {
        FavoritesPage({ refreshToken: this.detailToken }).width('100%').height('100%').zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'about') {
        AboutPage().width('100%').height('100%').zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'messages') {
        MessagesPage({ refreshToken: this.detailToken }).width('100%').height('100%').zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'search') {
        SearchPage({ refreshToken: this.detailToken }).width('100%').height('100%').zIndex(20)
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
            .onClick(() => ScenicDetailNav.close())
            Text('出行偏好')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
          }
          .width('100%')
          .padding({ left: 12, right: Theme.space.pageX, top: 8 })
          AIAssistantPage({
            hideChrome: true,
            onBookFromAi: (destId: string): void => {
              ScenicDetailNav.openDest(destId)
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
