import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { JournalPage } from './JournalPage'
import { AlbumPage } from './AlbumPage'
import { ReviewPage } from './ReviewPage'
import { MinePage } from './MinePage'
import { FavoritesPage } from './FavoritesPage'
import { LifeCalendarPage } from './LifeCalendarPage'
import { MoodTrackPage } from './MoodTrackPage'
import { HabitCheckinPage } from './HabitCheckinPage'
import { LifeListPage } from './LifeListPage'
import { LifeInsightPage } from './LifeInsightPage'
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
    t1.name = 'book'
    t1.label = '记录'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'photo'
    t2.label = '相册'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'chart'
    t3.label = '回顾'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

/** 5 Tab：首页 | 记录 | 相册 | 回顾 | 我的；详情 Overlay 顶层 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailRefresh: number = 0
  @State contentRefresh: number = 0
  @State journalCreateTrigger: number = 0
  @State albumCreateTrigger: number = 0
  @State favoritesRefresh: number = 0
  @State showFavorites: boolean = false
  @State showCalendar: boolean = false
  @State showMood: boolean = false
  @State showHabit: boolean = false
  @State showList: boolean = false
  @State showInsight: boolean = false
  @State journalTemplateKey: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @Prop company: string = '魏文波'
  @Prop appName: string = '生活札记'
  @Prop tagline: string = '一款记录生活、收藏美好瞬间的智慧生活应用，日系手账美学与数字整理并存'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
  }

  private openTool(name: string): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    this.showCalendar = name === 'calendar'
    this.showMood = name === 'mood'
    this.showHabit = name === 'habit'
    this.showList = name === 'list'
    this.showInsight = name === 'insight'
  }

  private closeTools(): void {
    this.showCalendar = false
    this.showMood = false
    this.showHabit = false
    this.showList = false
    this.showInsight = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.bumpContentRefresh()
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
              this.journalTemplateKey = ''
              this.current = 1
              this.journalCreateTrigger += 1
            },
            onRequireAuth: (): void => this.onRequireAuth(),
            onPickTemplate: (key: string): void => {
              this.journalTemplateKey = key
              this.current = 1
              this.journalCreateTrigger += 1
            },
            onOpenTool: (name: string): void => { this.openTool(name) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          JournalPage({
            createTrigger: this.journalCreateTrigger,
            templateKey: this.journalTemplateKey,
            onRequireAuth: (): void => this.onRequireAuth(),
            onDiaryCreated: (): void => { this.bumpContentRefresh() }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          AlbumPage({
            createTrigger: this.albumCreateTrigger,
            onRequireAuth: (): void => this.onRequireAuth(),
            onAlbumCreated: (): void => {
              this.bumpContentRefresh()
            }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          ReviewPage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onOpenTool: (name: string): void => { this.openTool(name) }
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
            onOpenTool: (name: string): void => { this.openTool(name) }
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
          .shadow({ radius: 16, color: 'rgba(92,107,115,0.06)', offsetY: -4, offsetX: 0 })
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

      if (this.showList) {
        LifeListPage({
          onClose: (): void => { this.closeTools() },
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showInsight) {
        LifeInsightPage({
          onClose: (): void => { this.closeTools() },
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showHabit) {
        HabitCheckinPage({
          onClose: (): void => { this.closeTools() },
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showMood) {
        MoodTrackPage({
          onClose: (): void => { this.closeTools() },
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showCalendar) {
        LifeCalendarPage({
          onClose: (): void => { this.closeTools() },
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
        onCreateAlbum: (): void => {
          this.current = 2
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
            Theme.colors().brandDeep : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().surfaceSubtle : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandDeep : Theme.colors().textSecondary)
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
      if (t.index === 3) {
        this.bumpContentRefresh()
      }
    })
  }
}
