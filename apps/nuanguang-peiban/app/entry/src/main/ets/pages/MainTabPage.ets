import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { CompanionPage } from './CompanionPage'
import { MinePage } from './MinePage'
import { QuoteDetailPane } from '../components/detail/QuoteDetailPane'
import { BreathModeDetailPane } from '../components/detail/BreathModeDetailPane'
import { BreathGuideOverlay } from '../components/warm/BreathGuideOverlay'
import { AuthService } from '../services/AuthService'
import { WarmCompanionNav } from '../services/WarmCompanionNav'
import { WarmCompanionBizService } from '../services/WarmCompanionBizService'
import { BreathModeItem } from '../models/WarmCompanionModels'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '今日心情'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'heart'
    t1.label = '陪伴时光'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'user'
    t2.label = '我的空间'
    tabs.push(t2)
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
  @Prop company: string = '暖光生活'
  @Prop appName: string = '暖光陪伴'
  @Prop tagline: string = '面向都市青年的轻度情绪陪伴应用，不施压慢节奏记录心情与放松陪伴'
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
    const mode = await WarmCompanionBizService.findBreathMode(modeId)
    if (mode === undefined) {
      return
    }
    WarmCompanionNav.close()
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
            refreshToken: this.contentRefresh
          }).layoutWeight(1)
        } else if (this.current === 1) {
          CompanionPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
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

      if (this.detailRoute.length > 0 && WarmCompanionNav.kind() === 'quote') {
        QuoteDetailPane({
          quoteId: WarmCompanionNav.parseId(),
          refreshToken: this.detailToken
        })
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && WarmCompanionNav.kind() === 'breath') {
        BreathModeDetailPane({
          modeId: WarmCompanionNav.parseId(),
          refreshToken: this.detailToken,
          onStart: (modeId: string): void => { void this.startBreathGuide(modeId) }
        })
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
