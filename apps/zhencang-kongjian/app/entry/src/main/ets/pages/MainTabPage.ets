import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { TreasureDetailPane } from '../components/detail/TreasureDetailPane'
import { HomePage } from './HomePage'
import { ArchivePage } from './ArchivePage'
import { ThemeHubPage } from './ThemeHubPage'
import { ReviewHubPage } from './ReviewHubPage'
import { ItemEditorPage } from './ItemEditorPage'
import {
  AchievementWallPage,
  AlbumEditorPage,
  NoteEditorPage,
  PlanEditorPage,
  SearchPage,
  SmartOrganizePage
} from './TreasureSubPages'
import {
  AlbumDetailPage,
  ComparePage,
  DomainArchivePage,
  NoteListPage,
  OnboardingOverlay,
  PlanListPage,
  WishListPage
} from './TreasureExtraPages'
import { TreasureStore } from '../services/TreasureStore'
import {
  AlbumListPage,
  CategoryManagePage,
  ExportPage,
  IncompletePage,
  TagManagePage,
  TrashPage,
  TreasureMinePage
} from './TreasureMinePage'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('treasureTabIndex') @Watch('onTabJump') tabJump: number = 0
  @State current: number = 0
  @State refreshToken: number = 0
  @State editorToken: number = 0
  @State detailToken: number = 0
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('treasureShowEditor') @Watch('onEditorFlag') showEditor: boolean = false
  @StorageLink('treasureShowDetail') @Watch('onDetailFlag') showDetail: boolean = false
  @StorageLink('treasureEditId') editId: string = ''
  @StorageLink('treasureDetailId') detailId: string = ''
  @StorageLink('treasureSubPage') subPage: string = ''
  @StorageLink('treasureRev') @Watch('onStoreRev') storeRev: number = 0
  @State showOnboarding: boolean = false
  private tabs: TabItem[] = MainTabPage.buildTabs()

  aboutToAppear(): void {
    this.showOnboarding = !TreasureStore.settings().onboardingDone
  }

  static buildTabs(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '首页'],
      ['1', 'biz', '珍藏'],
      ['2', 'ai', '主题'],
      ['3', 'chart', '回顾'],
      ['4', 'user', '我的']
    ]
    for (const d of defs) {
      const t = new TabItem()
      t.index = parseInt(d[0], 10)
      t.name = d[1] as AppIconName
      t.label = d[2]
      tabs.push(t)
    }
    return tabs
  }

  onTabJump(): void {
    if (this.tabJump >= 0 && this.tabJump <= 4) {
      this.current = this.tabJump
      AppStorage.setOrCreate('treasureTabIndex', -1)
    }
  }

  onEditorFlag(): void {
    if (this.showEditor) {
      this.editorToken += 1
    }
  }

  onDetailFlag(): void {
    if (this.showDetail) {
      this.detailToken += 1
    }
  }

  onStoreRev(): void {
    this.refreshToken += 1
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({ refreshToken: this.refreshToken }).layoutWeight(1)
        } else if (this.current === 1) {
          ArchivePage({ refreshToken: this.refreshToken }).layoutWeight(1)
        } else if (this.current === 2) {
          ThemeHubPage({ refreshToken: this.refreshToken }).layoutWeight(1)
        } else if (this.current === 3) {
          ReviewHubPage({ refreshToken: this.refreshToken }).layoutWeight(1)
        } else {
          TreasureMinePage({ refreshToken: this.refreshToken, onToast: (t: string) => { this.showToast(t) } }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => { this.TabBarItem(t) }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .padding({ left: Theme.space.s2, right: Theme.space.s2, bottom: 10 })
          .margin({ left: Theme.space.s3, right: Theme.space.s3, bottom: Theme.space.s2 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(44,62,66,0.08)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showEditor) {
        ItemEditorPage({ itemId: this.editId, openToken: this.editorToken, onSaved: (m: string) => { this.showToast(m) } })
          .width('100%').height('100%').zIndex(16)
      }
      if (this.showDetail) {
        TreasureDetailPane({ itemId: this.detailId, openToken: this.detailToken, onToast: (t: string) => { this.showToast(t) } })
          .width('100%').height('100%').zIndex(18)
      }
      if (this.subPage === 'search') {
        SearchPage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'smartOrganize') {
        SmartOrganizePage().width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'planEditor') {
        PlanEditorPage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'noteEditor') {
        NoteEditorPage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'albumEditor') {
        AlbumEditorPage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'achievements') {
        AchievementWallPage().width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'categories') {
        CategoryManagePage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'tags') {
        TagManagePage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'incomplete') {
        IncompletePage().width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'trash') {
        TrashPage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'export') {
        ExportPage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'albums') {
        AlbumListPage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'albumDetail') {
        AlbumDetailPage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'planList') {
        PlanListPage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'wishList') {
        WishListPage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'noteList') {
        NoteListPage({ onToast: (t: string) => { this.showToast(t) } }).width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'domainArchive') {
        DomainArchivePage().width('100%').height('100%').zIndex(15)
      }
      if (this.subPage === 'compare') {
        ComparePage().width('100%').height('100%').zIndex(15)
      }

      if (this.showOnboarding) {
        OnboardingOverlay({
          onDone: (): void => {
            this.showOnboarding = false
          }
        }).width('100%').height('100%')
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.sm,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(40)
      .height(24)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(10)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
