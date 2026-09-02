import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { TrailPage } from './TrailPage'
import { ListsPage } from './ListsPage'
import { NotesPage } from './NotesPage'
import { MinePage } from './MinePage'
import { ExcerptDetailPane } from '../components/detail/ExcerptDetailPane'
import { BookListDetailPane } from '../components/detail/BookListDetailPane'
import { ListBookDetailPane } from '../components/detail/ListBookDetailPane'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { AuthService } from '../services/AuthService'
import { RoamDetailNav } from '../services/RoamDetailNav'

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
    t1.name = 'chart'
    t1.label = '轨迹'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'book'
    t2.label = '书单'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'bookmark'
    t3.label = '笔记'
    tabs.push(t3)
    return tabs
  }
}

/** 4 Tab：首页 | 轨迹 | 书单 | 笔记。设置从笔记页齿轮进入 Overlay。 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @StorageLink('detailToken') detailToken: number = 0
  @StorageLink('showMineSettings') showMineSettings: boolean = false
  @StorageLink('roamRefresh') roamRefresh: number = 0
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '书页漫游'
  @Prop tagline: string = '在书页间漫游，发现属于你的阅读风景。'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  onDarkChange(): void {
    Theme.setColorMode(this.darkModeOn ? 'dark' : 'light')
  }

  onTabLink(): void {
    this.current = this.mainTabIndex
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            tagline: this.tagline,
            refreshToken: this.roamRefresh
          }).layoutWeight(1)
        } else if (this.current === 1) {
          TrailPage({ refreshToken: this.roamRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          ListsPage({ refreshToken: this.roamRefresh }).layoutWeight(1)
        } else {
          NotesPage({ refreshToken: this.roamRefresh }).layoutWeight(1)
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

      if (this.detailRoute.length > 0) {
        if (RoamDetailNav.routeKind(this.detailRoute) === 'excerpt') {
          ExcerptDetailPane({
            itemId: RoamDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (RoamDetailNav.routeKind(this.detailRoute) === 'booklist') {
          BookListDetailPane({
            listId: RoamDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (RoamDetailNav.routeKind(this.detailRoute) === 'listbook') {
          ListBookDetailPane({
            listId: RoamDetailNav.parseRouteId(this.detailRoute),
            bookIndex: RoamDetailNav.parseRouteBookIndex(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (RoamDetailNav.routeKind(this.detailRoute) === 'note') {
          NoteDetailPane({
            noteId: RoamDetailNav.parseRouteId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        }
      }

      if (this.showMineSettings) {
        MinePage({
          appName: this.appName,
          overlayMode: true,
          settingsOnly: true,
          onOpenLogin: (): void => { this.onOpenLogin() },
          onLogout: (): void => {
            void AuthService.logout()
            this.onLogout()
          },
          onCloseOverlay: (): void => { RoamDetailNav.closeSettings() }
        })
          .width('100%')
          .height('100%')
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
          color: this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : Color.Transparent)
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
      this.current = t.index
      AppStorage.setOrCreate('mainTabIndex', t.index)
    })
  }
}
