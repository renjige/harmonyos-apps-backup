import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { DiscoverPage } from './DiscoverPage'
import { TimelinePage } from './TimelinePage'
import { MinePage } from './MinePage'
import { DiagnosePage } from './DiagnosePage'
import { BookingsPage } from './BookingsPage'
import { FavoritesPage } from './FavoritesPage'
import { MessagesPage } from './MessagesPage'
import { VenueDetailPane } from '../components/detail/VenueDetailPane'
import { PromotionDetailPane } from '../components/detail/PromotionDetailPane'
import { CaseDetailPane } from '../components/detail/CaseDetailPane'
import { BookingSheet } from '../components/court/BookingSheet'
import { FanCalendarPage } from './FanCalendarPage'
import { FanTimelinePage } from './FanTimelinePage'
import { FanListPage } from './FanListPage'
import { FanEditorPage } from './FanEditorPage'
import { FanGuideWizardPage } from './FanGuideWizardPage'
import { FanDashboardPage } from './FanDashboardPage'
import { FanDetailPane } from '../components/detail/FanDetailPane'
import { CourtDetailNav } from '../services/CourtDetailNav'
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
    t1.name = 'search'
    t1.label = '发现'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '拾光'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)
    return tabs
  }
}

/** 球场拾光：首页 / 发现 / 拾光 / 我的 + 详情 Overlay 栈 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 2
  @State dataRefresh: number = 0
  @State discoverCategory: string = '全部'
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('courtVenueId') courtVenueId: string = ''
  @StorageLink('courtPromotionId') courtPromotionId: string = ''
  @StorageLink('courtBookingVenueId') courtBookingVenueId: string = ''
  @StorageLink('courtCaseId') courtCaseId: string = ''
  @StorageLink('showCourtDiagnose') showCourtDiagnose: boolean = false
  @StorageLink('showCourtBookings') showCourtBookings: boolean = false
  @StorageLink('showCourtFavorites') showCourtFavorites: boolean = false
  @StorageLink('showCourtMessages') showCourtMessages: boolean = false
  @StorageLink('showCourtFanList') showCourtFanList: boolean = false
  @StorageLink('showCourtFanEditor') showCourtFanEditor: boolean = false
  @StorageLink('showCourtFanCalendar') showCourtFanCalendar: boolean = false
  @StorageLink('showCourtFanTimeline') showCourtFanTimeline: boolean = false
  @StorageLink('showCourtFanWizard') showCourtFanWizard: boolean = false
  @StorageLink('showCourtFanDashboard') showCourtFanDashboard: boolean = false
  @StorageLink('courtFanId') courtFanId: string = ''
  @Prop company: string = '拾光运动科技'
  @Prop appName: string = '球场拾光'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpRefresh(): void {
    this.dataRefresh += 1
  }

  private handleBookVenue(venueId: string, slotTime: string): void {
    if (!AuthService.requireAuth('submit')) {
      this.onRequireAuth()
      return
    }
    CourtDetailNav.openBooking(venueId, slotTime)
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            tagline: this.tagline,
            refreshToken: this.dataRefresh,
            onGoDiscover: (): void => {
              this.current = 1
            },
            onGoMemory: (): void => {
              this.current = 2
            }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          DiscoverPage({
            refreshToken: this.dataRefresh
          }).layoutWeight(1)
        } else if (this.current === 2) {
          TimelinePage({
            refreshToken: this.dataRefresh,
            onRequireAuth: (): void => {
              this.onRequireAuth()
            }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.dataRefresh,
            onOpenLogin: (): void => {
              this.onOpenLogin()
            },
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
            onOpenBookings: (): void => {
              CourtDetailNav.openBookings()
            },
            onOpenFavorites: (): void => {
              CourtDetailNav.openFavorites()
            },
            onOpenMessages: (): void => {
              CourtDetailNav.openMessages()
            },
            onGoMemory: (): void => {
              CourtDetailNav.close()
              this.current = 2
            },
            onDataChanged: (): void => {
              this.bumpRefresh()
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
          .backgroundColor(Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(26,42,58,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.courtVenueId.length > 0) {
        VenueDetailPane({
          venueId: this.courtVenueId,
          onBook: (slotTime: string): void => {
            this.handleBookVenue(this.courtVenueId, slotTime)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.courtPromotionId.length > 0) {
        PromotionDetailPane({
          promotionId: this.courtPromotionId,
          onBrowseVenues: (): void => {
            CourtDetailNav.close()
            this.current = 1
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.courtCaseId.length > 0) {
        CaseDetailPane({
          caseId: this.courtCaseId,
          onBookSame: (category: string): void => {
            CourtDetailNav.close()
            this.discoverCategory = category
            this.current = 1
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.courtBookingVenueId.length > 0) {
        BookingSheet({
          venueId: this.courtBookingVenueId,
          onSuccess: (): void => {
            this.bumpRefresh()
          },
          onRequireAuth: (): void => {
            this.onRequireAuth()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(55)
      }

      if (this.showCourtDiagnose) {
        DiagnosePage({
          onGoDiscover: (category: string): void => {
            this.discoverCategory = category
            this.current = 1
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(45)
      }

      if (this.showCourtBookings) {
        BookingsPage({
          refreshToken: this.dataRefresh,
          onRequireAuth: (): void => {
            this.onRequireAuth()
          },
          onChanged: (): void => {
            this.bumpRefresh()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(48)
      }

      if (this.showCourtFavorites) {
        FavoritesPage({
          refreshToken: this.dataRefresh
        })
          .width('100%')
          .height('100%')
          .zIndex(48)
      }

      if (this.showCourtMessages) {
        Column() {
          MessagesPage().layoutWeight(1)
          Row() {
            Text('返回')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().brandPrimary)
              .padding(Theme.space.pageX)
              .onClick(() => {
                CourtDetailNav.close()
              })
          }
          .width('100%')
        }
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().surfacePage)
          .zIndex(48)
      }

      if (this.showCourtFanTimeline) {
        FanTimelinePage()
          .width('100%')
          .height('100%')
          .zIndex(48)
      }

      if (this.showCourtFanWizard) {
        FanGuideWizardPage()
          .width('100%')
          .height('100%')
          .zIndex(49)
      }

      if (this.showCourtFanDashboard) {
        FanDashboardPage()
          .width('100%')
          .height('100%')
          .zIndex(49)
      }

      if (this.showCourtFanCalendar) {
        FanCalendarPage()
          .width('100%')
          .height('100%')
          .zIndex(48)
      }

      if (this.showCourtFanList) {
        FanListPage({
          refreshToken: this.dataRefresh
        })
          .width('100%')
          .height('100%')
          .zIndex(48)
      }

      if (this.courtFanId.length > 0) {
        FanDetailPane({
          refreshToken: this.dataRefresh,
          onChanged: (): void => {
            this.bumpRefresh()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(52)
      }

      if (this.showCourtFanEditor) {
        FanEditorPage()
          .width('100%')
          .height('100%')
          .zIndex(56)
      }
    }
    .width('100%')
    .height('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandDeep : Theme.colors().textPrimary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().surfaceSubtle : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.caption)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandDeep : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      CourtDetailNav.close()
      this.current = t.index
    })
  }
}
