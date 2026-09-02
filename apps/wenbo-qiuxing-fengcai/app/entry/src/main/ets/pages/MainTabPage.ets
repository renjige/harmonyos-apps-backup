import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { DiscoverPage } from './DiscoverPage'
import { WatchPlanPage } from './WatchPlanPage'
import { GrowthPage } from './GrowthPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { ComparePage } from './ComparePage'
import { SportHubPage } from './SportHubPage'
import { ScoutNotesPage } from './ScoutNotesPage'
import { QuizPage } from './QuizPage'
import { FollowPage } from './FollowPage'
import { AthleteDetailPane } from '../components/detail/AthleteDetailPane'
import { EventDetailPane } from '../components/detail/EventDetailPane'
import { AuthService } from '../services/AuthService'
import { StarDetailNav } from '../services/StarDetailNav'

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
    t2.name = 'check'
    t2.label = '计划'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'chart'
    t3.label = '成长'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

/** 5 Tab：首页 | 发现 | 计划 | 成长 | 我的 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailRefresh: number = 0
  @State contentRefresh: number = 0
  @State showMessages: boolean = false
  @State showFollow: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @StorageLink('detailToken') detailToken: number = 0
  @StorageLink('themeColorMode') themeColorMode: string = 'system'
  @Prop company: string = '魏文波'
  @Prop appName: string = '球星风采'
  @Prop tagline: string = '体育人物工具：观赛计划、球探笔记、双星对比、知识挑战与赛事提醒'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
    this.detailRefresh += 1
  }

  private closeSubPages(): void {
    this.showMessages = false
    this.showFollow = false
    if (StarDetailNav.isOpen()) {
      StarDetailNav.close()
    }
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private requireAuth(): void {
    this.closeSubPages()
    this.onRequireAuth()
  }

  private openMessages(): void {
    this.showMessages = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openFollowPanel(): void {
    this.showFollow = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private switchTab(index: number): void {
    if (StarDetailNav.isOpen()) {
      StarDetailNav.close()
    }
    this.showMessages = false
    this.showFollow = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.current = index
  }

  private detailKind(): string {
    const route = this.detailRoute
    if (route === 'compare' || route === 'watchplan' || route === 'quiz' || route === 'scout') {
      return route
    }
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  private detailId(): string {
    const route = this.detailRoute
    if (route === 'compare' || route === 'watchplan' || route === 'quiz' || route === 'scout') {
      return ''
    }
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }

  private detailNavToken(): number {
    return this.detailToken
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
            onOpenMessages: (): void => { this.openMessages() },
            onSwitchTab: (index: number): void => { this.switchTab(index) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          DiscoverPage({
            refreshToken: this.contentRefresh
          }).layoutWeight(1)
        } else if (this.current === 2) {
          WatchPlanPage({
            embedded: true
          }).layoutWeight(1)
        } else if (this.current === 3) {
          GrowthPage({
            refreshToken: this.contentRefresh
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
            onRequireAuth: (): void => { this.requireAuth() },
            onOpenMessages: (): void => { this.openMessages() },
            onOpenFollow: (): void => { this.openFollowPanel() },
            onSwitchTab: (index: number): void => { this.switchTab(index) }
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
          .shadow({ radius: 16, color: 'rgba(15,23,42,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showMessages) {
        MessagesPage({
          onClose: (): void => {
            this.showMessages = false
            AppStorage.setOrCreate('tabBarHidden', StarDetailNav.isOpen())
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showFollow) {
        Column() {
          FollowPage({
            refreshToken: this.contentRefresh,
            overlayMode: true,
            onRequireAuth: (): void => { this.requireAuth() },
            onClose: (): void => {
              this.showFollow = false
              AppStorage.setOrCreate('tabBarHidden', false)
            }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(16)
      }

      if (this.detailRoute.length > 0) {
        Column() {
          if (this.detailKind() === 'event') {
            EventDetailPane({
              itemId: this.detailId(),
              refreshToken: this.detailNavToken(),
              onRequireAuth: (): void => { this.requireAuth() },
              onChanged: (): void => { this.bumpContentRefresh() }
            })
              .width('100%')
              .height('100%')
          } else if (this.detailKind() === 'sport') {
            SportHubPage({
              sportKey: this.detailId(),
              refreshToken: this.detailNavToken()
            })
              .width('100%')
              .height('100%')
          } else if (this.detailKind() === 'compare') {
            ComparePage()
              .width('100%')
              .height('100%')
          } else if (this.detailKind() === 'watchplan') {
            WatchPlanPage()
              .width('100%')
              .height('100%')
          } else if (this.detailKind() === 'scout') {
            ScoutNotesPage({
              athleteId: this.detailId(),
              navToken: this.detailNavToken()
            })
              .width('100%')
              .height('100%')
          } else if (this.detailKind() === 'quiz') {
            QuizPage()
              .width('100%')
              .height('100%')
          } else {
            AthleteDetailPane({
              itemId: this.detailId(),
              refreshToken: this.detailNavToken(),
              onRequireAuth: (): void => { this.requireAuth() },
              onChanged: (): void => { this.bumpContentRefresh() }
            })
              .width('100%')
              .height('100%')
          }
        }
        .width('100%')
        .height('100%')
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
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
      this.switchTab(t.index)
    })
  }
}
