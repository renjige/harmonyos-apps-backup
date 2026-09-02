import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { RecordPage } from './RecordPage'
import { BoardPage } from './BoardPage'
import { PlanPage } from './PlanPage'
import { MinePage } from './MinePage'
import { FavoritesPage } from './FavoritesPage'
import { OrganizePage } from './OrganizePage'
import { AnnualReportPage } from './AnnualReportPage'
import { MessagesPage } from './MessagesPage'
import { HabitsPage } from './HabitsPage'
import { ReviewsPage } from './ReviewsPage'
import { RitualPage } from './RitualPage'
import { StuckWorkshopPage } from './StuckWorkshopPage'
import { ContrastPage } from './ContrastPage'
import { ThemeMonthPage } from './ThemeMonthPage'
import { AIAssistantPage } from './AIAssistantPage'
import { AchievementsPage } from './AchievementsPage'
import { GrowthToolsPage } from './GrowthToolsPage'
import { FeaturedDetailPane } from '../components/detail/FeaturedDetailPane'
import { RecordDetailPane } from '../components/detail/RecordDetailPane'
import { BoardDetailPane } from '../components/detail/BoardDetailPane'
import { PlanDetailPane } from '../components/detail/PlanDetailPane'
import { AuthService } from '../services/AuthService'
import { GrowthDetailNav } from '../services/GrowthDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '成长空间'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'book'
    t1.label = '成长记录'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'calendar'
    t2.label = '成长目标'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'chart'
    t3.label = '时间轴'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

/** 5 Tab：成长 | 记录 | 成果 | 计划 | 我的；详情 Overlay 顶层 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailRefresh: number = 0
  @State contentRefresh: number = 0
  @State recordCreateTrigger: number = 0
  @State boardCreateTrigger: number = 0
  @State planRefresh: number = 0
  @State favoritesRefresh: number = 0
  @State showFavorites: boolean = false
  @State showOrganize: boolean = false
  @State showAnnualReport: boolean = false
  @State showMessages: boolean = false
  @State showHabits: boolean = false
  @State showReviews: boolean = false
  @State showDiagnose: boolean = false
  @State showRitual: boolean = false
  @State showStuck: boolean = false
  @State showContrast: boolean = false
  @State showTheme: boolean = false
  @State showAchievements: boolean = false
  @State showGrowthTools: boolean = false
  @State annualRefresh: number = 0
  @State achievementsRefresh: number = 0
  @State messagesRefresh: number = 0
  @State habitsRefresh: number = 0
  @State reviewsRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') @Watch('onDetailRouteChange') detailRoute: string = ''
  @Prop company: string = '魏文波'
  @Prop appName: string = '成长手册'
  @Prop tagline: string = '一款记录个人成长过程、管理目标计划、保存成长成果的智慧成长应用，记录成长见证进步'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()
  private detailWasOpen: boolean = false

  aboutToAppear(): void {
    this.detailWasOpen = this.detailRoute.length > 0
  }

  onDetailRouteChange(): void {
    const open = this.detailRoute.length > 0
    if (this.detailWasOpen && !open) {
      this.bumpContentRefresh()
    }
    this.detailWasOpen = open
  }

  private hideOverlays(): void {
    this.showFavorites = false
    this.showOrganize = false
    this.showAnnualReport = false
    this.showMessages = false
    this.showHabits = false
    this.showReviews = false
    this.showDiagnose = false
    this.showRitual = false
    this.showStuck = false
    this.showContrast = false
    this.showTheme = false
    this.showAchievements = false
    this.showGrowthTools = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private openGrowthTools(): void {
    this.hideOverlays()
    this.showGrowthTools = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openAchievements(): void {
    this.hideOverlays()
    this.showAchievements = true
    AppStorage.setOrCreate('tabBarHidden', true)
    this.achievementsRefresh += 1
  }

  private openHabits(): void {
    this.hideOverlays()
    this.showHabits = true
    AppStorage.setOrCreate('tabBarHidden', true)
    this.habitsRefresh += 1
  }

  private openReviews(): void {
    this.hideOverlays()
    this.showReviews = true
    AppStorage.setOrCreate('tabBarHidden', true)
    this.reviewsRefresh += 1
  }

  private openDiagnose(): void {
    this.hideOverlays()
    this.showDiagnose = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private handleDiagnoseAction(category: string): void {
    this.showDiagnose = false
    if (category === '习惯打卡') {
      this.openHabits()
      return
    }
    if (category === '每周复盘') {
      this.openReviews()
      return
    }
    if (category === '成长目标') {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = 2
      return
    }
    AppStorage.setOrCreate('tabBarHidden', false)
    this.current = 1
    this.recordCreateTrigger += 1
  }

  private openRitual(): void {
    this.hideOverlays()
    this.showRitual = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openStuck(): void {
    this.hideOverlays()
    this.showStuck = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openContrast(): void {
    this.hideOverlays()
    this.showContrast = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openTheme(): void {
    this.hideOverlays()
    this.showTheme = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
    this.planRefresh += 1
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
            onWriteRecord: (): void => {
              this.current = 1
              this.recordCreateTrigger += 1
            },
            onSwitchTab: (index: number): void => {
              if (GrowthDetailNav.isOpen()) {
                GrowthDetailNav.close()
                this.bumpContentRefresh()
              }
              this.hideOverlays()
              this.current = index
            },
            onOpenAnnualReport: (): void => {
              this.hideOverlays()
              this.showAnnualReport = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.annualRefresh += 1
            },
            onOpenFavorites: (): void => {
              this.hideOverlays()
              this.showFavorites = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.favoritesRefresh += 1
            },
            onOpenOrganize: (): void => {
              this.hideOverlays()
              this.showOrganize = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenMessages: (): void => {
              this.hideOverlays()
              this.showMessages = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.messagesRefresh += 1
            },
            onOpenHabits: (): void => { this.openHabits() },
            onOpenReviews: (): void => { this.openReviews() },
            onOpenDiagnose: (): void => { this.openDiagnose() },
            onOpenRitual: (): void => { this.openRitual() },
            onOpenStuck: (): void => { this.openStuck() },
            onOpenContrast: (): void => { this.openContrast() },
            onOpenTheme: (): void => { this.openTheme() },
            onOpenTools: (): void => { this.openGrowthTools() },
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          RecordPage({
            createTrigger: this.recordCreateTrigger,
            onRequireAuth: (): void => this.onRequireAuth(),
            onRecordCreated: (): void => { this.bumpContentRefresh() }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          PlanPage({
            refreshToken: this.planRefresh,
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 3) {
          BoardPage({
            createTrigger: this.boardCreateTrigger,
            onRequireAuth: (): void => this.onRequireAuth(),
            onBoardCreated: (): void => { this.bumpContentRefresh() }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onOpenLogin: (): void => this.onOpenLogin(),
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
            onRequireAuth: (): void => this.onRequireAuth(),
            onSwitchTab: (index: number): void => {
              if (GrowthDetailNav.isOpen()) {
                GrowthDetailNav.close()
              }
              this.current = index
            },
            onOpenFavorites: (): void => {
              this.showFavorites = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.favoritesRefresh += 1
            },
            onOpenAnnualReport: (): void => {
              this.showAnnualReport = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.annualRefresh += 1
            },
            onOpenOrganize: (): void => {
              this.hideOverlays()
              this.showOrganize = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenHabits: (): void => { this.openHabits() },
            onOpenReviews: (): void => { this.openReviews() },
            onOpenDiagnose: (): void => { this.openDiagnose() },
            onOpenMessages: (): void => {
              this.hideOverlays()
              this.showMessages = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.messagesRefresh += 1
            },
            onOpenAchievements: (): void => { this.openAchievements() }
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
          .shadow({ radius: 16, color: 'rgba(27,42,65,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showFavorites) {
        FavoritesPage({
          refreshToken: this.favoritesRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => {
            this.showFavorites = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showAnnualReport) {
        AnnualReportPage({
          refreshToken: this.annualRefresh,
          onClose: (): void => {
            this.showAnnualReport = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showOrganize) {
        OrganizePage({
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => {
            this.showOrganize = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showMessages) {
        MessagesPage({
          refreshToken: this.messagesRefresh,
          onClose: (): void => {
            this.showMessages = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showHabits) {
        HabitsPage({
          refreshToken: this.habitsRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => {
            this.showHabits = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showReviews) {
        ReviewsPage({
          refreshToken: this.reviewsRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => {
            this.showReviews = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showDiagnose) {
        AIAssistantPage({
          onClose: (): void => {
            this.showDiagnose = false
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onBookFromAi: (category: string): void => { this.handleDiagnoseAction(category) }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showRitual) {
        RitualPage({
          onClose: (): void => {
            this.showRitual = false
            AppStorage.setOrCreate('tabBarHidden', false)
            this.bumpContentRefresh()
          },
          onRequireAuth: (): void => this.onRequireAuth(),
          onSaved: (): void => { this.bumpContentRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showStuck) {
        StuckWorkshopPage({
          onClose: (): void => {
            this.showStuck = false
            AppStorage.setOrCreate('tabBarHidden', false)
            this.bumpContentRefresh()
          },
          onRequireAuth: (): void => this.onRequireAuth(),
          onSaved: (): void => { this.bumpContentRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showContrast) {
        ContrastPage({
          onClose: (): void => {
            this.showContrast = false
            AppStorage.setOrCreate('tabBarHidden', false)
            this.bumpContentRefresh()
          },
          onRequireAuth: (): void => this.onRequireAuth(),
          onWriteRecord: (): void => {
            this.showContrast = false
            AppStorage.setOrCreate('tabBarHidden', false)
            this.current = 1
            this.recordCreateTrigger += 1
          },
          onSaved: (): void => { this.bumpContentRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showTheme) {
        ThemeMonthPage({
          onClose: (): void => {
            this.showTheme = false
            AppStorage.setOrCreate('tabBarHidden', false)
            this.bumpContentRefresh()
          },
          onRequireAuth: (): void => this.onRequireAuth(),
          onSaved: (): void => { this.bumpContentRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showGrowthTools) {
        GrowthToolsPage({
          onClose: (): void => {
            this.showGrowthTools = false
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onOpenRitual: (): void => { this.openRitual() },
          onOpenStuck: (): void => { this.openStuck() },
          onOpenContrast: (): void => { this.openContrast() },
          onOpenTheme: (): void => { this.openTheme() },
          onOpenDiagnose: (): void => { this.openDiagnose() },
          onOpenHabits: (): void => { this.openHabits() },
          onOpenReviews: (): void => { this.openReviews() },
          onOpenOrganize: (): void => {
            this.hideOverlays()
            this.showOrganize = true
            AppStorage.setOrCreate('tabBarHidden', true)
          },
          onOpenAnnualReport: (): void => {
            this.hideOverlays()
            this.showAnnualReport = true
            AppStorage.setOrCreate('tabBarHidden', true)
            this.annualRefresh += 1
          },
          onOpenFavorites: (): void => {
            this.hideOverlays()
            this.showFavorites = true
            AppStorage.setOrCreate('tabBarHidden', true)
            this.favoritesRefresh += 1
          },
          onOpenAchievements: (): void => { this.openAchievements() },
          onOpenMessages: (): void => {
            this.hideOverlays()
            this.showMessages = true
            AppStorage.setOrCreate('tabBarHidden', true)
            this.messagesRefresh += 1
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showAchievements) {
        AchievementsPage({
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => {
            this.showAchievements = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.detailRoute.length > 0) {
        this.DetailOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailOverlay() {
    if (GrowthDetailNav.parseKind() === 'featured') {
      FeaturedDetailPane({
        itemId: GrowthDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth()
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (GrowthDetailNav.parseKind() === 'inspiration') {
      RecordDetailPane({
        itemId: GrowthDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth(),
        onRecordChanged: (): void => { this.bumpContentRefresh() }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (GrowthDetailNav.parseKind() === 'board') {
      BoardDetailPane({
        itemId: GrowthDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth(),
        onCreateBoard: (): void => {
          this.current = 3
          this.boardCreateTrigger += 1
        }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (GrowthDetailNav.parseKind() === 'plan') {
      PlanDetailPane({
        itemId: GrowthDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth(),
        onPlanUpdated: (): void => { this.bumpContentRefresh() }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
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
    .onClick(() => {
      if (GrowthDetailNav.isOpen()) {
        GrowthDetailNav.close()
        this.bumpContentRefresh()
      }
      this.hideOverlays()
      this.current = t.index
    })
  }
}
