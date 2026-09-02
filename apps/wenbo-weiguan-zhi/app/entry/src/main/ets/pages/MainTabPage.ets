import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { ObserveIntroOverlay } from '../components/essay/ObserveIntroOverlay'
import { IntroStore } from '../services/IntroStore'
import { PracticeTabPage } from './PracticeTabPage'
import { CalendarPage } from './CalendarPage'
import { TodayPage } from './TodayPage'
import { MinePage } from './MinePage'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '今日'],
      ['1', 'chart', '练习'],
      ['2', 'calendar', '历'],
      ['3', 'user', '我的']
    ]
    for (const row of defs) {
      const t = new TabItem()
      t.index = parseInt(row[0], 10)
      t.name = row[1] as AppIconName
      t.label = row[2]
      tabs.push(t)
    }
    return tabs
  }
}

@Component
export struct MainTabPage {
  @State current: number = 0
  @State reloadToken: number = 0
  @State showIntro: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('essayTabIndex') @Watch('onTabJump') essayTabIndex: number = 0
  @StorageLink('forceObserveIntro') @Watch('onForceIntro') forceObserveIntro: number = 0
  @StorageLink('essayFontScale') fontScale: number = 1
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '微观志'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.applyTabJump()
    this.showIntro = IntroStore.shouldShowIntro()
  }

  private finishIntro(startCard: boolean): void {
    void IntroStore.markSeen()
    this.showIntro = false
    this.current = 0
    if (startCard) {
      AppStorage.setOrCreate('openObserveCard', Date.now())
      this.bumpReload()
    }
  }

  onTabJump(): void {
    this.applyTabJump()
  }

  onForceIntro(): void {
    if (this.forceObserveIntro > 0) {
      this.showIntro = true
      AppStorage.setOrCreate('forceObserveIntro', 0)
    }
  }

  private applyTabJump(): void {
    if (this.essayTabIndex >= 0 && this.essayTabIndex <= 3) {
      this.current = this.essayTabIndex
      AppStorage.setOrCreate('essayTabIndex', -1)
    }
  }

  private bumpReload(): void {
    this.reloadToken++
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          TodayPage({ reloadToken: this.reloadToken }).layoutWeight(1)
        } else if (this.current === 1) {
          PracticeTabPage({ reloadToken: this.reloadToken }).layoutWeight(1)
        } else if (this.current === 2) {
          CalendarPage({ reloadToken: this.reloadToken }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            reloadToken: this.reloadToken,
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
          .padding({ bottom: 4 })
          .backgroundColor(Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .onAppear((): void => {
        if (this.essayTabIndex >= 0 && this.essayTabIndex <= 3 && this.current !== this.essayTabIndex) {
          this.current = this.essayTabIndex
          AppStorage.setOrCreate('essayTabIndex', -1)
        }
      })

      if (this.showIntro) {
        ObserveIntroOverlay({
          onDone: (): void => { this.finishIntro(false) },
          onStartCard: (): void => { this.finishIntro(true) }
        })
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
        Theme.colors().brandPrimaryContainer : 'transparent')
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
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      this.bumpReload()
    })
  }
}
