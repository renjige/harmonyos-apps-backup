import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { AlbumListPage } from './AlbumListPage'
import { GalleryPage } from './GalleryPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AIAssistantPage } from './AIAssistantPage'
import { AuthService } from '../services/AuthService'
import { KagNav } from '../services/KagNav'
import { KagBizService } from '../services/KagBizService'
import { ArtworkItem, AlbumItem, CatalogItem } from '../models/KagModels'
import { WorkDetailPane } from '../components/detail/WorkDetailPane'
import { WorkFormOverlay } from '../components/detail/WorkFormOverlay'
import { AlbumFormOverlay } from '../components/detail/AlbumFormOverlay'
import { AlbumDetailPane } from '../components/detail/AlbumDetailPane'
import { CatalogDetailPane } from '../components/detail/CatalogDetailPane'
import { CatalogListOverlay } from '../components/detail/CatalogListOverlay'
import { SharePosterOverlay } from '../components/detail/SharePosterOverlay'
import { SearchOverlay } from '../components/detail/SearchOverlay'
import { ChildFormOverlay } from '../components/detail/ChildFormOverlay'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '时间线'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '画册'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '画廊'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('kagRoute') @Watch('onRoute') route: string = ''
  @StorageLink('mainTab') @Watch('onMainTab') mainTab: number = 0
  @StorageLink('kagChildId') childId: string = ''
  @Prop company: string = '魏文波'
  @Prop appName: string = '少儿画苑'
  @Prop tagline: string = ''
  @State work: ArtworkItem = new ArtworkItem()
  @State album: AlbumItem = new AlbumItem()
  @State catalog: CatalogItem = new CatalogItem()
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

  onRoute(): void {
    void this.resolveRoute()
  }

  private kind(): string {
    return KagNav.kindOf(this.route)
  }

  private async resolveRoute(): Promise<void> {
    const kind = this.kind()
    const id = KagNav.idOf(this.route)
    if (kind === 'work' || kind === 'share') {
      const list = await KagBizService.loadWorks(this.childId, '', '')
      const found = KagBizService.findWork(list, id)
      if (found !== undefined) {
        this.work = found
      }
    }
    if (kind === 'album') {
      const list = await KagBizService.loadAlbums(this.childId)
      const found = KagBizService.findAlbum(list, id)
      if (found !== undefined) {
        this.album = found
      }
    }
    if (kind === 'theme' || kind === 'hall' || kind === 'milestone' || kind === 'guide') {
      let list: CatalogItem[] = []
      if (kind === 'theme') {
        list = await KagBizService.loadThemes()
      } else if (kind === 'hall') {
        list = await KagBizService.loadHalls()
      } else if (kind === 'milestone') {
        list = await KagBizService.loadMilestones()
      } else {
        list = await KagBizService.loadGuides()
      }
      const found = KagBizService.findCatalog(list, id)
      if (found !== undefined) {
        this.catalog = found
      }
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            tagline: this.tagline,
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          AlbumListPage({ onRequireAuth: () => this.onRequireAuth() }).layoutWeight(1)
        } else if (this.current === 2) {
          GalleryPage({ onRequireAuth: () => this.onRequireAuth() }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => {
              AuthService.logout()
              this.onLogout()
            },
            onRequireAuth: () => this.onRequireAuth()
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

      if (this.kind() === 'form') {
        WorkFormOverlay().width('100%').height('100%')
      } else if (this.kind() === 'albumForm') {
        AlbumFormOverlay().width('100%').height('100%')
      } else if (this.kind() === 'childForm') {
        ChildFormOverlay().width('100%').height('100%')
      } else if (this.kind() === 'search') {
        SearchOverlay().width('100%').height('100%')
      } else if (this.kind() === 'work') {
        WorkDetailPane({ item: this.work, onRequireAuth: () => this.onRequireAuth() })
          .width('100%').height('100%')
      } else if (this.kind() === 'album') {
        AlbumDetailPane({ item: this.album }).width('100%').height('100%')
      } else if (this.kind() === 'share') {
        SharePosterOverlay({ item: this.work }).width('100%').height('100%')
      } else if (this.kind() === 'theme' || this.kind() === 'hall' || this.kind() === 'milestone' || this.kind() === 'guide') {
        CatalogDetailPane({
          item: this.catalog,
          kind: this.kind(),
          onRequireAuth: () => this.onRequireAuth()
        }).width('100%').height('100%')
      } else if (this.kind() === 'themes' || this.kind() === 'halls' || this.kind() === 'milestones' || this.kind() === 'guides') {
        CatalogListOverlay({ kind: this.listKind() }).width('100%').height('100%')
      } else if (this.kind() === 'curate') {
        AIAssistantPage({
          onRequireAuth: () => this.onRequireAuth(),
          onBookFromAi: (_c: string) => {
            KagNav.openBare('halls')
          }
        }).width('100%').height('100%')
      } else if (this.kind() === 'messages') {
        MessagesPage({ showClose: true }).width('100%').height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  private listKind(): string {
    if (this.kind() === 'halls') {
      return 'hall'
    }
    if (this.kind() === 'milestones') {
      return 'milestone'
    }
    if (this.kind() === 'guides') {
      return 'guide'
    }
    return 'theme'
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      AppStorage.setOrCreate('mainTab', t.index)
      this.current = t.index
    })
  }
}
