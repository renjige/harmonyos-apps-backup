import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { LibraryPage } from './LibraryPage'
import { InsightPage } from './InsightPage'
import { MinePage } from './MinePage'
import { WriteInspirationPane } from '../components/slip/WriteInspirationPane'
import { InspirationDetailPane } from '../components/detail/InspirationDetailPane'
import { AuthService } from '../services/AuthService'
import { SlipNav } from '../services/SlipNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'edit'
    t0.label = '记录'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'list'
    t1.label = '札记'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '洞察'
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
  @State writeToken: number = 0
  @State detailToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('showWriteNote') @Watch('onWriteFlag') showWrite: boolean = false
  @StorageLink('writeNoteId') writeNoteId: string = ''
  @StorageLink('detailRoute') @Watch('onDetailFlag') detailRoute: string = ''
  @StorageLink('noteRefresh') noteRefresh: number = 0
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '梦隅文化'
  @Prop appName: string = '梦隅札'
  @Prop tagline: string = '记录梦境 · 洞察自我'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  onWriteFlag(): void {
    if (this.showWrite) {
      this.writeToken += 1
    }
  }

  onDetailFlag(): void {
    if (this.detailRoute.length > 0) {
      this.detailToken += 1
    }
  }

  onDarkChange(): void {
    Theme.setColorMode(this.darkModeOn ? 'dark' : 'light')
  }

  private detailId(): string {
    return SlipNav.parseId()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.noteRefresh,
            onOpenLibrary: (): void => { this.current = 1 }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          LibraryPage({ refreshToken: this.noteRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          InsightPage({ refreshToken: this.noteRefresh }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.noteRefresh,
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
          .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s3 })
          .padding({ left: 4, right: 4, top: 4, bottom: 4 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .shadow({ radius: 12, color: Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(26,26,46,0.08)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showWrite) {
        WriteInspirationPane({
          editId: this.writeNoteId,
          refreshToken: this.writeToken
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.detailRoute.length > 0) {
        InspirationDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
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
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
