import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { MapPage } from './MapPage'
import { LibraryPage } from './LibraryPage'
import { MinePage } from './MinePage'
import { HuntOverlay } from './HuntOverlay'
import { PoemDetailOverlay } from './PoemDetailOverlay'
import { PlaceDetailOverlay } from './PlaceDetailOverlay'
import { MatchOverlay } from './MatchOverlay'
import { MessagesPage } from './MessagesPage'
import { PoetryNav } from '../services/PoetryNav'
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
    t0.label = '寻宝'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'chart'
    t1.label = '地图'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'biz'
    t2.label = '诗库'
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
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('poetryRoute') poetryRoute: string = ''
  @StorageLink('mainTab') @Watch('onMainTab') mainTab: number = 0
  @StorageLink('poetryTick') tick: number = 0
  @StorageLink('huntColorMode') colorMode: string = 'system'
  @Prop company: string = '魏文波'
  @Prop appName: string = '诗词寻宝'
  @Prop tagline: string = '以闯关寻宝与诗地点亮学习鉴赏古典诗词，告别枯燥名篇罗列'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.current = this.mainTab
  }

  onMainTab(): void {
    this.current = this.mainTab
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage().layoutWeight(1)
        } else if (this.current === 1) {
          MapPage().layoutWeight(1)
        } else if (this.current === 2) {
          LibraryPage().layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => {
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
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(26,26,46,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.poetryRoute === PoetryNav.HUNT) {
        HuntOverlay().width('100%').height('100%')
      } else if (this.poetryRoute === PoetryNav.POEM) {
        PoemDetailOverlay().width('100%').height('100%')
      } else if (this.poetryRoute === PoetryNav.PLACE) {
        PlaceDetailOverlay().width('100%').height('100%')
      } else if (this.poetryRoute === PoetryNav.MATCH) {
        MatchOverlay().width('100%').height('100%')
      } else if (this.poetryRoute === PoetryNav.MESSAGES) {
        Column() {
          MessagesPage().layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
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
        .fontSize(11)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      this.current = t.index
      AppStorage.setOrCreate('mainTab', t.index)
      AppStorage.setOrCreate('tabBarHidden', false)
    })
  }
}
