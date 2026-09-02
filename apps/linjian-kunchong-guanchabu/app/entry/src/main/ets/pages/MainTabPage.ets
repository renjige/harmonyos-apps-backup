import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { AtlasPage } from './AtlasPage'
import { StatsPage } from './StatsPage'
import { MinePage } from './MinePage'
import { ObserveEditorSheet } from '../components/insect/ObserveEditorSheet'
import { ObservationDetailPane } from '../components/insect/ObservationDetailPane'
import { InsectWikiPane } from '../components/insect/InsectWikiPane'
import { WikiListSheet } from '../components/insect/WikiListSheet'
import { InsectCatalog, InsectWikiItem } from '../models/InsectCatalog'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const home = new TabItem()
    home.index = 0
    home.name = 'home'
    home.label = '发现'
    tabs.push(home)
    const atlas = new TabItem()
    atlas.index = 1
    atlas.name = 'biz'
    atlas.label = '图鉴'
    tabs.push(atlas)
    const stats = new TabItem()
    stats.index = 2
    stats.name = 'chart'
    stats.label = '统计'
    tabs.push(stats)
    const mine = new TabItem()
    mine.index = 3
    mine.name = 'user'
    mine.label = '我的'
    tabs.push(mine)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State refreshToken: number = 0
  @State showEditor: boolean = false
  @State editId: string = ''
  @State showDetail: boolean = false
  @State obsId: string = ''
  @State showWiki: boolean = false
  @State wikiItem: InsectWikiItem = InsectCatalog.today()
  @State showWikiList: boolean = false
  onPrivacyRevoked: () => void = () => {}
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 16

  private openOverlay(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeOverlay(): void {
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private openEditor(id: string): void {
    this.editId = id
    this.showEditor = true
    this.openOverlay()
  }

  private openDetail(id: string): void {
    this.obsId = id
    this.showDetail = true
    this.openOverlay()
  }

  private openWiki(id: string): void {
    this.wikiItem = InsectCatalog.find(id)
    this.showWiki = true
    this.showWikiList = false
    this.openOverlay()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onStartObserve: (): void => this.openEditor(''),
            onOpenWiki: (id: string): void => this.openWiki(id),
            onOpenWikiList: (): void => {
              this.showWikiList = true
              this.openOverlay()
            },
            onOpenObs: (id: string): void => this.openDetail(id)
          }).layoutWeight(1)
        } else if (this.current === 1) {
          AtlasPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onOpenObs: (id: string): void => this.openDetail(id),
            onStartObserve: (): void => this.openEditor('')
          }).layoutWeight(1)
        } else if (this.current === 2) {
          StatsPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else {
          MinePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onPrivacyRevoked: (): void => this.onPrivacyRevoked()
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(this.tabBarHeight)
          .padding({ left: Theme.space.s3, right: Theme.space.s3, bottom: this.tabSafeBottom })
          .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s2 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(26,74,58,0.08)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showWikiList) {
        WikiListSheet({
          onBack: (): void => {
            this.showWikiList = false
            this.closeOverlay()
          },
          onOpen: (id: string): void => this.openWiki(id)
        })
      }
      if (this.showWiki) {
        InsectWikiPane({
          item: this.wikiItem,
          onBack: (): void => {
            this.showWiki = false
            this.closeOverlay()
          },
          onStartObserve: (): void => {
            this.showWiki = false
            this.openEditor('')
          }
        })
      }
      if (this.showDetail) {
        ObservationDetailPane({
          obsId: this.obsId,
          onBack: (): void => {
            this.showDetail = false
            this.closeOverlay()
            this.refreshToken++
          },
          onEdit: (): void => {
            this.showDetail = false
            this.openEditor(this.obsId)
          },
          onDeleted: (): void => {
            this.refreshToken++
          }
        })
      }
      if (this.showEditor) {
        ObserveEditorSheet({
          editId: this.editId,
          onClose: (): void => {
            this.showEditor = false
            this.closeOverlay()
            this.refreshToken++
          },
          onSaved: (): void => {
            this.refreshToken++
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 4 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(44)
      .height(26)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.caption)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 6 })
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      this.refreshToken++
    })
  }
}
