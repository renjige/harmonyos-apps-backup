import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { TimelinePage } from './TimelinePage'
import { AlbumPage } from './AlbumPage'
import { FamilyCirclePage } from './FamilyCirclePage'
import { MinePage } from './MinePage'
import { PhotoUploadPage } from './PhotoUploadPage'
import { FilterListPage } from './FilterListPage'
import { SearchPage } from './SearchPage'
import { RecapPage } from './RecapPage'
import { PhotoDetailPane } from '../components/detail/PhotoDetailPane'
import { AlbumNav } from '../services/AlbumNav'

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
    t1.name = 'grid'
    t1.label = '相册'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'people'
    t2.label = '家庭圈'
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
  @State contentRefresh: number = 0
  @State uploadToken: number = 0
  @State detailToken: number = 0
  @State filterToken: number = 0
  @State searchToken: number = 0
  @State recapToken: number = 0
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('albumShowUpload') @Watch('onUploadFlag') showUpload: boolean = false
  @StorageLink('albumShowDetail') @Watch('onDetailFlag') showDetail: boolean = false
  @StorageLink('albumShowFilter') @Watch('onFilterFlag') showFilter: boolean = false
  @StorageLink('albumShowSearch') @Watch('onSearchFlag') showSearch: boolean = false
  @StorageLink('albumShowRecap') @Watch('onRecapFlag') showRecap: boolean = false
  @StorageLink('albumDetailId') detailId: string = ''
  @StorageLink('albumRev') @Watch('onStoreRev') storeRev: number = 0
  @Prop appName: string = '家用册'
  private tabs: TabItem[] = TabItem.all()

  onUploadFlag(): void {
    if (this.showUpload) {
      this.uploadToken += 1
    }
  }

  onDetailFlag(): void {
    if (this.showDetail) {
      this.detailToken += 1
    }
  }

  onFilterFlag(): void {
    if (this.showFilter) {
      this.filterToken += 1
    }
  }

  onSearchFlag(): void {
    if (this.showSearch) {
      this.searchToken += 1
    }
  }

  onRecapFlag(): void {
    if (this.showRecap) {
      this.recapToken += 1
    }
  }

  onStoreRev(): void {
    this.contentRefresh += 1
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2800)
  }

  private closeUpload(): void {
    AlbumNav.closeUpload()
    this.contentRefresh += 1
  }

  private closeDetail(): void {
    AlbumNav.closeDetail()
    this.contentRefresh += 1
  }

  private closeFilter(): void {
    AlbumNav.closeFilter()
    this.contentRefresh += 1
  }

  private closeSearch(): void {
    AlbumNav.closeSearch()
    this.contentRefresh += 1
  }

  private closeRecap(): void {
    AlbumNav.closeRecap()
    this.contentRefresh += 1
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)

      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        if (this.current === 0) {
          TimelinePage({
            refreshToken: this.contentRefresh,
            onToast: (text: string) => { this.showToast(text) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          AlbumPage({
            refreshToken: this.contentRefresh,
            onToast: (text: string) => { this.showToast(text) }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          FamilyCirclePage({
            refreshToken: this.contentRefresh,
            onToast: (text: string) => { this.showToast(text) }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onToast: (text: string) => { this.showToast(text) }
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
          .justifyContent(FlexAlign.SpaceAround)
          .alignItems(VerticalAlign.Center)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .padding({ bottom: 28 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showUpload) {
        PhotoUploadPage({
          refreshToken: this.uploadToken,
          onToast: (text: string) => { this.showToast(text) },
          onClose: (): void => { this.closeUpload() }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(14)
      }

      if (this.showDetail) {
        PhotoDetailPane({
          photoId: this.detailId,
          refreshToken: this.detailToken,
          onToast: (text: string) => { this.showToast(text) },
          onBack: (): void => { this.closeDetail() }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(15)
      }

      if (this.showFilter) {
        FilterListPage({
          refreshToken: this.filterToken,
          onBack: (): void => { this.closeFilter() }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(13)
      }

      if (this.showSearch) {
        SearchPage({
          refreshToken: this.searchToken,
          onBack: (): void => { this.closeSearch() }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(13)
      }

      if (this.showRecap) {
        RecapPage({
          refreshToken: this.recapToken,
          onBack: (): void => { this.closeRecap() }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(12)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
