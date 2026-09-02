import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { TrailPage } from './TrailPage'
import { KnowledgePage } from './KnowledgePage'
import { MinePage } from './MinePage'
import { PlayOverlay } from './PlayOverlay'
import { ScoreOverlay } from './ScoreOverlay'
import { AssessOverlay } from './AssessOverlay'
import { MessagesPage } from './MessagesPage'
import { DrillDetailPane } from '../components/detail/DrillDetailPane'
import { ArticleDetailPane } from '../components/detail/ArticleDetailPane'
import { AchievementDetailPane } from '../components/detail/AchievementDetailPane'
import { BrainNav } from '../services/BrainNav'
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
    t0.label = '训练'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'chart'
    t1.label = '轨迹'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'biz'
    t2.label = '知识'
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
  @StorageLink('quizRoute') quizRoute: string = ''
  @StorageLink('mainTab') @Watch('onMainTab') mainTab: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '脑力探秘'
  @Prop tagline: string = '星空沉浸式认知训练'
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
          TrailPage().layoutWeight(1)
        } else if (this.current === 2) {
          KnowledgePage().layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
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
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.quizRoute === BrainNav.DRILL) {
        DrillDetailPane().width('100%').height('100%')
      } else if (this.quizRoute === BrainNav.PLAY) {
        PlayOverlay().width('100%').height('100%')
      } else if (this.quizRoute === BrainNav.ARTICLE) {
        ArticleDetailPane().width('100%').height('100%')
      } else if (this.quizRoute === BrainNav.ACHIEVE) {
        AchievementDetailPane().width('100%').height('100%')
      } else if (this.quizRoute === BrainNav.ASSESS) {
        AssessOverlay().width('100%').height('100%')
      } else if (this.quizRoute === BrainNav.SCORE) {
        ScoreOverlay().width('100%').height('100%')
      } else if (this.quizRoute === BrainNav.MESSAGES) {
        Column() {
          MessagesPage()
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
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
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary,
          active: this.current === t.index
        })
      }
      .width(36)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .borderRadius(14)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
      Text(t.label)
        .fontSize(11)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height(Theme.nav.tabHeight)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.current = t.index
      AppStorage.setOrCreate('mainTab', t.index)
    })
  }
}
