import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { TripsPage } from './TripsPage'
import { MinePage } from './MinePage'
import { TripFormPane } from '../components/trip/TripFormPane'
import { ItemFormPane } from '../components/trip/ItemFormPane'
import { TripDetailPane } from '../components/trip/TripDetailPane'
import { TemplatesPane } from '../components/trip/TemplatesPane'
import { CalendarPane } from '../components/trip/CalendarPane'
import { SearchPane } from '../components/trip/SearchPane'
import { AuthService } from '../services/AuthService'
import { TripNav } from '../services/TripNav'
import { ConfigurationConstant } from '@kit.AbilityKit'

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
    t1.label = '行程'
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
  @State current: number = 0
  @State formToken: number = 0
  @State itemToken: number = 0
  @State detailToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('showTripForm') @Watch('onForm') showTripForm: boolean = false
  @StorageLink('showItemForm') @Watch('onItem') showItemForm: boolean = false
  @StorageLink('detailTripId') @Watch('onDetail') detailTripId: string = ''
  @StorageLink('showTemplates') showTemplates: boolean = false
  @StorageLink('showCalendar') showCalendar: boolean = false
  @StorageLink('showSearch') showSearch: boolean = false
  @StorageLink('tripRefresh') tripRefresh: number = 0
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('darkModeOn') @Watch('onDark') darkModeOn: boolean = false
  @StorageLink('toastText') toastText: string = ''
  @StorageLink('fontLevel') @Watch('onFont') fontLevel: number = 1
  @StorageLink('homeHasItems') homeHasItems: boolean = false
  @Prop company: string = '魏文波'
  @Prop appName: string = '行程备忘'
  @Prop tagline: string = '把接下来的安排，先记下来'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  onForm(): void {
    if (this.showTripForm) {
      this.formToken += 1
    }
  }

  onItem(): void {
    if (this.showItemForm) {
      this.itemToken += 1
    }
  }

  onDetail(): void {
    if (this.detailTripId.length > 0) {
      this.detailToken += 1
    }
  }

  onDark(): void {
    this.applyUiMode()
  }

  aboutToAppear(): void {
    this.applyUiMode()
  }

  private applyUiMode(): void {
    Theme.applyDark(this.darkModeOn)
    try {
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        host.getApplicationContext().setColorMode(this.darkModeOn ?
          ConfigurationConstant.ColorMode.COLOR_MODE_DARK :
          ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
      }
    } catch {
    }
  }

  onFont(): void {
    Theme.setFontLevel(this.fontLevel)
  }

  onTabLink(): void {
    this.current = this.mainTabIndex
  }

  private showFab(): boolean {
    if (this.tabBarHidden || this.current === 2) {
      return false
    }
    if (this.current === 0) {
      return this.homeHasItems
    }
    return true
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Stack() {
          HomePage({
            appName: this.appName,
            refreshToken: this.tripRefresh,
            themeDark: this.darkModeOn
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 0 ? Visibility.Visible : Visibility.None)
            .hitTestBehavior(this.current === 0 ? HitTestMode.Default : HitTestMode.None)
          TripsPage({
            refreshToken: this.tripRefresh,
            themeDark: this.darkModeOn
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 1 ? Visibility.Visible : Visibility.None)
            .hitTestBehavior(this.current === 1 ? HitTestMode.Default : HitTestMode.None)
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
            }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 2 ? Visibility.Visible : Visibility.None)
            .hitTestBehavior(this.current === 2 ? HitTestMode.Default : HitTestMode.None)
        }
        .width('100%')
        .layoutWeight(1)
        .clip(true)

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
          .border({ width: { top: 1 }, color: Theme.palette(this.darkModeOn).strokeHairline })
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
              AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.palette(this.darkModeOn).brandOnPrimary })
            }
            .width(52)
            .height(52)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.palette(this.darkModeOn).brandPrimary)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 20, bottom: 72 })
            .hitTestBehavior(HitTestMode.Default)
            .onClick((): void => { TripNav.openCreate() })
          }
          .height('100%')
        }
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.Transparent)
        .zIndex(8)
      }

      if (this.showTripForm) {
        TripFormPane({ refreshToken: this.formToken })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }
      if (this.showItemForm) {
        ItemFormPane({ refreshToken: this.itemToken })
          .width('100%')
          .height('100%')
          .zIndex(17)
      }
      if (this.detailTripId.length > 0) {
        TripDetailPane({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }
      if (this.showTemplates) {
        TemplatesPane()
          .width('100%')
          .height('100%')
          .zIndex(14)
      }
      if (this.showCalendar) {
        CalendarPane()
          .width('100%')
          .height('100%')
          .zIndex(14)
      }
      if (this.showSearch) {
        SearchPane()
          .width('100%')
          .height('100%')
          .zIndex(14)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.palette(this.darkModeOn).brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.palette(this.darkModeOn).brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .align(Alignment.Top)
          .zIndex(30)
          .onAppear((): void => {
            setTimeout((): void => {
              AppStorage.setOrCreate('toastText', '')
            }, 2400)
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.palette(this.darkModeOn).brandPrimary : Theme.palette(this.darkModeOn).textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.palette(this.darkModeOn).brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.palette(this.darkModeOn).brandPrimary : Theme.palette(this.darkModeOn).textSecondary)
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
