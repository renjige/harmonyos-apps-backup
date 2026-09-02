import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { StudyPage } from './StudyPage'
import { NotesPage } from './NotesPage'
import { CirclePage } from './CirclePage'
import { MinePage } from './MinePage'
import { AIAssistantPage } from './AIAssistantPage'
import { ExcerptDetailPane } from '../components/detail/ExcerptDetailPane'
import { ListDetailPane } from '../components/detail/ListDetailPane'
import { EssayDetailPane } from '../components/detail/EssayDetailPane'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { RecordEditorPane } from '../components/detail/RecordEditorPane'
import { AuthService } from '../services/AuthService'
import { InkDetailNav } from '../services/InkDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const make = (index: number, name: AppIconName, label: string): TabItem => {
      const t = new TabItem()
      t.index = index
      t.name = name
      t.label = label
      return t
    }
    tabs.push(make(0, 'home', '首页'))
    tabs.push(make(1, 'book', '书房'))
    tabs.push(make(2, 'bookmark', '笔记'))
    tabs.push(make(3, 'heart', '文友圈'))
    tabs.push(make(4, 'user', '我的'))
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @StorageLink('detailToken') detailToken: number = 0
  @StorageLink('inkRefresh') inkRefresh: number = 0
  @StorageLink('showMatchQuiz') showMatchQuiz: boolean = false
  @StorageLink('mainTabIndex') @Watch('onTabLink') mainTabIndex: number = 0
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '墨香雅集'
  @Prop appName: string = '墨香小筑'
  @Prop tagline: string = '读今日书摘，写下墨迹，在小筑与文友打卡。'
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
            refreshToken: this.inkRefresh
          }).layoutWeight(1)
        } else if (this.current === 1) {
          StudyPage({ refreshToken: this.inkRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          NotesPage({
            refreshToken: this.inkRefresh,
            onRequireAuth: (): void => { this.onRequireAuth() }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          CirclePage({
            refreshToken: this.inkRefresh,
            onRequireAuth: (): void => { this.onRequireAuth() }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => { this.onLogout() }
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

      if (this.detailRoute.length > 0) {
        if (InkDetailNav.routeKind(this.detailRoute) === 'excerpt') {
          ExcerptDetailPane({
            itemId: InkDetailNav.parseId(this.detailRoute),
            refreshToken: this.detailToken,
            onRequireAuth: (): void => { this.onRequireAuth() }
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (InkDetailNav.routeKind(this.detailRoute) === 'list') {
          ListDetailPane({
            listId: InkDetailNav.parseId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (InkDetailNav.routeKind(this.detailRoute) === 'essay') {
          EssayDetailPane({
            itemId: InkDetailNav.parseId(this.detailRoute),
            refreshToken: this.detailToken,
            onRequireAuth: (): void => { this.onRequireAuth() }
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (InkDetailNav.routeKind(this.detailRoute) === 'note') {
          NoteDetailPane({
            itemId: InkDetailNav.parseId(this.detailRoute),
            kind: 'note',
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (InkDetailNav.routeKind(this.detailRoute) === 'review') {
          NoteDetailPane({
            itemId: InkDetailNav.parseId(this.detailRoute),
            kind: 'review',
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        } else if (InkDetailNav.routeKind(this.detailRoute) === 'editor') {
          RecordEditorPane({
            kind: InkDetailNav.parseEditorKind(this.detailRoute),
            itemId: InkDetailNav.parseId(this.detailRoute),
            refreshToken: this.detailToken
          })
            .width('100%')
            .height('100%')
            .zIndex(18)
        }
      }

      if (this.showMatchQuiz) {
        AIAssistantPage({
          onRequireAuth: (): void => { this.onRequireAuth() },
          onBookFromAi: (_c: string): void => {
            InkDetailNav.closeMatch()
            InkDetailNav.switchTab(1)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(19)
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
