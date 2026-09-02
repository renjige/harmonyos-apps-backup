import { Theme } from '../components/design-system/Theme'
import { ExplorePage } from './ExplorePage'
import { PlanPage } from './PlanPage'
import { JournalHubPage } from './JournalHubPage'
import { GrowthPage } from './GrowthPage'
import { HomePage } from './HomePage'
import { FavoritesPage } from './FavoritesPage'
import { FeaturedDetailPane } from '../components/detail/FeaturedDetailPane'
import { DiaryDetailPane } from '../components/detail/DiaryDetailPane'
import { AlbumDetailPane } from '../components/detail/AlbumDetailPane'
import { AuthService } from '../services/AuthService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'

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
    t1.label = '探索'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'calendar'
    t2.label = '计划'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'book'
    t3.label = '札记'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'chart'
    t4.label = '成长'
    tabs.push(t4)
    return tabs
  }
}

/** 5 Tab：首页 | 探索 | 计划 | 札记 | 成长 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailRefresh: number = 0
  @State contentRefresh: number = 0
  @State journalCreateTrigger: number = 0
  @State albumCreateTrigger: number = 0
  @State planCreateTrigger: number = 0
  @State journalHubSegment: number = 0
  @State favoritesRefresh: number = 0
  @State showFavorites: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @Prop company: string = '魏文波'
  @Prop appName: string = '旅行札记'
  @Prop tagline: string = '出行计划、旅行日记、本机相册策展与成长回顾一体化的智慧旅行工作台'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
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
            onCreateJourney: (): void => {
              this.current = 3
              this.journalHubSegment = 0
              this.journalCreateTrigger += 1
            },
            onCreatePlan: (): void => {
              this.current = 2
              this.planCreateTrigger += 1
            },
            onOpenExplore: (): void => { this.current = 1 },
            onOpenGrowth: (): void => { this.current = 4 },
            onOpenPlan: (): void => { this.current = 2 }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          ExplorePage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => { this.onRequireAuth() }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          PlanPage({
            createTrigger: this.planCreateTrigger,
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => { this.onRequireAuth() },
            onDataChanged: (): void => { this.bumpContentRefresh() },
            onWriteDiary: (): void => {
              this.current = 3
              this.journalHubSegment = 0
              this.journalCreateTrigger += 1
            }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          JournalHubPage({
            journalCreateTrigger: this.journalCreateTrigger,
            albumCreateTrigger: this.albumCreateTrigger,
            segment: this.journalHubSegment,
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => { this.onRequireAuth() },
            onDiaryCreated: (): void => { this.bumpContentRefresh() },
            onAlbumCreated: (): void => { this.bumpContentRefresh() },
            onSegmentChange: (index: number): void => { this.journalHubSegment = index }
          }).layoutWeight(1)
        } else {
          GrowthPage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => { this.onRequireAuth() },
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
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
          .shadow({ radius: 16, color: 'rgba(26,58,82,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showFavorites) {
        FavoritesPage({
          refreshToken: this.favoritesRefresh,
          onRequireAuth: (): void => { this.onRequireAuth() },
          onClose: (): void => {
            this.showFavorites = false
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
        onRequireAuth: (): void => { this.onRequireAuth() }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (JournalDetailNav.parseKind() === 'diary') {
      DiaryDetailPane({
        itemId: JournalDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => { this.onRequireAuth() },
        onDataChanged: (): void => {
          this.detailRefresh += 1
          this.bumpContentRefresh()
        }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (JournalDetailNav.parseKind() === 'album') {
      AlbumDetailPane({
        itemId: JournalDetailNav.parseId(),
        onRequireAuth: (): void => { this.onRequireAuth() },
        onCreateAlbum: (): void => {
          this.current = 3
          this.journalHubSegment = 1
          this.albumCreateTrigger += 1
        },
        onDataChanged: (): void => {
          this.bumpContentRefresh()
        }
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
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
