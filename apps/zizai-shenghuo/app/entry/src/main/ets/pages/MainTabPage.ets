import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { WisdomHomePage } from './WisdomHomePage'
import { RecordPage } from './RecordPage'
import { RhythmPage } from './RhythmPage'
import { ZizaiMinePage } from './ZizaiMinePage'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '首页'],
      ['1', 'message', '记录'],
      ['2', 'chart', '节奏'],
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
  @State current: number = 0
  @State refreshToken: number = 0
  onPrivacyRevoked: () => void = () => {}
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 16

  build() {
    Column() {
      if (this.current === 0) {
        WisdomHomePage({
          refreshToken: this.refreshToken,
          bottomInset: this.tabBarHeight + this.tabSafeBottom
        }).layoutWeight(1)
      } else if (this.current === 1) {
        RecordPage({
          refreshToken: this.refreshToken,
          bottomInset: this.tabBarHeight + this.tabSafeBottom
        }).layoutWeight(1)
      } else if (this.current === 2) {
        RhythmPage({
          refreshToken: this.refreshToken,
          bottomInset: this.tabBarHeight + this.tabSafeBottom
        }).layoutWeight(1)
      } else {
        ZizaiMinePage({
          refreshToken: this.refreshToken,
          bottomInset: this.tabBarHeight + this.tabSafeBottom,
          onPrivacyRevoked: (): void => this.onPrivacyRevoked(),
          onDataCleared: (): void => { this.refreshToken++ }
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
        .padding({ left: Theme.space.s3, right: Theme.space.s3, bottom: this.tabSafeBottom })
        .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s2 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .shadow({ radius: 16, color: 'rgba(44,44,44,0.08)', offsetY: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 4 }) {
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
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.caption)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 6 })
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      this.refreshToken++
    })
  }
}
