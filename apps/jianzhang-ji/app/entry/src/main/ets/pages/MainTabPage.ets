import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { FavoritesPage } from './FavoritesPage'
import { ComparePage } from './ComparePage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AuthService } from '../services/AuthService'
import { BrochureDetailNav } from '../services/BrochureDetailNav'
import { BrochureBizService } from '../services/BrochureBizService'
import { BrochureItem, ArticleItem } from '../models/BrochureModels'
import { BrochureDetailPane } from '../components/detail/BrochureDetailPane'
import { ArticleDetailPane } from '../components/detail/ArticleDetailPane'

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
    t1.name = 'bookmark'
    t1.label = '收藏'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '对比'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)
    return tabs
  }
}

/** 四 Tab：首页 | 收藏 | 对比 | 我的；详情 Overlay 顶层 + tabBarHidden */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showMessages: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('brochureRoute') @Watch('onRoute') route: string = ''
  @StorageLink('mainTab') @Watch('onMainTab') mainTab: number = 0
  @StorageLink('brochureTick') @Watch('onRouteTick') brochureTick: number = 0
  @Prop company: string = '北京简章集科技有限公司'
  @Prop appName: string = '简章集'
  @Prop tagline: string = '高校招生简章智慧检索平台，帮助学生和家长快速找到目标院校的官方招生信息'
  @State brochure: BrochureItem = new BrochureItem()
  @State article: ArticleItem = new ArticleItem()
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

  onRouteTick(): void {
    void this.resolveRoute()
  }

  private kind(): string {
    return BrochureDetailNav.kindOf(this.route)
  }

  private async resolveRoute(): Promise<void> {
    const kind = this.kind()
    const id = BrochureDetailNav.idOf(this.route)
    if (kind === 'brochure') {
      const row = await BrochureBizService.loadBrochureById(id)
      if (row !== undefined) {
        this.brochure = row
      }
    }
    if (kind === 'article') {
      const row = await BrochureBizService.loadArticleById(id)
      if (row !== undefined) {
        this.article = row
      }
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            tagline: this.tagline
          }).layoutWeight(1)
        } else if (this.current === 1) {
          FavoritesPage({
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 2) {
          ComparePage().layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => this.onOpenLogin(),
            onOpenMessages: (): void => { this.showMessages = true },
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
            onRequireAuth: (): void => this.onRequireAuth()
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
          .shadow({ radius: 16, color: 'rgba(10,37,64,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showMessages) {
        Column() {
          MessagesPage({
            onClose: (): void => { this.showMessages = false }
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.kind() === 'brochure') {
        BrochureDetailPane({
          item: this.brochure,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(100)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      } else if (this.kind() === 'article') {
        ArticleDetailPane({ item: this.article })
          .width('100%')
          .height('100%')
          .zIndex(100)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
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
      AppStorage.setOrCreate('tabBarHidden', false)
      AppStorage.setOrCreate('mainTab', t.index)
      this.current = t.index
    })
  }
}
