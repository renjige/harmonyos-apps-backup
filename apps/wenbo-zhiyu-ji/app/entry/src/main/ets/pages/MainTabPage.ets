import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { LibraryPage } from './LibraryPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AuthorListOverlay } from '../components/wisdom/AuthorListOverlay'
import { QuoteSearchOverlay } from '../components/wisdom/QuoteSearchOverlay'
import { FavoritesPane } from '../components/wisdom/FavoritesPane'
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
    t0.label = '首页'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '语录库'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'user'
    t2.label = '我的'
    tabs.push(t2)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailToken: number = 0
  @State detailKind: string = ''
  @State detailId: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') @Watch('onDetailFlag') detailRoute: string = ''
  @StorageLink('whRefresh') whRefresh: number = 0
  @StorageLink('showQuoteSearch') showSearch: boolean = false
  @StorageLink('showFavorites') showFavorites: boolean = false
  @StorageLink('showAuthorList') showAuthorList: boolean = false
  @StorageLink('showMessages') showMessages: boolean = false
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '知语集'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

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
          HomePage({
            appName: this.appName,
            refreshToken: this.whRefresh,
            onRequireAuth: (): void => { this.onRequireAuth() }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          LibraryPage({ refreshToken: this.whRefresh }).layoutWeight(1)
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

      if (this.detailRoute.length > 0) {
        WisdomDetailHost({
          detailKind: this.detailKind,
          detailId: this.detailId,
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showSearch) {
        QuoteSearchOverlay()
          .width('100%')
          .height('100%')
          .zIndex(14)
      }

      if (this.showFavorites) {
        FavoritesPane({
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
          .width('100%')
          .height('100%')
          .zIndex(14)
      }

      if (this.showAuthorList) {
        AuthorListOverlay()
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
