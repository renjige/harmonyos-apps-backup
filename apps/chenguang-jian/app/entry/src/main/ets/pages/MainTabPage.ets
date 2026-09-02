import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { TagsPage } from './TagsPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AIAssistantPage } from './AIAssistantPage'
import { AuthService } from '../services/AuthService'
import { EssayBizService } from '../services/EssayBizService'
import { EssayNav } from '../services/EssayNav'
import { EssayStore } from '../services/EssayStore'
import { WriteEssayPane } from '../components/essay/WriteEssayPane'
import { DawnQuoteOverlay } from '../components/essay/DawnQuoteOverlay'
import { FavQuotesPane } from '../components/essay/FavQuotesPane'
import { EssayDetailPane } from '../components/detail/EssayDetailPane'
import { CatalogDetailPane } from '../components/detail/CatalogDetailPane'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '笺集'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'tag'
    t1.label = '标签'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'user'
    t2.label = '我的'
    tabs.push(t2)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showQuote: boolean = false
  @State quoteId: string = ''
  @State quoteTitle: string = ''
  @State quoteBody: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('showWriteEssay') showWrite: boolean = false
  @StorageLink('writeEssayId') writeEssayId: string = ''
  @StorageLink('detailRoute') detailRoute: string = ''
  @StorageLink('detailToken') detailToken: number = 0
  @StorageLink('showMessages') showMessages: boolean = false
  @StorageLink('showDiagnose') showDiagnose: boolean = false
  @StorageLink('showFavQuotes') showFav: boolean = false
  @StorageLink('essayRefresh') essayRefresh: number = 0
  @StorageLink('mainTabIndex') @Watch('onMainTab') pageTab: number = 0
  @Prop appName: string = '晨光笺'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('darkModeOn') === true) {
      Theme.setColorMode('dark')
    }
    void this.maybeQuote()
  }

  onMainTab(): void {
    this.current = this.pageTab
  }

  private async maybeQuote(): Promise<void> {
    if (!EssayStore.shouldShowQuote()) {
      return
    }
    const daily = await EssayBizService.loadDaily(new Date().getHours())
    const item = EssayBizService.quoteFromDaily(daily)
    if (item === undefined) {
      return
    }
    this.quoteId = item.id
    this.quoteTitle = item.title
    this.quoteBody = item.body
    this.showQuote = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeQuote(): void {
    this.showQuote = false
    EssayNav.restoreBar()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({ refreshToken: this.essayRefresh }).layoutWeight(1)
        } else if (this.current === 1) {
          TagsPage({ refreshToken: this.essayRefresh }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.essayRefresh,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => {
              AuthService.logout()
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
          .shadow({ radius: 16, color: 'rgba(61,50,40,0.08)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showQuote) {
        DawnQuoteOverlay({
          quoteId: this.quoteId,
          quoteTitle: this.quoteTitle,
          quoteBody: this.quoteBody,
          onClose: (): void => { this.closeQuote() }
        })
      }

      if (this.showWrite) {
        WriteEssayPane({
          editId: this.writeEssayId,
          refreshToken: this.essayRefresh,
          onSaved: (): void => { EssayNav.bumpRefresh() }
        })
      }

      if (this.detailRoute.length > 0) {
        if (EssayNav.parseKind() === 'essay') {
          EssayDetailPane({
            itemId: EssayNav.parseId(),
            refreshToken: this.detailToken,
            onChanged: (): void => { EssayNav.bumpRefresh() }
          })
        } else {
          CatalogDetailPane({
            kind: EssayNav.parseKind(),
            itemId: EssayNav.parseId(),
            refreshToken: this.detailToken
          })
        }
      }

      if (this.showFav) {
        FavQuotesPane()
      }

      if (this.showMessages) {
        MessagesPage()
      }

      if (this.showDiagnose) {
        Column() {
          Row() {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick((): void => { EssayNav.closeDiagnose() })
            Text('书写习惯自检')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: 8 })
          AIAssistantPage({
            onWrite: (): void => {
              EssayNav.closeDiagnose()
              EssayNav.openWrite('')
            }
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
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
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      AppStorage.setOrCreate('mainTabIndex', t.index)
      this.current = t.index
    })
  }
}
