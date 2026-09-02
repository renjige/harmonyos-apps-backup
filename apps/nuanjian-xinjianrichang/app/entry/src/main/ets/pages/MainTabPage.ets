import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { NotesPage } from './NotesPage'
import { ReviewPage } from './ReviewPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { WriteNotePane } from '../components/note/WriteNotePane'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { AuthService } from '../services/AuthService'
import { NoteNav } from '../services/NoteNav'

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
    t1.name = 'heart'
    t1.label = '心笺'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '回顾'
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
  @StorageLink('showMessages') showMessages: boolean = false
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '暖笺生活'
  @Prop appName: string = '心笺日常'
  @Prop tagline: string = '把平凡日子写成自己的故事'
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
    return NoteNav.parseId()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            refreshToken: this.noteRefresh,
            onOpenAll: (): void => { this.current = 1 }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          NotesPage({ refreshToken: this.noteRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          ReviewPage({ refreshToken: this.noteRefresh }).layoutWeight(1)
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
        }
      }
      .width('100%')
      .height('100%')

      if (this.showWrite) {
        WriteNotePane({
          editId: this.writeNoteId,
          refreshToken: this.writeToken
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.detailRoute.length > 0) {
        NoteDetailPane({
          itemId: this.detailId(),
          refreshToken: this.detailToken
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showMessages) {
        MessagesPage()
          .width('100%')
          .height('100%')
          .zIndex(14)
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
