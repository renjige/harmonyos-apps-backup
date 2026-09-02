import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { BreathPage } from './BreathPage'
import { RecordPage } from './RecordPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { QuoteListPage } from './QuoteListPage'
import { QuoteDetailPane } from '../components/detail/QuoteDetailPane'
import { BreathModeDetailPane } from '../components/detail/BreathModeDetailPane'
import { BreathGuideOverlay } from '../components/cool/BreathGuideOverlay'
import { AuthService } from '../services/AuthService'
import { CoolPlanNav } from '../services/CoolPlanNav'
import { CoolPlanBizService } from '../services/CoolPlanBizService'
import { BreathModeItem } from '../models/CoolPlanModels'

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
    t1.name = 'heart'
    t1.label = '呼吸'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'calendar'
    t2.label = '记录'
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
  @State guideMode: BreathModeItem | undefined = undefined
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') @Watch('onDetailRouteChange') detailRoute: string = ''
  @StorageLink('detailToken') detailToken: number = 0
  @StorageLink('switchTabIndex') @Watch('onSwitchTab') switchTabIndex: number = -1
  @StorageLink('contentRefreshBump') @Watch('onRefreshBump') contentRefreshBump: number = 0
  @StorageLink('pendingToast') pendingToast: string = ''
  @State toastText: string = ''
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '清凉计划'
  @Prop tagline: string = '在喧嚣中找回内心的清凉——你的智慧心灵休憩站'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    if (this.pendingToast.length > 0) {
      this.showToast(this.pendingToast)
      AppStorage.setOrCreate('pendingToast', '')
      this.bump()
    }
  }

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

  onRefreshBump(): void {
    if (this.contentRefreshBump > 0) {
      this.bump()
      if (this.pendingToast.length > 0) {
        this.showToast(this.pendingToast)
        AppStorage.setOrCreate('pendingToast', '')
      }
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2800)
  }

  private async startBreathGuide(modeId: string): Promise<void> {
    const mode = await CoolPlanBizService.findBreathMode(modeId)
    if (mode === undefined) {
      return
    }
    CoolPlanNav.close()
    this.current = 1
    this.guideMode = mode
    AppStorage.setOrCreate('tabBarHidden', true)
    this.bump()
  }

  private closeBreathGuide(): void {
    this.guideMode = undefined
    AppStorage.setOrCreate('tabBarHidden', false)
    this.bump()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onOpenMessages: (): void => CoolPlanNav.openMessages()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          BreathPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          RecordPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
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
          .height(Theme.nav.tabHeight)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
          .padding({ left: Theme.space.s2, right: Theme.space.s2 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .shadow({ radius: 12, color: Theme.colors().overlayScrim, offsetY: -2 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.detailRoute.length > 0 && CoolPlanNav.kind() === 'quote') {
        QuoteDetailPane({
          quoteId: CoolPlanNav.parseId(),
          refreshToken: this.detailToken
        })
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && CoolPlanNav.kind() === 'breath') {
        BreathModeDetailPane({
          modeId: CoolPlanNav.parseId(),
          refreshToken: this.detailToken,
          onStart: (modeId: string): void => { void this.startBreathGuide(modeId) }
        })
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && CoolPlanNav.kind() === 'messages') {
        MessagesPage()
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && CoolPlanNav.kind() === 'quote-list') {
        QuoteListPage()
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      }

      if (this.guideMode !== undefined) {
        BreathGuideOverlay({
          mode: this.guideMode,
          onClose: (): void => this.closeBreathGuide(),
          onSaved: (): void => this.bump()
        })
          .width('100%').height('100%').zIndex(30)
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .maxLines(3)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(40)
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
