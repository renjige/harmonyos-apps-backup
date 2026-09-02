import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { ScriptListPage } from './ScriptListPage'
import { CalendarPage } from './CalendarPage'
import { MinePage } from './MinePage'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '首页'],
      ['1', 'calendar', '时光相册'],
      ['2', 'user', '我的']
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
  @State current: number = 0
  @State reloadToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('darkModeEnabled') darkMode: boolean = false
  @Prop appName: string = '生活剧本'
  private tabs: TabItem[] = TabItem.all()

  private bumpReload(): void {
    this.reloadToken++
  }

  build() {
    Column() {
      if (this.current === 0) {
        ScriptListPage({ reloadToken: this.reloadToken, appName: this.appName }).layoutWeight(1)
      } else if (this.current === 1) {
        CalendarPage({ reloadToken: this.reloadToken }).layoutWeight(1)
      } else {
        MinePage({ reloadToken: this.reloadToken }).layoutWeight(1)
      }

      if (!this.tabBarHidden) {
        Row() {
          ForEach(this.tabs, (t: TabItem) => {
            this.TabBarItem(t)
          }, (t: TabItem) => `${t.index}`)
        }
        .width('100%')
        .height(58)
        .padding({ left: Theme.space.s3, right: Theme.space.s3, top: 6, bottom: 6 })
        .margin({ left: Theme.space.s3, right: Theme.space.s3, bottom: Theme.space.s3 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .shadow({ radius: 16, color: 'rgba(45,45,45,0.08)', offsetY: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .id(this.darkMode ? 'tab_dark' : 'tab_light')
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: 20,
          color: this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(36)
      .height(24)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(10)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
        .maxLines(1)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      if (t.index === 0 || t.index === 1 || t.index === 2) {
        this.bumpReload()
      }
    })
  }
}
