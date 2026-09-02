import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { MapsPage } from './MapsPage'
import { QuestPage } from './QuestPage'
import { VaultPage } from './VaultPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { QuizOverlay } from './QuizOverlay'
import { MapDetailPane } from '../components/detail/MapDetailPane'
import { TreasureDetailPane } from '../components/detail/TreasureDetailPane'
import { BadgeDetailPane } from '../components/detail/BadgeDetailPane'
import { QuestNav } from '../services/QuestNav'
import { AIAssistantPage } from './AIAssistantPage'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '发现'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '地图'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'ai'
    t2.label = '寻宝'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'chart'
    t3.label = '宝藏'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('questRoute') questRoute: string = ''
  @StorageLink('mainTab') @Watch('onMainTab') mainTab: number = 0
  @Prop company: string = '知寻探索'
  @Prop appName: string = '知识寻宝'
  @Prop tagline: string = ''
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
          MapsPage().layoutWeight(1)
        } else if (this.current === 2) {
          QuestPage().layoutWeight(1)
        } else if (this.current === 3) {
          VaultPage().layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => this.onLogout()
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
          .margin({ left: 12, right: 12, bottom: 8 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(45,27,105,0.10)', offsetY: -2, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.questRoute === QuestNav.MAP) {
        MapDetailPane()
          .width('100%')
          .height('100%')
      } else if (this.questRoute === QuestNav.TREASURE) {
        TreasureDetailPane()
          .width('100%')
          .height('100%')
      } else if (this.questRoute === QuestNav.BADGE) {
        BadgeDetailPane()
          .width('100%')
          .height('100%')
      } else if (this.questRoute === QuestNav.QUIZ) {
        QuizOverlay()
          .width('100%')
          .height('100%')
      } else if (this.questRoute === QuestNav.MESSAGES) {
        Column() {
          Row() {
            Text('关闭')
              .fontSize(15)
              .fontColor(Theme.colors().brandPrimary)
              .padding(16)
              .onClick(() => QuestNav.close())
            Blank()
          }
          .width('100%')
          MessagesPage().layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      } else if (this.questRoute === QuestNav.MATCH) {
        Column() {
          Row() {
            Text('关闭')
              .fontSize(15)
              .fontColor(Theme.colors().brandPrimary)
              .padding(16)
              .onClick(() => QuestNav.close())
            Blank()
          }
          .width('100%')
          AIAssistantPage({
            onRequireAuth: () => this.onRequireAuth(),
            onBookFromAi: (_c: string) => {
              QuestNav.close()
              AppStorage.setOrCreate('mainTab', 1)
              this.current = 1
            }
          }).layoutWeight(1)
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
      .width(Theme.icon.md + 4)
      .height(Theme.icon.md + 4)
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
    .padding({ top: 6, bottom: 6 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      AppStorage.setOrCreate('mainTab', t.index)
      this.current = t.index
    })
  }
}
