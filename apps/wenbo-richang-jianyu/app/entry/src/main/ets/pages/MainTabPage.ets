import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ExplorePage } from './ExplorePage'
import { PlanTabPage } from './PlanTabPage'
import { JournalPage } from './JournalPage'
import { AlbumPage } from './AlbumPage'
import { GrowthPage } from './GrowthPage'
import { MinePage } from './MinePage'
import { FavoritesPage } from './FavoritesPage'
import { FeaturedDetailPane } from '../components/detail/FeaturedDetailPane'
import { DiaryDetailPane } from '../components/detail/DiaryDetailPane'
import { AlbumDetailPane } from '../components/detail/AlbumDetailPane'
import { LifeHubHost } from './LifeHubHost'
import { MessagesPage } from './MessagesPage'
import { ProductGuideOverlay } from '../components/life/ProductGuideOverlay'
import { AuthService } from '../services/AuthService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { LifeHubNav } from '../services/LifeHubNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '笺台'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'ai'
    t1.label = '灵感'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'check'
    t2.label = '计划'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'book'
    t3.label = '创作'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'chart'
    t4.label = '成长'
    tabs.push(t4)
    const t5 = new TabItem()
    t5.index = 5
    t5.name = 'user'
    t5.label = '我的'
    tabs.push(t5)
    return tabs
  }
}

/** 6 Tab：笺台 | 灵感 | 计划 | 记录 | 成长 | 我的 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State contentRefresh: number = 0
  @State journalCreateTrigger: number = 0
  @State albumCreateTrigger: number = 0
  @State favoritesRefresh: number = 0
  @State showFavorites: boolean = false
  @State showAlbum: boolean = false
  @State showMessages: boolean = false
  @State messagesRefresh: number = 0
  @StorageLink('showProductGuide') showProductGuide: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @StorageLink('detailToken') detailToken: number = 0
  @StorageLink('lifeHubRoute') lifeHubRoute: string = ''
  @StorageLink('pendingTab') @Watch('onPendingTab') pendingTab: number = -1
  @StorageLink('pendingWriteDiary') @Watch('onPendingWrite') pendingWriteDiary: number = 0
  @StorageLink('pendingOpenFavorites') @Watch('onPendingFavorites') pendingOpenFavorites: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '日常笺语'
  @Prop tagline: string = '记录、计划、打卡与成长回顾一体的数字生活笺台'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
  }

  onPendingTab(): void {
    if (this.pendingTab >= 0 && this.pendingTab <= 5) {
      const tab = this.pendingTab
      this.current = tab
      AppStorage.setOrCreate('pendingTab', -1)
      if (tab === 0 || tab === 1 || tab === 2 || tab === 4) {
        this.bumpContentRefresh()
      }
    }
  }

  onPendingWrite(): void {
    if (this.pendingWriteDiary > 0) {
      this.current = 3
      this.journalCreateTrigger += 1
      AppStorage.setOrCreate('pendingWriteDiary', 0)
    }
  }

  onPendingFavorites(): void {
    if (this.pendingOpenFavorites > 0) {
      this.showFavorites = true
      AppStorage.setOrCreate('tabBarHidden', true)
      this.favoritesRefresh += 1
      AppStorage.setOrCreate('pendingOpenFavorites', 0)
    }
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
            onWriteToday: (): void => {
              this.current = 3
              this.journalCreateTrigger += 1
            },
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          ExplorePage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 2) {
          PlanTabPage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 3) {
          JournalPage({
            createTrigger: this.journalCreateTrigger,
            onRequireAuth: (): void => this.onRequireAuth(),
            onDiaryCreated: (): void => { this.bumpContentRefresh() }
          }).layoutWeight(1)
        } else if (this.current === 4) {
          GrowthPage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth()
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
              if (index === 0 || index === 1 || index === 2 || index === 4) {
                this.bumpContentRefresh()
              }
            },
            onOpenFavorites: (): void => {
              this.showFavorites = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.favoritesRefresh += 1
            },
            onOpenAlbum: (): void => {
              this.showAlbum = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenMessages: (): void => {
              this.showMessages = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.messagesRefresh += 1
            },
            onOpenLifeHub: (): void => { LifeHubNav.open('menu', false) }
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
          .shadow({ radius: 16, color: 'rgba(166,123,91,0.08)', offsetY: -4, offsetX: 0 })
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

      if (this.showAlbum) {
        AlbumPage({
          asOverlay: true,
          createTrigger: this.albumCreateTrigger,
          onRequireAuth: (): void => this.onRequireAuth(),
          onAlbumCreated: (): void => { this.bumpContentRefresh() },
          onClose: (): void => {
            this.showAlbum = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showMessages) {
        MessagesPage({
          asOverlay: true,
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

      if (this.showProductGuide) {
        ProductGuideOverlay()
      }

      if (this.lifeHubRoute.length > 0) {
        LifeHubHost({
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
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
        refreshToken: this.detailToken,
        onRequireAuth: (): void => this.onRequireAuth()
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (JournalDetailNav.parseKind() === 'diary') {
      DiaryDetailPane({
        itemId: JournalDetailNav.parseId(),
        refreshToken: this.detailToken,
        onRequireAuth: (): void => this.onRequireAuth()
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (JournalDetailNav.parseKind() === 'album') {
      AlbumDetailPane({
        itemId: JournalDetailNav.parseId(),
        refreshToken: this.detailToken,
        onRequireAuth: (): void => this.onRequireAuth(),
        onCreateAlbum: (): void => {
          this.showAlbum = true
          AppStorage.setOrCreate('tabBarHidden', true)
          this.albumCreateTrigger += 1
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
      if (LifeHubNav.isOpen()) {
        LifeHubNav.close()
      }
      this.showFavorites = false
      this.showAlbum = false
      this.showMessages = false
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      if (t.index === 0 || t.index === 1 || t.index === 2 || t.index === 4) {
        this.bumpContentRefresh()
      }
    })
  }
}
