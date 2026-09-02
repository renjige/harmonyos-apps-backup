import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { LibraryPage } from './LibraryPage'
import { ReviewPage } from './ReviewPage'
import { MinePage } from './MinePage'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '首页'],
      ['1', 'biz', '知识库'],
      ['2', 'refresh', '复习'],
      ['3', 'user', '我的']
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
  @StorageLink('wanxiangTabIndex') @Watch('onTabIndexChange') activeTab: number = 0
  @Prop refreshToken: number = 0
  onDataChanged: () => void = () => {}
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 58
  private readonly tabSafeBottom: number = 20

  onTabIndexChange(): void {
    this.onDataChanged()
  }

  build() {
    Column() {
      if (this.activeTab === 0) {
        HomePage({
          refreshToken: this.refreshToken,
          bottomInset: this.tabBarHeight + this.tabSafeBottom + 12
        }).layoutWeight(1)
      } else if (this.activeTab === 1) {
        LibraryPage({
          refreshToken: this.refreshToken,
          bottomInset: this.tabBarHeight + this.tabSafeBottom + 12
        }).layoutWeight(1)
      } else if (this.activeTab === 2) {
        ReviewPage({
          refreshToken: this.refreshToken,
          bottomInset: this.tabBarHeight + this.tabSafeBottom + 12,
          onDataChanged: (): void => this.onDataChanged()
        }).layoutWeight(1)
      } else {
        MinePage({
          refreshToken: this.refreshToken,
          bottomInset: this.tabBarHeight + this.tabSafeBottom + 12,
          onDataChanged: (): void => this.onDataChanged()
        }).layoutWeight(1)
      }

      if (!this.tabBarHidden) {
        Row() {
          ForEach(this.tabs, (t: TabItem) => {
            this.TabBarItem(t)
          }, (t: TabItem) => `${t.index}`)
        }
        .width('100%')
        .height(this.tabBarHeight)
        .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: this.tabSafeBottom })
        .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s2 })
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .shadow({
          radius: 20,
          color: Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(0,122,255,0.10)',
          offsetY: 6
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 4 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.activeTab === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textPrimary
        })
      }
      .width(44)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.activeTab === t.index ?
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.caption)
        .fontWeight(this.activeTab === t.index ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.activeTab === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 6 })
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      AppStorage.setOrCreate('wanxiangTabIndex', t.index)
      this.onDataChanged()
    })
  }
}
