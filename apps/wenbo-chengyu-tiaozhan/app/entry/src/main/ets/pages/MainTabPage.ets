import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { CampaignPage } from './CampaignPage'
import { BankPage } from './BankPage'
import { MinePage } from './MinePage'
import { ChallengeOverlay } from './ChallengeOverlay'
import { ScoreOverlay } from './ScoreOverlay'
import { AIAssistantPage } from './AIAssistantPage'
import { ChapterDetailPane } from '../components/detail/ChapterDetailPane'
import { ThemeDetailPane } from '../components/detail/ThemeDetailPane'
import { BadgeDetailPane } from '../components/detail/BadgeDetailPane'
import { IdiomNav } from '../services/IdiomNav'
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
    t0.label = '今日'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '闯关'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '题库'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '成就'
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
  @Prop appName: string = '成语挑战'
  @Prop tagline: string = '水墨风成语竞技'
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
          CampaignPage().layoutWeight(1)
        } else if (this.current === 2) {
          BankPage().layoutWeight(1)
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

      if (this.quizRoute === IdiomNav.QUIZ) {
        ChallengeOverlay().width('100%').height('100%')
      } else if (this.quizRoute === IdiomNav.SCORE) {
        ScoreOverlay().width('100%').height('100%')
      } else if (this.quizRoute === IdiomNav.CHAPTER) {
        ChapterDetailPane().width('100%').height('100%')
      } else if (this.quizRoute === IdiomNav.THEME) {
        ThemeDetailPane().width('100%').height('100%')
      } else if (this.quizRoute === IdiomNav.BADGE) {
        BadgeDetailPane().width('100%').height('100%')
      } else if (this.quizRoute === IdiomNav.DIAGNOSE) {
        Column() {
          AIAssistantPage({
            onRequireAuth: () => this.onRequireAuth(),
            onBookFromAi: (_c: string) => {
              IdiomNav.close()
              AppStorage.setOrCreate('mainTab', 2)
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
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      AppStorage.setOrCreate('mainTab', t.index)
    })
  }
}
