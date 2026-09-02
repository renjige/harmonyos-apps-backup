import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { DiaryPage } from './DiaryPage'
import { MinePage } from './MinePage'
import { AuthService } from '../services/AuthService'

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
    t1.name = 'calendar'
    t1.label = '日记'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'user'
    t2.label = '我的'
    tabs.push(t2)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State mineRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop company: string = '青柠生活'
  @Prop appName: string = '青柠日常'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  build() {
    Column() {
      if (this.current === 0) {
        HomePage({ appName: this.appName }).layoutWeight(1)
      } else if (this.current === 1) {
        DiaryPage().layoutWeight(1)
      } else {
        MinePage({
          appName: this.appName,
          appearToken: this.mineRefresh,
          onOpenLogin: () => this.onOpenLogin(),
          onLogout: () => {
            AuthService.logout()
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
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .shadow({ radius: 16, color: 'rgba(45,74,30,0.08)', offsetY: -2, offsetX: 0 })
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
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      if (t.index === 2) {
        this.mineRefresh++
      }
    })
  }
}
