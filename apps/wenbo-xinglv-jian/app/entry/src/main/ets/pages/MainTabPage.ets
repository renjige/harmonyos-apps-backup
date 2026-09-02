import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { TripsPage } from './TripsPage'
import { JournalPage } from './JournalPage'
import { InspirationPage } from './InspirationPage'
import { MinePage } from './MinePage'
import { TripFormPane } from '../components/trip/TripFormPane'
import { ItemFormPane } from '../components/trip/ItemFormPane'
import { TripDetailPane } from '../components/trip/TripDetailPane'
import { TemplatesPane } from '../components/trip/TemplatesPane'
import { SearchPane } from '../components/trip/SearchPane'
import { JournalFormPane } from '../components/journal/JournalFormPane'
import { JournalDetailPane } from '../components/journal/JournalDetailPane'
import { InspireFormPane } from '../components/inspiration/InspireFormPane'
import { InspireDetailPane } from '../components/inspiration/InspireDetailPane'
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
    t0.name = 'biz'
    t0.label = '行程'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'book'
    t1.label = '旅迹'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'bookmark'
    t2.label = '灵感'
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
  @State current: number = 0
  @State formToken: number = 0
  @State itemToken: number = 0
  @State detailToken: number = 0
  @State journalFormToken: number = 0
  @State journalDetailToken: number = 0
  @State inspireFormToken: number = 0
  @State inspireDetailToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('showTripForm') @Watch('onForm') showTripForm: boolean = false
  @StorageLink('showItemForm') @Watch('onItem') showItemForm: boolean = false
  @StorageLink('detailTripId') @Watch('onDetail') detailTripId: string = ''
  @StorageLink('showJournalForm') @Watch('onJournalForm') showJournalForm: boolean = false
  @StorageLink('detailJournalId') @Watch('onJournalDetail') detailJournalId: string = ''
  @StorageLink('showInspireForm') @Watch('onInspireForm') showInspireForm: boolean = false
  @StorageLink('detailInspireId') @Watch('onInspireDetail') detailInspireId: string = ''
  @StorageLink('showTemplates') showTemplates: boolean = false
  @StorageLink('showSearch') showSearch: boolean = false
  @StorageLink('tripRefresh') tripRefresh: number = 0
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('darkModeOn') @Watch('onDark') darkModeOn: boolean = false
  @StorageLink('toastText') toastText: string = ''
  @StorageLink('fontLevel') @Watch('onFont') fontLevel: number = 1
  @Prop company: string = '薛茂新'
  @Prop appName: string = '行旅笺'
  @Prop tagline: string = '纸上的旅途，从容记录每一段出行'
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

  onJournalForm(): void {
    if (this.showJournalForm) {
      this.journalFormToken += 1
    }
  }

  onJournalDetail(): void {
    if (this.detailJournalId.length > 0) {
      this.journalDetailToken += 1
    }
  }

  onInspireForm(): void {
    if (this.showInspireForm) {
      this.inspireFormToken += 1
    }
  }

  onInspireDetail(): void {
    if (this.detailInspireId.length > 0) {
      this.inspireDetailToken += 1
    }
  }

  onDark(): void {
    this.applyUiMode()
  }

  aboutToAppear(): void {
    this.current = this.mainTabIndex
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
    if (this.tabBarHidden || this.current === 3) {
      return false
    }
    return true
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Stack() {
          TripsPage({
            appName: this.appName,
            visible: this.current === 0,
            themeDark: this.darkModeOn
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 0 ? Visibility.Visible : Visibility.None)
          JournalPage({
            refreshToken: this.tripRefresh,
            themeDark: this.darkModeOn
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 1 ? Visibility.Visible : Visibility.None)
          InspirationPage({
            refreshToken: this.tripRefresh,
            themeDark: this.darkModeOn
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 2 ? Visibility.Visible : Visibility.None)
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
            .visibility(this.current === 3 ? Visibility.Visible : Visibility.None)
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
          .margin({ left: 12, right: 12, bottom: 8 })
          .borderRadius(Theme.radius.xl)
          .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
          .shadow({
            radius: 12,
            color: this.darkModeOn ? 'rgba(0,0,0,0.35)' : 'rgba(44,44,44,0.08)',
            offsetX: 0,
            offsetY: 4
          })
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
            .backgroundColor(Theme.palette(this.darkModeOn).brandAccent)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 20, bottom: 72 })
            .onClick((): void => { TripNav.fabForTab(this.current) })
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
      if (this.showJournalForm) {
        JournalFormPane({ refreshToken: this.journalFormToken })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }
      if (this.detailJournalId.length > 0) {
        JournalDetailPane({ refreshToken: this.journalDetailToken })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }
      if (this.showInspireForm) {
        InspireFormPane({ refreshToken: this.inspireFormToken })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }
      if (this.detailInspireId.length > 0) {
        InspireDetailPane({ refreshToken: this.inspireDetailToken })
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
            Theme.palette(this.darkModeOn).brandAccent : Theme.palette(this.darkModeOn).textSecondary
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
          Theme.palette(this.darkModeOn).brandAccent : Theme.palette(this.darkModeOn).textSecondary)
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
