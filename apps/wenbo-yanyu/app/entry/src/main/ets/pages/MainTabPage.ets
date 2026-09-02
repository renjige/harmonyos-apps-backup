import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HubPage } from './HubPage'
import { ExpressPage } from './ExpressPage'
import { ResearchPage } from './ResearchPage'
import { GrowthPage } from './GrowthPage'
import { ResearchOverlay } from './research/ResearchOverlay'
import { MinePage } from './MinePage'
import { HistoryPage } from './HistoryPage'
import { FavoritesPage } from './FavoritesPage'
import { ManuscriptListPage } from './ManuscriptListPage'
import { AIAssistantPage } from './AIAssistantPage'
import { DraftPage } from './DraftPage'
import { ScenarioLibraryPage } from './ScenarioLibraryPage'
import { UseCaseGuidePage } from './UseCaseGuidePage'
import { InspirationDetailPane } from '../components/detail/InspirationDetailPane'
import { StyleDetailPane } from '../components/detail/StyleDetailPane'
import { AuthService } from '../services/AuthService'
import { LanguageCraftNav } from '../services/LanguageCraftNav'
import { AppRefresh } from '../services/AppRefresh'

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
    t1.name = 'edit'
    t1.label = '表达'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'bookmark'
    t2.label = '研究'
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

@Component
export struct MainTabPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('mainTabIndex') @Watch('onMainTab') storedTab: number = 0
  @State current: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailInspirationId') detailId: string = ''
  @StorageLink('detailRefresh') detailRefresh: number = 0
  @StorageLink('detailStyleKey') styleKey: string = ''
  @StorageLink('detailStyleRefresh') styleRefresh: number = 0
  @StorageLink('showHistory') showHistory: boolean = false
  @StorageLink('showFavorites') showFavorites: boolean = false
  @StorageLink('showManuscripts') showManuscripts: boolean = false
  @StorageLink('showDiagnose') showDiagnose: boolean = false
  @StorageLink('showDraft') showDraft: boolean = false
  @StorageLink('showScenarioLibrary') showScenarioLibrary: boolean = false
  @StorageLink('showUseCaseGuide') showUseCaseGuide: boolean = false
  @StorageLink('researchPanel') researchPanel: string = ''
  @StorageLink('recordRefresh') recordRefresh: number = 0
  @StorageLink('favRefresh') favRefresh: number = 0
  @StorageLink('hubRefresh') hubRefresh: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '研语'
  @Prop tagline: string = '润色表达，也把学习与思考沉淀成自己的研究资料。'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.current = this.storedTab
  }

  onMainTab(): void {
    this.current = this.storedTab
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          HubPage({ appName: this.appName })
            .width('100%')
            .height('100%')
            .visibility(this.current === 0 ? Visibility.Visible : Visibility.None)
          ExpressPage({ appName: this.appName })
            .width('100%')
            .height('100%')
            .visibility(this.current === 1 ? Visibility.Visible : Visibility.None)
          ResearchPage()
            .width('100%')
            .height('100%')
            .visibility(this.current === 2 ? Visibility.Visible : Visibility.None)
          GrowthPage({ tabActive: this.current === 3 })
            .width('100%')
            .height('100%')
            .visibility(this.current === 3 ? Visibility.Visible : Visibility.None)
          MinePage({
            appName: this.appName,
            tabActive: this.current === 4,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
            }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 4 ? Visibility.Visible : Visibility.None)
        }
        .layoutWeight(1)
        .width('100%')

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
          .border({ width: { top: 1 }, color: Theme.of(this.darkModeOn).strokeHairline })
          .shadow({ radius: 16, color: 'rgba(26,58,92,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.detailId.length > 0) {
        InspirationDetailPane({
          itemId: this.detailId,
          refreshToken: this.detailRefresh
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.styleKey.length > 0) {
        StyleDetailPane({
          itemKey: this.styleKey,
          refreshToken: this.styleRefresh
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showHistory) {
        HistoryPage({ refreshToken: this.recordRefresh })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showFavorites) {
        FavoritesPage({ refreshToken: this.favRefresh })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showManuscripts) {
        ManuscriptListPage()
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showDiagnose) {
        AIAssistantPage({
          onClose: (): void => { LanguageCraftNav.closeDiagnose() }
        })
          .width('100%')
          .height('100%')
          .zIndex(15)
      }

      if (this.showDraft) {
        DraftPage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showScenarioLibrary) {
        ScenarioLibraryPage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showUseCaseGuide) {
        UseCaseGuidePage()
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.researchPanel.length > 0) {
        ResearchOverlay()
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
            Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.of(this.darkModeOn).brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      AppStorage.setOrCreate('mainTabIndex', t.index)
      this.current = t.index
      if (t.index === 0 || t.index === 3 || t.index === 4) {
        AppRefresh.bumpHub()
      }
      if (t.index === 2 || t.index === 3) {
        AppRefresh.bumpResearch()
      }
    })
  }
}
