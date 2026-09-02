import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { PuzzleListPage } from './PuzzleListPage'
import { FamilyPage } from './FamilyPage'
import { GrowthPage } from './GrowthPage'
import { MinePage } from './MinePage'
import { QuizOverlay } from './QuizOverlay'
import { FamilyPlayOverlay } from './FamilyPlayOverlay'
import { PuzzleDetailOverlay } from './PuzzleDetailOverlay'
import { QuizSummaryOverlay } from './QuizSummaryOverlay'
import { CustomPuzzleOverlay } from './CustomPuzzleOverlay'
import { WeeklyReviewOverlay } from './WeeklyReviewOverlay'
import { QuizNav } from '../services/QuizNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '今日'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'search'
    t1.label = '探索'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'message'
    t2.label = '亲子'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'chart'
    t3.label = '成长'
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
  @StorageLink('quizRoute') quizRoute: string = ''
  @StorageLink('mainTab') @Watch('onMainTab') mainTab: number = 0
  @StorageLink('quizTick') tick: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '亲子智谜'
  @Prop tagline: string = '一起动脑，一起开心。'
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
          PuzzleListPage().layoutWeight(1)
        } else if (this.current === 2) {
          FamilyPage().layoutWeight(1)
        } else if (this.current === 3) {
          GrowthPage().layoutWeight(1)
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
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(30,42,58,0.05)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.quizRoute === QuizNav.QUIZ) {
        QuizOverlay()
          .width('100%')
          .height('100%')
      } else if (this.quizRoute === QuizNav.FAMILY) {
        FamilyPlayOverlay()
          .width('100%')
          .height('100%')
      } else if (this.quizRoute === QuizNav.DETAIL) {
        PuzzleDetailOverlay()
          .width('100%')
          .height('100%')
      } else if (this.quizRoute === QuizNav.SUMMARY) {
        QuizSummaryOverlay()
          .width('100%')
          .height('100%')
      } else if (this.quizRoute === QuizNav.CUSTOM) {
        CustomPuzzleOverlay()
          .width('100%')
          .height('100%')
      } else if (this.quizRoute === QuizNav.REVIEW) {
        WeeklyReviewOverlay()
          .width('100%')
          .height('100%')
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
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.current = t.index
      AppStorage.setOrCreate('mainTab', t.index)
    })
  }
}
