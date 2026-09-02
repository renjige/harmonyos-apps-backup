import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { HomePage } from './HomePage'
import { StudyPage } from './StudyPage'
import { VaultPage } from './VaultPage'
import { DailyPage } from './DailyPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { CatalogBrowsePage } from './CatalogBrowsePage'
import { ChallengePage } from './ChallengePage'
import { HistoryRecordPage } from './HistoryRecordPage'
import { PlanStatsPage } from './PlanStatsPage'
import { TimelinePage } from './TimelinePage'
import { AchievementPage } from './AchievementPage'
import { ReviewPage } from './ReviewPage'
import { FlashcardReviewPage } from './FlashcardReviewPage'
import { StudyCalendarPage } from './StudyCalendarPage'
import { UserNotePage } from './UserNotePage'
import { AIAssistantPage } from './AIAssistantPage'
import { InsightDetailPane } from '../components/detail/InsightDetailPane'
import { DailyDetailPane } from '../components/detail/DailyDetailPane'
import { PathDetailPane } from '../components/detail/PathDetailPane'
import { NoteEditPane } from '../components/ask/NoteEditPane'
import { AuthService } from '../services/AuthService'
import { AskNav } from '../services/AskNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '工作台'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'chart'
    t1.label = '学习'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'bookmark'
    t2.label = '知识库'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'book'
    t3.label = '新知'
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
  @State detailToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') @Watch('onDetailFlag') detailRoute: string = ''
  @StorageLink('vaultRefresh') vaultRefresh: number = 0
  @StorageLink('showMessages') showMessages: boolean = false
  @StorageLink('showDiagnose') showDiagnose: boolean = false
  @StorageLink('showNoteEdit') showNoteEdit: boolean = false
  @StorageLink('noteEditId') noteEditId: string = ''
  @StorageLink('learnPanel') learnPanel: string = ''
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '问知'
  @Prop tagline: string = '提问求知、结构化解答与个人知识库，把答案真正留下来。'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  onDetailFlag(): void {
    if (this.detailRoute.length > 0) {
      this.detailToken += 1
    }
  }

  onDarkChange(): void {
    Theme.setColorMode(this.darkModeOn ? 'dark' : 'light')
  }

  onTabLink(): void {
    this.current = this.mainTabIndex
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({ appName: this.appName, refreshToken: this.vaultRefresh }).layoutWeight(1)
        } else if (this.current === 1) {
          StudyPage({ refreshToken: this.vaultRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          VaultPage({ refreshToken: this.vaultRefresh }).layoutWeight(1)
        } else if (this.current === 3) {
          DailyPage({ refreshToken: this.vaultRefresh }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => {
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
          .margin({ left: Theme.space.s3, right: Theme.space.s3, bottom: Theme.space.s3 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.detailRoute.length > 0 && AskNav.parseKind() === 'path') {
        PathDetailPane({
          pathId: AskNav.parseId(),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.detailRoute.length > 0 && AskNav.parseKind() === 'daily') {
        DailyDetailPane({
          itemId: AskNav.parseId(),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.detailRoute.length > 0 && AskNav.parseKind() !== 'daily' && AskNav.parseKind() !== 'path') {
        InsightDetailPane({
          kind: AskNav.parseKind(),
          itemId: AskNav.parseId(),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showNoteEdit) {
        NoteEditPane({ itemId: this.noteEditId })
          .width('100%')
          .height('100%')
          .zIndex(19)
      }

      if (this.learnPanel === 'catalog' || this.learnPanel === 'topics') {
        CatalogBrowsePage({ mode: this.learnPanel })
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.learnPanel === 'challenge') {
        ChallengePage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.learnPanel === 'history' || this.learnPanel === 'wrong' || this.learnPanel === 'cards') {
        HistoryRecordPage({ mode: this.learnPanel })
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.learnPanel === 'plan' || this.learnPanel === 'stats') {
        PlanStatsPage({ mode: this.learnPanel })
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.learnPanel === 'timeline') {
        TimelinePage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.learnPanel === 'achievements') {
        AchievementPage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.learnPanel === 'review') {
        ReviewPage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.learnPanel === 'notes') {
        UserNotePage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.learnPanel === 'flashcards') {
        FlashcardReviewPage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.learnPanel === 'calendar') {
        StudyCalendarPage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showDiagnose) {
        Column() {
          AppNavBar({
            title: '求知偏好',
            onBack: (): void => { AskNav.closeDiagnose() }
          })
          AIAssistantPage({
            onBookFromAi: (_c: string): void => {
              AskNav.closeDiagnose()
              AskNav.switchTab(0)
            }
          })
            .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(16)
      }

      if (this.showMessages) {
        MessagesPage()
          .width('100%')
          .height('100%')
          .zIndex(14)
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
        Theme.colors().brandPrimaryContainer : Color.Transparent)
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
      AppStorage.setOrCreate('mainTabIndex', t.index)
    })
  }
}
