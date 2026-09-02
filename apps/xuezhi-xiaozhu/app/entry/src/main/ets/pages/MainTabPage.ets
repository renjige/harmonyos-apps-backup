import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { LibraryPage } from './LibraryPage'
import { ProgressPage } from './ProgressPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { QaOverlay } from './QaOverlay'
import { FavoritesOverlay } from './FavoritesOverlay'
import { AIAssistantPage } from './AIAssistantPage'
import { PathDetailPane } from '../components/detail/PathDetailPane'
import { LessonDetailPane } from '../components/detail/LessonDetailPane'
import { CardDetailPane } from '../components/detail/CardDetailPane'
import { AuthService } from '../services/AuthService'
import { CottageNav } from '../services/CottageNav'

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
    t1.label = '知识库'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '进度'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)
    return tabs
  }
}

/** 4 Tab：首页 | 知识库 | 进度 | 我的。详情与问答在顶层 Overlay。 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') @Watch('onDetailFlag') detailRoute: string = ''
  @StorageLink('detailKind') detailKind: string = ''
  @StorageLink('detailId') detailId: string = ''
  @StorageLink('overlayRoute') overlayRoute: string = ''
  @StorageLink('showMessages') showMessages: boolean = false
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('cottageTick') tick: number = 0
  @Prop company: string = '学知小筑'
  @Prop appName: string = '学知小筑'
  @Prop tagline: string = '选一个领域，按路径把知识一点点筑进日常。'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.current = this.mainTabIndex
  }

  onTabLink(): void {
    this.current = this.mainTabIndex
  }

  onDetailFlag(): void {
    if (this.detailRoute.length > 0) {
      this.detailToken += 1
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({ appName: this.appName }).layoutWeight(1)
        } else if (this.current === 1) {
          LibraryPage().layoutWeight(1)
        } else if (this.current === 2) {
          ProgressPage({
            onRequireAuth: (): void => { this.onRequireAuth() }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => { this.onOpenLogin() },
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
          .shadow({ radius: 16, color: 'rgba(18,32,58,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.detailRoute.length > 0 && this.detailKind === CottageNav.PATH) {
        PathDetailPane({
          entityId: this.detailId,
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (this.detailRoute.length > 0 && this.detailKind === CottageNav.LESSON) {
        LessonDetailPane({
          entityId: this.detailId,
          refreshToken: this.detailToken,
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      } else if (this.detailRoute.length > 0) {
        CardDetailPane({
          entityId: this.detailId,
          kind: this.detailKind === CottageNav.DAILY ? 'daily' : 'card',
          refreshToken: this.detailToken,
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.overlayRoute === CottageNav.QA) {
        QaOverlay()
          .width('100%')
          .height('100%')
          .zIndex(20)
      }
      if (this.overlayRoute === CottageNav.DIAGNOSE) {
        AIAssistantPage()
          .width('100%')
          .height('100%')
          .zIndex(20)
      }
      if (this.overlayRoute === CottageNav.FAVORITES) {
        FavoritesOverlay({
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      }

      if (this.showMessages) {
        MessagesPage({
          onClose: (): void => { CottageNav.closeMessages() }
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
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
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      AppStorage.setOrCreate('mainTabIndex', t.index)
    })
  }
}
