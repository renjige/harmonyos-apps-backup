import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { RecordsPage } from './RecordsPage'
import { LibraryPage } from './LibraryPage'
import { MinePage } from './MinePage'
import { ChallengeOverlay } from './ChallengeOverlay'
import { FeihuaOverlay } from './FeihuaOverlay'
import { ScoreOverlay } from './ScoreOverlay'
import { PoemDetailOverlay } from './PoemDetailOverlay'
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
    t0.label = '首页'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'chart'
    t1.label = '记录'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'biz'
    t2.label = '诗库'
    tabs.push(t2)
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
  @Prop company: string = '承德锐泓科技有限公司'
  @Prop appName: string = '诗词挑战'
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

  private openMine(): void {
    PoetryNav.openMine()
  }

  private openLibraryTab(): void {
    this.current = 2
    AppStorage.setOrCreate('mainTab', 2)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            onOpenMine: (): void => this.openMine(),
            onOpenLibrary: (): void => this.openLibraryTab()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          RecordsPage().layoutWeight(1)
        } else {
          LibraryPage({
            onOpenMine: (): void => this.openMine()
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
        }
      }
      .width('100%')
      .height('100%')

      if (this.poetryRoute === PoetryNav.QUIZ) {
        ChallengeOverlay().width('100%').height('100%')
      } else if (this.poetryRoute === PoetryNav.SCORE) {
        ScoreOverlay().width('100%').height('100%')
      } else if (this.poetryRoute === PoetryNav.FEIHUA) {
        FeihuaOverlay().width('100%').height('100%')
      } else if (this.poetryRoute === PoetryNav.POEM) {
        PoemDetailOverlay().width('100%').height('100%')
      } else if (this.poetryRoute === PoetryNav.MINE) {
        Column() {
          Row() {
            Text('返回')
              .fontSize(15)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 20, top: 16, bottom: 8 })
              .onClick((): void => PoetryNav.close())
          }
          .width('100%')
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => this.onOpenLogin(),
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
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
      AppStorage.setOrCreate('mainTab', t.index)
    })
  }
}
