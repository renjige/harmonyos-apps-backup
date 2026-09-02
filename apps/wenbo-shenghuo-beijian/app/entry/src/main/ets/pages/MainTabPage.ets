import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { NotesPage } from './NotesPage'
import { CalendarPage } from './CalendarPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { WriteSlipPane } from '../components/slip/WriteSlipPane'
import { CatalogListPane } from '../components/slip/CatalogListPane'
import { SlipDetailPane } from '../components/detail/SlipDetailPane'
import { CatalogDetailPane } from '../components/detail/CatalogDetailPane'
import { AuthService } from '../services/AuthService'
import { SlipNav } from '../services/SlipNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '今日'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '笺记'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'calendar'
    t2.label = '日历'
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
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('showWriteSlip') @Watch('onWriteFlag') showWrite: boolean = false
  @StorageLink('writeSlipId') writeSlipId: string = ''
  @StorageLink('detailRoute') @Watch('onDetailFlag') detailRoute: string = ''
  @StorageLink('slipRefresh') slipRefresh: number = 0
  @StorageLink('showMessages') showMessages: boolean = false
  @StorageLink('showCatalogList') showCatalogList: boolean = false
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '魏文波'
  @Prop appName: string = '生活备笺'
  @Prop tagline: string = '把生活琐事轻轻记下来'
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
    }
  }

  onDarkChange(): void {
    Theme.setColorMode(this.darkModeOn ? 'dark' : 'light')
  }

  onTabLink(): void {
    this.current = this.mainTabIndex
  }

  private detailKind(): string {
    return SlipNav.parseKind()
  }

  private detailId(): string {
    return SlipNav.parseId()
  }

  private showFab(): boolean {
    return !this.tabBarHidden && this.current !== 3
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        if (this.current === 0) {
          HomePage({ appName: this.appName, refreshToken: this.slipRefresh }).layoutWeight(1)
        } else if (this.current === 1) {
          NotesPage({ refreshToken: this.slipRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          CalendarPage({ refreshToken: this.slipRefresh }).layoutWeight(1)
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

      if (this.showFab()) {
        Row() {
          Blank()
          Column() {
            Blank()
            Column() {
              AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
            }
            .width(56)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 20, bottom: 72 })
            .onClick((): void => { SlipNav.openWrite('') })
          }
          .height('100%')
        }
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.Transparent)
        .zIndex(8)
      }

      if (this.showWrite) {
        WriteSlipPane({
          editId: this.writeSlipId,
          refreshToken: this.writeToken
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.detailRoute.length > 0 && this.detailKind() === 'slip') {
        SlipDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.detailRoute.length > 0 && this.detailKind() !== 'slip') {
        CatalogDetailPane({
          kind: this.detailKind(),
          itemId: this.detailId(),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showCatalogList) {
        CatalogListPane()
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
