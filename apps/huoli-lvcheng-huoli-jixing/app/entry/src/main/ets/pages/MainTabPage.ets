import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomeDashboardPage } from './HomeDashboardPage'
import { JournalHubPage } from './JournalHubPage'
import { ActionHubPage } from './ActionHubPage'
import { GrowthHubPage } from './GrowthHubPage'
import { MinePage } from './MinePage'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '工作台'],
      ['1', 'chart', '纪行'],
      ['2', 'biz', '行动'],
      ['3', 'chart', '成长'],
      ['4', 'user', '我的']
    ]
    for (const d of defs) {
      const t = new TabItem()
      t.index = parseInt(d[0], 10)
      t.name = d[1] as AppIconName
      t.label = d[2]
      tabs.push(t)
    }
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State refreshToken: number = 0
  @State journalSearchPulse: number = 0
  @State growthPlansPulse: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 28
  private controller: TabsController = new TabsController()

  private bumpRefresh(): void {
    this.refreshToken++
  }

  private switchTab(index: number, pulsePlans: boolean = false): void {
    this.current = index
    this.controller.changeIndex(index)
    if (pulsePlans) {
      this.growthPlansPulse++
    }
    this.bumpRefresh()
  }

  build() {
    Column() {
      Tabs({ index: this.current, controller: this.controller }) {
        TabContent() {
          HomeDashboardPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onChanged: (): void => { this.bumpRefresh() },
            onOpenJournal: (): void => { this.switchTab(1) },
            onOpenGrowth: (): void => { this.switchTab(3, true) },
            onOpenAction: (): void => { this.switchTab(2) },
            onOpenSearch: (): void => {
              this.switchTab(1)
              this.journalSearchPulse++
            }
          })
        }

        TabContent() {
          JournalHubPage({
            refreshToken: this.refreshToken,
            searchPulse: this.journalSearchPulse,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onChanged: (): void => { this.bumpRefresh() }
          })
        }

        TabContent() {
          ActionHubPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onChanged: (): void => { this.bumpRefresh() }
          })
        }

        TabContent() {
          GrowthHubPage({
            refreshToken: this.refreshToken,
            plansPulse: this.growthPlansPulse,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onChanged: (): void => { this.bumpRefresh() }
          })
        }

        TabContent() {
          MinePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onDataCleared: (): void => { this.bumpRefresh() }
          })
        }
      }
      .barHeight(0)
      .animationDuration(0)
      .onChange((idx: number): void => {
        this.current = idx
        this.bumpRefresh()
      })
      .layoutWeight(1)

      if (!this.tabBarHidden) {
        Row() {
          ForEach(this.tabs, (t: TabItem) => {
            this.TabBarItem(t)
          }, (t: TabItem) => `${t.index}`)
        }
        .width('100%')
        .height(this.tabBarHeight)
        .padding({ left: Theme.space.s2, right: Theme.space.s2, bottom: this.tabSafeBottom })
        .margin({ left: Theme.space.s3, right: Theme.space.s3, bottom: Theme.space.s2 })
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .shadow({ radius: 16, color: 'rgba(26,42,58,0.08)', offsetY: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 3 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(44)
      .height(26)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : Color.Transparent)
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(10)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Regular)
        .maxLines(1)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick((): void => {
      this.switchTab(t.index)
    })
  }
}
