import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { MatchListPage } from './MatchListPage'
import { LogHubPage } from './LogHubPage'
import { CollectPage } from './CollectPage'
import { SettingsPage } from './SettingsPage'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '首页'],
      ['1', 'biz', '赛事'],
      ['2', 'chart', '记录'],
      ['3', 'ai', '收藏'],
      ['4', 'user', '我的']
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
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('mainTabIndex') current: number = 0
  @State reloadToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop appName: string = '赛场拾录'
  private tabs: TabItem[] = TabItem.all()

  private bumpReload(): void {
    this.reloadToken++
  }

  build() {
    Column() {
      if (this.current === 0) {
        HomePage({ reloadToken: this.reloadToken }).layoutWeight(1)
      } else if (this.current === 1) {
        MatchListPage({ reloadToken: this.reloadToken }).layoutWeight(1)
      } else if (this.current === 2) {
        LogHubPage({ reloadToken: this.reloadToken }).layoutWeight(1)
      } else if (this.current === 3) {
        CollectPage({ reloadToken: this.reloadToken }).layoutWeight(1)
      } else {
        SettingsPage({ reloadToken: this.reloadToken }).layoutWeight(1)
      }

      if (!this.tabBarHidden) {
        Row() {
          ForEach(this.tabs, (t: TabItem) => {
            this.TabBarItem(t)
          }, (t: TabItem) => `${t.index}`)
        }
        .width('100%')
        .height(Theme.nav.tabHeight)
        .padding({ left: Theme.space.s2, right: Theme.space.s2, bottom: 4, top: 4 })
        .margin({ left: Theme.space.s3, right: Theme.space.s3, bottom: Theme.space.s2 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .shadow({ radius: 12, color: 'rgba(15,23,42,0.08)', offsetY: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
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
      .width(40)
      .height(26)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          (this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary) :
          (this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary))
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      AppStorage.setOrCreate('mainTabIndex', t.index)
      this.bumpReload()
    })
  }
}
