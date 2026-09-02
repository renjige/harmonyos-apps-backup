import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { DiscoverPage } from './DiscoverPage'
import { SchedulePage } from './SchedulePage'
import { TeamsPage } from './TeamsPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { FollowPage } from './FollowPage'
import { StandingsPage } from './StandingsPage'
import { CalendarPage } from './CalendarPage'
import { ComparePage } from './ComparePage'
import { MyActivityPage } from './MyActivityPage'
import { DailyObservePage } from './DailyObservePage'
import { NewsDigestPage } from './NewsDigestPage'
import { ResearchFolderPage } from './ResearchFolderPage'
import { TeamDetailPane } from '../components/detail/TeamDetailPane'
import { MatchDetailPane } from '../components/detail/MatchDetailPane'
import { LeagueDetailPane } from '../components/detail/LeagueDetailPane'
import { ReminderFormOverlay } from '../components/reminder/ReminderFormOverlay'
import { ReminderSettingsPage } from './ReminderSettingsPage'
import { AuthService } from '../services/AuthService'
import { DetailNav } from '../services/DetailNav'
import { SportsBizService } from '../services/SportsBizService'
import { MatchItem } from '../models/MatchModels'

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
    t1.name = 'search'
    t1.label = '发现'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'calendar'
    t2.label = '赛程'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'biz'
    t3.label = '球队'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

/** 5 Tab：首页 | 发现 | 赛程 | 球队 | 我的 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailRefresh: number = 0
  @State contentRefresh: number = 0
  @State showMessages: boolean = false
  @State showFollow: boolean = false
  @State showStandings: boolean = false
  @State showCalendar: boolean = false
  @State showCompare: boolean = false
  @State showMyActivity: boolean = false
  @State showDaily: boolean = false
  @State showNews: boolean = false
  @State showResearch: boolean = false
  @State showReminderForm: boolean = false
  @State showReminderSettings: boolean = false
  @State reminderMatch: MatchItem = new MatchItem()
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @StorageLink('detailStack') detailStack: string = ''
  @StorageLink('themeColorMode') themeColorMode: string = 'system'
  @StorageLink('themeRevision') @Watch('onThemeRevisionChange') themeRevision: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '球队研判'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  onThemeRevisionChange(): void {
    this.bumpContentRefresh()
  }

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
    this.detailRefresh += 1
  }

  private pageBg(): string {
    if (this.themeRevision < 0) {
      return Theme.colors().surfacePage
    }
    return Theme.colors().surfacePage
  }

  private overlayOpen(): boolean {
    return this.showMessages || this.showFollow || this.showStandings ||
      this.showCalendar || this.showCompare || this.showMyActivity ||
      this.showDaily || this.showNews || this.showResearch ||
      this.showReminderSettings || this.showReminderForm || DetailNav.isOpen() ||
      this.detailStack.length > 0
  }

  private syncTabBarHidden(): void {
    AppStorage.setOrCreate('tabBarHidden', this.overlayOpen())
  }

  private closeSubPages(): void {
    this.showMessages = false
    this.showFollow = false
    this.showStandings = false
    this.showCalendar = false
    this.showCompare = false
    this.showMyActivity = false
    this.showDaily = false
    this.showNews = false
    this.showResearch = false
    this.showReminderSettings = false
    this.showReminderForm = false
    if (DetailNav.isOpen()) {
      DetailNav.reset()
    }
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private requireAuth(): void {
    this.closeSubPages()
    this.onRequireAuth()
  }

  private openReminderForm(match: MatchItem): void {
    this.reminderMatch = match
    this.showReminderForm = true
    this.syncTabBarHidden()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            refreshToken: this.contentRefresh,
            onOpenMessages: (): void => {
              this.showMessages = true
              this.syncTabBarHidden()
            },
            onOpenFollow: (): void => {
              this.showFollow = true
              this.syncTabBarHidden()
            },
            onOpenStandings: (): void => {
              this.showStandings = true
              this.syncTabBarHidden()
            },
            onOpenSchedule: (): void => {
              this.current = 2
            },
            onOpenDiscover: (): void => {
              this.current = 1
            },
            onOpenCompare: (): void => {
              this.showCompare = true
              this.syncTabBarHidden()
            },
            onOpenCalendar: (): void => {
              this.showCalendar = true
              this.syncTabBarHidden()
            },
            onOpenActivity: (): void => {
              this.showMyActivity = true
              this.syncTabBarHidden()
            },
            onOpenDaily: (): void => {
              this.showDaily = true
              this.syncTabBarHidden()
            },
            onOpenNews: (): void => {
              this.showNews = true
              this.syncTabBarHidden()
            },
            onOpenResearch: (): void => {
              this.showResearch = true
              this.syncTabBarHidden()
            }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          DiscoverPage({
            refreshToken: this.contentRefresh,
            onOpenCompare: (): void => {
              this.showCompare = true
              this.syncTabBarHidden()
            },
            onOpenCalendar: (): void => {
              this.showCalendar = true
              this.syncTabBarHidden()
            },
            onOpenStandings: (): void => {
              this.showStandings = true
              this.syncTabBarHidden()
            },
            onOpenActivity: (): void => {
              this.showMyActivity = true
              this.syncTabBarHidden()
            },
            onOpenDaily: (): void => {
              this.showDaily = true
              this.syncTabBarHidden()
            },
            onOpenNews: (): void => {
              this.showNews = true
              this.syncTabBarHidden()
            },
            onOpenResearch: (): void => {
              this.showResearch = true
              this.syncTabBarHidden()
            },
            onOpenFollow: (): void => {
              this.showFollow = true
              this.syncTabBarHidden()
            }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          SchedulePage({
            refreshToken: this.contentRefresh
          }).layoutWeight(1)
        } else if (this.current === 3) {
          TeamsPage({
            refreshToken: this.contentRefresh
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
            onOpenMessages: (): void => {
              this.showMessages = true
              this.syncTabBarHidden()
            },
            onOpenReminderSettings: (): void => {
              this.showReminderSettings = true
              this.syncTabBarHidden()
            },
            onOpenFollow: (): void => {
              this.showFollow = true
              this.syncTabBarHidden()
            },
            onOpenStandings: (): void => {
              this.showStandings = true
              this.syncTabBarHidden()
            },
            onOpenCalendar: (): void => {
              this.showCalendar = true
              this.syncTabBarHidden()
            },
            onOpenCompare: (): void => {
              this.showCompare = true
              this.syncTabBarHidden()
            },
            onOpenActivity: (): void => {
              this.showMyActivity = true
              this.syncTabBarHidden()
            },
            onOpenDaily: (): void => {
              this.showDaily = true
              this.syncTabBarHidden()
            },
            onOpenNews: (): void => {
              this.showNews = true
              this.syncTabBarHidden()
            },
            onOpenResearch: (): void => {
              this.showResearch = true
              this.syncTabBarHidden()
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
          .shadow({ radius: 16, color: 'rgba(15,23,42,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showMessages) {
        MessagesPage({
          onClose: (): void => {
            this.showMessages = false
            this.syncTabBarHidden()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showFollow) {
        FollowPage({
          refreshToken: this.contentRefresh,
          onClose: (): void => {
            this.showFollow = false
            this.syncTabBarHidden()
          },
          onRequireAuth: (): void => { this.requireAuth() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showStandings) {
        StandingsPage({
          refreshToken: this.contentRefresh,
          onClose: (): void => {
            this.showStandings = false
            this.syncTabBarHidden()
          },
          onOpenTeam: (title: string): void => {
            void this.openTeamByTitle(title)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showCalendar) {
        CalendarPage({
          refreshToken: this.contentRefresh,
          onClose: (): void => {
            this.showCalendar = false
            this.syncTabBarHidden()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showCompare) {
        ComparePage({
          refreshToken: this.contentRefresh,
          showClose: true,
          onClose: (): void => {
            this.showCompare = false
            this.syncTabBarHidden()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showMyActivity) {
        MyActivityPage({
          refreshToken: this.contentRefresh,
          onClose: (): void => {
            this.showMyActivity = false
            this.syncTabBarHidden()
          },
          onRequireAuth: (): void => { this.requireAuth() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showDaily) {
        DailyObservePage({
          refreshToken: this.contentRefresh,
          onClose: (): void => {
            this.showDaily = false
            this.syncTabBarHidden()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showNews) {
        NewsDigestPage({
          refreshToken: this.contentRefresh,
          onClose: (): void => {
            this.showNews = false
            this.syncTabBarHidden()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showResearch) {
        ResearchFolderPage({
          refreshToken: this.contentRefresh,
          onClose: (): void => {
            this.showResearch = false
            this.syncTabBarHidden()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.detailRoute.length > 0 && DetailNav.hasKind('league')) {
        LeagueDetailPane({
          itemId: DetailNav.idForKind('league'),
          refreshToken: this.detailRefresh
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      }

      if (this.detailRoute.length > 0 && DetailNav.hasKind('team')) {
        TeamDetailPane({
          itemId: DetailNav.idForKind('team'),
          refreshToken: this.detailRefresh,
          onRequireAuth: (): void => { this.requireAuth() },
          onOpenReminder: (match: MatchItem): void => { this.openReminderForm(match) },
          onChanged: (): void => { this.bumpContentRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(21)
      }

      if (this.detailRoute.length > 0 && DetailNav.hasKind('match')) {
        MatchDetailPane({
          itemId: DetailNav.idForKind('match'),
          refreshToken: this.detailRefresh,
          onRequireAuth: (): void => { this.requireAuth() },
          onOpenReminder: (match: MatchItem): void => { this.openReminderForm(match) },
          onChanged: (): void => { this.bumpContentRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(22)
      }

      if (this.showReminderSettings) {
        ReminderSettingsPage({
          onClose: (): void => {
            this.showReminderSettings = false
            this.syncTabBarHidden()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showReminderForm) {
        ReminderFormOverlay({
          match: this.reminderMatch,
          onClose: (): void => {
            this.showReminderForm = false
            this.syncTabBarHidden()
          },
          onSaved: (): void => { this.bumpContentRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(24)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.pageBg())
  }

  private async openTeamByTitle(title: string): Promise<void> {
    const team = await SportsBizService.findTeamByTitle(title)
    if (team !== undefined) {
      DetailNav.openTeam(team.id)
    }
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
      if (DetailNav.isOpen()) {
        DetailNav.reset()
      }
      this.showMessages = false
      this.showFollow = false
      this.showStandings = false
      this.showCalendar = false
      this.showCompare = false
      this.showMyActivity = false
      this.showReminderSettings = false
      this.showReminderForm = false
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
