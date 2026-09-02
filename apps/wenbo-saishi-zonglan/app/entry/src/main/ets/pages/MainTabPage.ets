import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { EventsPage } from './EventsPage'
import { FollowPage } from './FollowPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { CalendarPage } from './CalendarPage'
import { StandingsPage } from './StandingsPage'
import { MatchDetailPane } from '../components/detail/MatchDetailPane'
import { TeamDetailPane } from '../components/detail/TeamDetailPane'
import { LeagueDetailPane } from '../components/detail/LeagueDetailPane'
import { ReminderFormOverlay } from '../components/reminder/ReminderFormOverlay'
import { AuthService } from '../services/AuthService'
import { DetailNav } from '../services/DetailNav'
import { MatchItem } from '../models/MatchModels'
import { ReminderSettingsPage } from './ReminderSettingsPage'
import { SearchPage } from './SearchPage'
import { GrowthHubPage } from './GrowthHubPage'
import { ViewingPlanEditorOverlay } from '../components/viewing/ViewingPlanEditorOverlay'
import { WatchNoteEditorOverlay } from '../components/viewing/WatchNoteEditorOverlay'

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
    t1.name = 'biz'
    t1.label = '赛事'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'heart'
    t2.label = '观赛'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)
    return tabs
  }
}

/** 4 Tab：首页 | 赛事 | 关注 | 我的；详情 Overlay 顶层 */
@Component
export struct MainTabPage {
  @State current: number = 0
  @State detailRefresh: number = 0
  @State contentRefresh: number = 0
  @State showMessages: boolean = false
  @State showCalendar: boolean = false
  @State showStandings: boolean = false
  @State standingsLeague: string = ''
  @State showReminderForm: boolean = false
  @State showReminderSettings: boolean = false
  @State showSearch: boolean = false
  @State showGrowthHub: boolean = false
  @State showPlanEditor: boolean = false
  @State showNoteEditor: boolean = false
  @State noteMatch: MatchItem = new MatchItem()
  @State planSeedMatch: MatchItem = new MatchItem()
  @State reminderMatch: MatchItem = new MatchItem()
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @StorageLink('themeColorMode') themeColorMode: string = 'light'
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '赛事纵览'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
    this.detailRefresh += 1
  }

  private isDarkTheme(): boolean {
    return this.themeColorMode === 'dark'
  }

  private closeSubPages(): void {
    this.showMessages = false
    this.showCalendar = false
    this.showStandings = false
    this.showReminderSettings = false
    this.showReminderForm = false
    this.showSearch = false
    this.showGrowthHub = false
    this.showPlanEditor = false
    this.showNoteEditor = false
    if (DetailNav.isOpen()) {
      DetailNav.close()
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
    AppStorage.setOrCreate('tabBarHidden', true)
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
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenCalendar: (): void => {
              this.showCalendar = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenStandings: (): void => {
              this.standingsLeague = ''
              this.showStandings = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenFollow: (): void => {
              this.current = 2
            },
            onOpenSearch: (): void => {
              this.showSearch = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenGrowth: (): void => {
              this.showGrowthHub = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenPlanEditor: (): void => {
              this.planSeedMatch = new MatchItem()
              this.showPlanEditor = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          EventsPage({
            refreshToken: this.contentRefresh
          }).layoutWeight(1)
        } else if (this.current === 2) {
          FollowPage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => { this.requireAuth() }
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
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenCalendar: (): void => {
              this.showCalendar = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenReminderSettings: (): void => {
              this.showReminderSettings = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenGrowth: (): void => {
              this.showGrowthHub = true
              AppStorage.setOrCreate('tabBarHidden', true)
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
          .backgroundColor(Theme.palette(this.isDarkTheme()).surfaceCard)
          .border({ width: { top: 1 }, color: Theme.palette(this.isDarkTheme()).strokeHairline })
          .shadow({ radius: 16, color: 'rgba(15,23,42,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showMessages) {
        MessagesPage({
          onClose: (): void => {
            this.showMessages = false
            AppStorage.setOrCreate('tabBarHidden', DetailNav.isOpen() || this.showReminderForm || this.showCalendar || this.showStandings)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showCalendar) {
        CalendarPage({
          refreshToken: this.contentRefresh,
          showBack: true,
          onClose: (): void => {
            this.showCalendar = false
            AppStorage.setOrCreate('tabBarHidden',
              DetailNav.isOpen() || this.showReminderForm || this.showMessages || this.showStandings)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showStandings) {
        StandingsPage({
          refreshToken: this.contentRefresh,
          initialLeague: this.standingsLeague,
          showBack: true,
          onClose: (): void => {
            this.showStandings = false
            this.standingsLeague = ''
            AppStorage.setOrCreate('tabBarHidden',
              DetailNav.isOpen() || this.showReminderForm || this.showMessages || this.showCalendar)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(25)
      }

      if (this.detailRoute.length > 0) {
        if (DetailNav.parseKind() === 'team') {
          TeamDetailPane({
            itemId: DetailNav.parseId(),
            refreshToken: this.detailRefresh,
            onRequireAuth: (): void => { this.requireAuth() },
            onChanged: (): void => { this.bumpContentRefresh() }
          })
            .width('100%')
            .height('100%')
            .zIndex(20)
        } else if (DetailNav.parseKind() === 'league') {
          LeagueDetailPane({
            itemId: DetailNav.parseId(),
            refreshToken: this.detailRefresh,
            onRequireAuth: (): void => { this.requireAuth() },
            onOpenStandings: (leagueName: string): void => {
              this.standingsLeague = leagueName
              this.showStandings = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onChanged: (): void => { this.bumpContentRefresh() }
          })
            .width('100%')
            .height('100%')
            .zIndex(20)
        } else {
          MatchDetailPane({
            itemId: DetailNav.parseId(),
            refreshToken: this.detailRefresh,
            onRequireAuth: (): void => { this.requireAuth() },
            onOpenReminder: (match: MatchItem): void => { this.openReminderForm(match) },
            onOpenNote: (match: MatchItem): void => {
              this.noteMatch = match
              this.showNoteEditor = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenPlan: (match: MatchItem): void => {
              this.planSeedMatch = match
              this.showPlanEditor = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onChanged: (): void => { this.bumpContentRefresh() }
          })
            .width('100%')
            .height('100%')
            .zIndex(20)
        }
      }

      if (this.showReminderSettings) {
        ReminderSettingsPage({
          onClose: (): void => {
            this.showReminderSettings = false
            AppStorage.setOrCreate('tabBarHidden', DetailNav.isOpen() || this.showReminderForm || this.showMessages || this.showCalendar)
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
            AppStorage.setOrCreate('tabBarHidden', DetailNav.isOpen())
          },
          onSaved: (): void => { this.bumpContentRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(22)
      }

      if (this.showSearch) {
        SearchPage({
          onClose: (): void => {
            this.showSearch = false
            AppStorage.setOrCreate('tabBarHidden', DetailNav.isOpen() || this.showGrowthHub)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showGrowthHub) {
        GrowthHubPage({
          onClose: (): void => {
            this.showGrowthHub = false
            AppStorage.setOrCreate('tabBarHidden', DetailNav.isOpen() || this.showSearch)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showPlanEditor) {
        ViewingPlanEditorOverlay({
          seedMatchId: this.planSeedMatch.id,
          seedMatchTitle: this.planSeedMatch.title,
          seedMatchSport: this.planSeedMatch.sport,
          seedMatchLeague: this.planSeedMatch.leagueName,
          seedMatchDate: this.planSeedMatch.dateIso(),
          onClose: (): void => {
            this.showPlanEditor = false
            this.planSeedMatch = new MatchItem()
            AppStorage.setOrCreate('tabBarHidden', DetailNav.isOpen())
          },
          onSaved: (): void => { this.bumpContentRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(23)
      }

      if (this.showNoteEditor) {
        WatchNoteEditorOverlay({
          match: this.noteMatch,
          onClose: (): void => {
            this.showNoteEditor = false
            AppStorage.setOrCreate('tabBarHidden', DetailNav.isOpen())
          },
          onSaved: (): void => { this.bumpContentRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(23)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.isDarkTheme()).surfacePage)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.palette(this.isDarkTheme()).brandPrimary :
            Theme.palette(this.isDarkTheme()).textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.palette(this.isDarkTheme()).brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.palette(this.isDarkTheme()).brandPrimary :
          Theme.palette(this.isDarkTheme()).textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick((): void => {
      if (DetailNav.isOpen()) {
        DetailNav.close()
      }
      this.showMessages = false
      this.showCalendar = false
      this.showStandings = false
      this.showReminderSettings = false
      this.showReminderForm = false
      this.showSearch = false
      this.showGrowthHub = false
      this.showPlanEditor = false
      this.showNoteEditor = false
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
