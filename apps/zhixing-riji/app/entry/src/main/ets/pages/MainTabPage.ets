import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { JournalPage } from './JournalPage'
import { MapPage } from './MapPage'
import { MinePage } from './MinePage'
import { FavoritesPage } from './FavoritesPage'
import { OrganizePage } from './OrganizePage'
import { ReviewPage } from './ReviewPage'
import { FeaturedDetailPane } from '../components/detail/FeaturedDetailPane'
import { DiaryDetailPane } from '../components/detail/DiaryDetailPane'
import { AlbumDetailPane } from '../components/detail/AlbumDetailPane'
import { AuthService } from '../services/AuthService'
import { JournalDetailNav } from '../services/JournalDetailNav'

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
    t1.name = 'location'
    t1.label = '地图'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '时光'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)
    return tabs
  }
}

/** 4 Tab：首页 | 地图 | 时光 | 我的 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailRefresh: number = 0
  @State contentRefresh: number = 0
  @State journalCreateTrigger: number = 0
  @State showJournalOverlay: boolean = false
  @State favoritesRefresh: number = 0
  @State showFavorites: boolean = false
  @State showOrganize: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @Prop company: string = '智行科技'
  @Prop appName: string = '智行日记'
  @Prop tagline: string = '面向旅行爱好者的智慧旅行记录与回顾工具，地图轨迹可视化、智慧续写与时光回顾'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
  }

  private openJournalOverlay(): void {
    this.showJournalOverlay = true
    this.journalCreateTrigger += 1
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeJournalOverlay(): void {
    this.showJournalOverlay = false
    AppStorage.setOrCreate('tabBarHidden', false)
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
            onCreateJourney: (): void => { this.openJournalOverlay() }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          MapPage({
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 2) {
          ReviewPage({
            embeddedTab: true,
            onRequireAuth: (): void => this.onRequireAuth(),
            onClose: (): void => {}
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => this.onOpenLogin(),
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
            onRequireAuth: (): void => this.onRequireAuth(),
            onSwitchTab: (index: number): void => {
              if (JournalDetailNav.isOpen()) {
                JournalDetailNav.close()
              }
              this.current = index
            },
            onOpenFavorites: (): void => {
              this.showFavorites = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.favoritesRefresh += 1
            },
            onOpenOrganize: (): void => {
              this.showOrganize = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenReview: (): void => {
              this.current = 2
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
          .padding({ bottom: 28 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(44,62,107,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showJournalOverlay) {
        JournalPage({
          overlayMode: true,
          createTrigger: this.journalCreateTrigger,
          onRequireAuth: (): void => this.onRequireAuth(),
          onCloseOverlay: (): void => { this.closeJournalOverlay() },
          onDiaryCreated: (): void => {
            this.bumpContentRefresh()
            this.closeJournalOverlay()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

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

      if (this.detailRoute.length > 0) {
        this.DetailOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailOverlay() {
    if (JournalDetailNav.parseKind() === 'featured') {
      FeaturedDetailPane({
        itemId: JournalDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth()
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (JournalDetailNav.parseKind() === 'diary') {
      DiaryDetailPane({
        itemId: JournalDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth()
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (JournalDetailNav.parseKind() === 'album') {
      AlbumDetailPane({
        itemId: JournalDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth(),
        onCreateAlbum: (): void => {}
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
      if (JournalDetailNav.isOpen()) {
        JournalDetailNav.close()
      }
      this.showFavorites = false
      this.showOrganize = false
      this.showJournalOverlay = false
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
