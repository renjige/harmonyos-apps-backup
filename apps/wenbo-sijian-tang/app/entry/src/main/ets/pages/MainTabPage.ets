import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ThoughtsPage } from './ThoughtsPage'
import { CirclePage } from './CirclePage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { WriteThoughtPane } from '../components/wisdom/WriteThoughtPane'
import { ThoughtSearchOverlay } from '../components/wisdom/ThoughtSearchOverlay'
import { FavoritesPane } from '../components/wisdom/FavoritesPane'
import { HistoryPane } from '../components/wisdom/HistoryPane'
import { WisdomDetailHost } from '../components/detail/WisdomDetailHost'
import { AuthService } from '../services/AuthService'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '今日堂'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '思录'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'message'
    t2.label = '思友圈'
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
  @State writeToken: number = 0
  @State detailToken: number = 0
  @State detailKind: string = ''
  @State detailId: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('showWriteThought') @Watch('onWriteFlag') showWrite: boolean = false
  @StorageLink('writeThoughtId') writeThoughtId: string = ''
  @StorageLink('detailRoute') @Watch('onDetailFlag') detailRoute: string = ''
  @StorageLink('whRefresh') whRefresh: number = 0
  @StorageLink('showMessages') showMessages: boolean = false
  @StorageLink('showThoughtSearch') showSearch: boolean = false
  @StorageLink('showFavorites') showFavorites: boolean = false
  @StorageLink('showHistory') showHistory: boolean = false
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '魏文波'
  @Prop appName: string = '思见堂'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  onWriteFlag(): void {
    if (this.showWrite) {
      this.writeToken += 1
    }
  }

  onDetailFlag(): void {
    if (this.detailRoute.length > 0) {
      this.detailToken += 1
      const idx = this.detailRoute.indexOf(':')
      if (idx >= 0) {
        this.detailKind = this.detailRoute.substring(0, idx)
        this.detailId = this.detailRoute.substring(idx + 1)
      }
    }
  }

  onDarkChange(): void {
    Theme.setColorMode(this.darkModeOn ? 'dark' : 'light')
  }

  onTabLink(): void {
    this.current = this.mainTabIndex
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({ appName: this.appName, refreshToken: this.whRefresh }).layoutWeight(1)
        } else if (this.current === 1) {
          ThoughtsPage({
            refreshToken: this.whRefresh,
            onRequireAuth: (): void => { this.onRequireAuth() }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          CirclePage({
            refreshToken: this.whRefresh,
            onRequireAuth: (): void => { this.onRequireAuth() }
          }).layoutWeight(1)
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
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showWrite) {
        WriteThoughtPane({
          editId: this.writeThoughtId,
          refreshToken: this.writeToken,
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.detailRoute.length > 0) {
        WisdomDetailHost({
          detailKind: this.detailKind,
          detailId: this.detailId,
          refreshToken: this.detailToken,
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showSearch) {
        ThoughtSearchOverlay()
          .width('100%')
          .height('100%')
          .zIndex(14)
      }

      if (this.showFavorites) {
        FavoritesPane()
          .width('100%')
          .height('100%')
          .zIndex(14)
      }

      if (this.showHistory) {
        HistoryPane()
          .width('100%')
          .height('100%')
          .zIndex(14)
      }

      if (this.showMessages) {
        MessagesPage()
          .width('100%')
          .height('100%')
          .zIndex(14)
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
          color: this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : Color.Transparent)
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
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      AppStorage.setOrCreate('mainTabIndex', t.index)
    })
  }
}
