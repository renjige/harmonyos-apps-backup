import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { TrailPage } from './TrailPage'
import { CommunityPage } from './CommunityPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AboutPage } from './AboutPage'
import { FavoritesPage } from './FavoritesPage'
import { MyPostsPage } from './MyPostsPage'
import { AIAssistantPage } from './AIAssistantPage'
import { GearDetailPane } from '../components/detail/GearDetailPane'
import { CatalogDetailPane } from '../components/detail/CatalogDetailPane'
import { CategoryDetailPane } from '../components/detail/CategoryDetailPane'
import { TrailDetailPane } from '../components/detail/TrailDetailPane'
import { RouteDetailPane } from '../components/detail/RouteDetailPane'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { PostDetailPane } from '../components/detail/PostDetailPane'
import { GearFormPane } from '../components/forms/GearFormPane'
import { RouteFormPane } from '../components/forms/RouteFormPane'
import { PostFormPane } from '../components/forms/PostFormPane'
import { AuthService } from '../services/AuthService'
import { GearDetailNav } from '../services/GearDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '装备库'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '路线'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'message'
    t2.label = '社区'
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
  @State contentRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') @Watch('onDetailRouteChange') detailRoute: string = ''
  @StorageLink('detailToken') detailToken: number = 0
  @StorageLink('themeRevision') themeRevision: number = 0
  @Prop company: string = '承德锐泓科技有限公司'
  @Prop appName: string = '户外装备库'
  @Prop tagline: string = '克重账本与出装对照'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private kind(): string {
    return GearDetailNav.kind()
  }

  private detailId(): string {
    return GearDetailNav.parseId()
  }

  private bump(): void {
    this.contentRefresh += 1
  }

  onDetailRouteChange(): void {
    if (this.detailRoute.length === 0) {
      this.bump()
    }
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary
        })
      }
      .width(36)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .borderRadius(Theme.radius.pill)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimary : 'transparent')
      Text(t.label)
        .fontSize(Theme.type.caption)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height(Theme.nav.tabHeight)
    .justifyContent(FlexAlign.Center)
    .onClick(() => { this.current = t.index })
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          TrailPage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 2) {
          CommunityPage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onOpenLogin: (): void => this.onOpenLogin(),
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
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
        }
      }
      .width('100%')
      .height('100%')

      if (this.detailRoute.length > 0 && this.kind() === 'gear') {
        GearDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
      } else if (this.detailRoute.length > 0 && this.kind() === 'catalog') {
        CatalogDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
      } else if (this.detailRoute.length > 0 && this.kind() === 'cat') {
        CategoryDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
      } else if (this.detailRoute.length > 0 && this.kind() === 'trail') {
        TrailDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
      } else if (this.detailRoute.length > 0 && this.kind() === 'route') {
        RouteDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
      } else if (this.detailRoute.length > 0 && this.kind() === 'note') {
        NoteDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
      } else if (this.detailRoute.length > 0 && this.kind() === 'post') {
        PostDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
      } else if (this.detailRoute === 'gnew' || this.kind() === 'gedit') {
        GearFormPane({ editId: this.kind() === 'gedit' ? this.detailId() : '' })
          .width('100%')
          .height('100%')
      } else if (this.detailRoute === 'rnew') {
        RouteFormPane()
          .width('100%')
          .height('100%')
      } else if (this.detailRoute === 'pnew') {
        PostFormPane()
          .width('100%')
          .height('100%')
      } else if (this.detailRoute === 'inspect') {
        AIAssistantPage({
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
      } else if (this.detailRoute === 'messages') {
        MessagesPage({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
      } else if (this.detailRoute === 'about') {
        AboutPage()
          .width('100%')
          .height('100%')
      } else if (this.detailRoute === 'favorites') {
        FavoritesPage({
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
      } else if (this.detailRoute === 'myposts') {
        MyPostsPage({ refreshToken: this.detailToken })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .id(`main-${this.themeRevision}`)
  }
}
