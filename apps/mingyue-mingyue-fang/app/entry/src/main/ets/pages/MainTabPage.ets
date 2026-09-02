import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { NotesPage } from './NotesPage'
import { MinePage } from './MinePage'
import { QuotesPage } from './QuotesPage'
import { OrganizePage } from './OrganizePage'
import { ReportPage } from './ReportPage'
import { MessagesPage } from './MessagesPage'
import { FeaturedDetailPane } from '../components/detail/FeaturedDetailPane'
import { BookDetailPane } from '../components/detail/BookDetailPane'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { QuoteDetailPane } from '../components/detail/QuoteDetailPane'
import { PlanDetailPane } from '../components/detail/PlanDetailPane'
import { AuthService } from '../services/AuthService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'book'
    t0.label = '书架'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '笔记'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'user'
    t2.label = '我的'
    tabs.push(t2)
    return tabs
  }
}

/** 3 Tab：书架 | 笔记 | 我的 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State detailRefresh: number = 0
  @State contentRefresh: number = 0
  @State notesCreateTrigger: number = 0
  @State quotesRefresh: number = 0
  @State reportRefresh: number = 0
  @State showQuotes: boolean = false
  @State showOrganize: boolean = false
  @State showReport: boolean = false
  @State showMessages: boolean = false
  @State messagesRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @Prop company: string = '魏文波'
  @Prop appName: string = '明阅坊'
  @Prop tagline: string = '智慧阅读·知识管理·心灵栖息'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpContentRefresh(): void {
    this.contentRefresh += 1
  }

  private openReport(): void {
    this.showReport = true
    AppStorage.setOrCreate('tabBarHidden', true)
    this.reportRefresh += 1
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onBookChanged: (): void => { this.bumpContentRefresh() }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          NotesPage({
            createTrigger: this.notesCreateTrigger,
            onRequireAuth: (): void => this.onRequireAuth(),
            onNoteCreated: (): void => { this.bumpContentRefresh() }
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
              if (ReadingDetailNav.isOpen()) {
                ReadingDetailNav.close()
              }
              this.current = index
            },
            onOpenQuotes: (): void => {
              this.showQuotes = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.quotesRefresh += 1
            },
            onOpenOrganize: (): void => {
              this.showOrganize = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenReport: (): void => { this.openReport() },
            onOpenMessages: (): void => {
              this.showMessages = true
              AppStorage.setOrCreate('tabBarHidden', true)
              this.messagesRefresh += 1
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
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
          .padding({ left: Theme.space.s2, right: Theme.space.s2 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .shadow({ radius: 12, color: Theme.colors().overlayScrim, offsetY: -2 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showQuotes) {
        QuotesPage({
          refreshToken: this.quotesRefresh,
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => {
            this.showQuotes = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showOrganize) {
        OrganizePage({
          onRequireAuth: (): void => this.onRequireAuth(),
          onClose: (): void => {
            this.showOrganize = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showReport) {
        ReportPage({
          refreshToken: this.reportRefresh,
          onClose: (): void => {
            this.showReport = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showMessages) {
        MessagesPage({
          refreshToken: this.messagesRefresh,
          onClose: (): void => {
            this.showMessages = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
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
    if (ReadingDetailNav.parseKind() === 'featured') {
      FeaturedDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth()
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'book') {
      BookDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth(),
        onProgressUpdated: (): void => { this.bumpContentRefresh() }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'note') {
      NoteDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth()
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'quote') {
      QuoteDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onDeleted: (): void => { this.quotesRefresh += 1 }
      })
        .width('100%')
        .height('100%')
        .zIndex(20)
    } else if (ReadingDetailNav.parseKind() === 'plan') {
      PlanDetailPane({
        itemId: ReadingDetailNav.parseId(),
        refreshToken: this.detailRefresh,
        onRequireAuth: (): void => this.onRequireAuth(),
        onOpenReport: (): void => { this.openReport() },
        onProgressUpdated: (): void => { this.bumpContentRefresh() }
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
      if (ReadingDetailNav.isOpen()) {
        ReadingDetailNav.close()
      }
      this.showQuotes = false
      this.showOrganize = false
      this.showReport = false
      this.showMessages = false
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
