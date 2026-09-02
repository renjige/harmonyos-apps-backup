import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { WritePage } from './WritePage'
import { TimelinePage } from './TimelinePage'
import { ReviewPage } from './ReviewPage'
import { SettingsPage } from './SettingsPage'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '记录'],
      ['1', 'biz', '时间轴'],
      ['2', 'chart', '回顾'],
      ['3', 'user', '设置']
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
  @Prop appName: string = '积累日记'
  private tabs: TabItem[] = TabItem.all()

  private bumpReload(): void {
    this.reloadToken++
  }

  build() {
    Column() {
      if (this.current === 0) {
        WritePage({ reloadToken: this.reloadToken }).layoutWeight(1)
      } else if (this.current === 1) {
        TimelinePage({
          reloadToken: this.reloadToken,
          onOpenReview: (): void => { this.current = 2 }
        }).layoutWeight(1)
      } else if (this.current === 2) {
        ReviewPage().layoutWeight(1)
      } else {
        SettingsPage().layoutWeight(1)
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
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
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
      if (t.index === 0 || t.index === 1) {
        this.bumpReload()
      }
    })
  }
}
