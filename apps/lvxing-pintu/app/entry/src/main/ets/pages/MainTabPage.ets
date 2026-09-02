import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { FootprintPage } from './FootprintPage'
import { PuzzleHubPage } from './PuzzleHubPage'
import { FavoritesPage } from './FavoritesPage'
import { MinePage } from './MinePage'
import { PuzzleCreatePage } from './PuzzleCreatePage'
import { PuzzleDetailPane } from '../components/detail/PuzzleDetailPane'

class TabItem {
  index: number = 0
  name: AppIconName = 'map'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'map'
    t0.label = '足迹'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'star'
    t1.label = '拼图'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'heart'
    t2.label = '收藏'
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
  @State createToken: number = 0
  @State detailToken: number = 0
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('puzzleShowCreate') @Watch('onCreateFlag') showCreate: boolean = false
  @StorageLink('puzzleShowDetail') @Watch('onDetailFlag') showDetail: boolean = false
  @StorageLink('puzzleEditId') editId: string = ''
  @StorageLink('puzzleDetailId') detailId: string = ''
  @StorageLink('puzzleRev') @Watch('onStoreRev') storeRev: number = 0
  @Prop appName: string = '旅行拼图'
  private tabs: TabItem[] = TabItem.all()

  onCreateFlag(): void {
    if (this.showCreate) {
      this.createToken += 1
    }
  }

  onDetailFlag(): void {
    if (this.showDetail) {
      this.detailToken += 1
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
          FootprintPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
        } else if (this.current === 1) {
          PuzzleHubPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
        } else if (this.current === 2) {
          FavoritesPage({ refreshToken: this.contentRefresh }).layoutWeight(1)
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
        }
      }
      .width('100%')
      .height('100%')

      if (this.showCreate) {
        PuzzleCreatePage({
          editId: this.editId,
          refreshToken: this.createToken,
          onToast: (text: string) => { this.showToast(text) },
          onDone: (): void => { this.contentRefresh += 1 }
        })
          .width('100%')
          .height('100%')
          .zIndex(12)
      }

      if (this.showDetail) {
        PuzzleDetailPane({
          puzzleId: this.detailId,
          refreshToken: this.detailToken,
          onToast: (text: string) => { this.showToast(text) },
          onBack: (): void => { this.contentRefresh += 1 }
        })
          .width('100%')
          .height('100%')
          .zIndex(12)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
