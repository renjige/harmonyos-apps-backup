import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { GearPage } from './GearPage'
import { DiscoverPage } from './DiscoverPage'
import { JournalPage } from './JournalPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AIAssistantPage } from './AIAssistantPage'
import { AboutPage } from './AboutPage'
import { FeedbackPage } from './FeedbackPage'
import { FavoritesPage } from './FavoritesPage'
import { AlbumPage } from './AlbumPage'
import { PostsPage } from './PostsPage'
import { CampDetailPane } from '../components/detail/CampDetailPane'
import { GuideDetailPane } from '../components/detail/GuideDetailPane'
import { TemplateDetailPane } from '../components/detail/TemplateDetailPane'
import { TripDetailPane } from '../components/detail/TripDetailPane'
import { JournalDetailPane } from '../components/detail/JournalDetailPane'
import { PostDetailPane } from '../components/detail/PostDetailPane'
import { TripFormPane } from '../components/forms/TripFormPane'
import { GearFormPane } from '../components/forms/GearFormPane'
import { JournalFormPane } from '../components/forms/JournalFormPane'
import { PackListPane } from '../components/forms/PackListPane'
import { NoteFormPane } from '../components/forms/NoteFormPane'
import { PostFormPane } from '../components/forms/PostFormPane'
import { AuthService } from '../services/AuthService'
import { CampDetailNav } from '../services/CampDetailNav'

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
    t1.name = 'bag'
    t1.label = '装备'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'search'
    t2.label = '发现'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'book'
    t3.label = '记录'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
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
  @Prop company: string = '魏文波'
  @Prop appName: string = '露营玩家'
  @Prop tagline: string = '称完装备再出发'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private kind(): string {
    return CampDetailNav.kind()
  }

  private detailId(): string {
    return CampDetailNav.parseId()
  }

  private bump(): void {
    this.contentRefresh += 1
  }

  onDetailRouteChange(): void {
    if (this.detailRoute.length === 0) {
      this.bump()
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onOpenDiscover: (): void => { this.current = 2 },
            onOpenGear: (): void => { this.current = 1 },
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          GearPage({
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 2) {
          DiscoverPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
        } else if (this.current === 3) {
          JournalPage({
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
            },
            onSwitchTab: (index: number): void => { this.current = index }
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

      if (this.detailRoute.length > 0 && this.kind() === 'camp') {
        CampDetailPane({
          campId: this.detailId(),
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        }).width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'guide') {
        GuideDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'tpl') {
        TemplateDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        }).width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'trip') {
        TripDetailPane({ itemId: this.detailId(), refreshToken: this.detailToken })
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'tnew') {
        TripFormPane().width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'gnew') {
        GearFormPane({ editId: '' }).width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'gedit') {
        GearFormPane({ editId: this.detailId() }).width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'journal') {
        JournalDetailPane({ itemId: this.detailId(), refreshToken: this.detailToken })
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'jnew') {
        JournalFormPane().width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && (this.kind() === 'pack' || this.kind() === 'pnew')) {
        PackListPane().width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'note') {
        NoteFormPane({ campId: this.detailId() }).width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'postnew') {
        PostFormPane().width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'post') {
        PostDetailPane({ itemId: this.detailId(), refreshToken: this.detailToken })
          .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'myposts') {
        PostsPage({
          refreshToken: this.detailToken,
          onRequireAuth: (): void => this.onRequireAuth()
        }).width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'favorites') {
        FavoritesPage({ refreshToken: this.detailToken }).width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'album') {
        AlbumPage({ refreshToken: this.detailToken }).width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'messages') {
        MessagesPage({ refreshToken: this.detailToken }).width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'about') {
        AboutPage().width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'feedback') {
        FeedbackPage().width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage).zIndex(20)
      } else if (this.detailRoute.length > 0 && this.kind() === 'diagnose') {
        Column() {
          Row() {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick(() => CampDetailNav.close())
            Text('智慧清单')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
          }
          .width('100%')
          .padding({ left: 12, right: Theme.space.pageX, top: 8 })
          AIAssistantPage({
            onBookFromAi: (tplId: string): void => {
              CampDetailNav.openTemplate(tplId)
            }
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(20)
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
      this.current = t.index
      this.bump()
    })
  }
}
