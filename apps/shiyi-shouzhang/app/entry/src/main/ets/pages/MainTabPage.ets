import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { JournalPage } from './JournalPage'
import { ReviewPage } from './ReviewPage'
import { MinePage } from './MinePage'
import { ComposePage } from './ComposePage'
import { PickupGalleryPage } from './PickupGalleryPage'
import { TagManagePage } from './TagManagePage'
import { JournalDetailPane } from '../components/detail/JournalDetailPane'

class TabItem {
  index: number = 0
  name: AppIconName = 'star'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'star'
    t0.label = '拾意'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'book'
    t1.label = '手账'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'calendar'
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
  @State contentRefresh: number = 0
  @State composeToken: number = 0
  @State detailToken: number = 0
  @State pickupToken: number = 0
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('shiyiShowCompose') @Watch('onComposeFlag') showCompose: boolean = false
  @StorageLink('shiyiShowDetail') @Watch('onDetailFlag') showDetail: boolean = false
  @StorageLink('shiyiShowPickup') @Watch('onPickupFlag') showPickup: boolean = false
  @StorageLink('shiyiShowTags') showTags: boolean = false
  @StorageLink('shiyiComposeId') composeId: string = ''
  @StorageLink('shiyiComposeDate') composeDate: string = ''
  @StorageLink('shiyiDetailId') detailId: string = ''
  @StorageLink('shiyiRev') @Watch('onStoreRev') storeRev: number = 0
  @Prop company: string = '拾意生活'
  @Prop appName: string = '手账拾意'
  @Prop tagline: string = '拾起生活里的小事，记录值得留下的心意。'
  private tabs: TabItem[] = TabItem.all()

  onComposeFlag(): void {
    if (this.showCompose) {
      this.composeToken += 1
    }
  }

  onDetailFlag(): void {
    if (this.showDetail) {
      this.detailToken += 1
    }
  }

  onPickupFlag(): void {
    if (this.showPickup) {
      this.pickupToken += 1
    }
  }

  onStoreRev(): void {
    this.contentRefresh += 1
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.contentRefresh,
            onToast: (text: string) => {
              this.showToast(text)
            }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          JournalPage({
            refreshToken: this.contentRefresh
          }).layoutWeight(1)
        } else if (this.current === 2) {
          ReviewPage({
            refreshToken: this.contentRefresh
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.contentRefresh,
            onToast: (text: string) => {
              this.showToast(text)
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

      if (this.showCompose) {
        ComposePage({
          entryId: this.composeId,
          entryDate: this.composeDate,
          openToken: this.composeToken,
          onSaved: (message: string) => {
            this.showToast(message)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showDetail) {
        JournalDetailPane({
          itemId: this.detailId,
          openToken: this.detailToken,
          onToast: (text: string) => {
            this.showToast(text)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showPickup) {
        PickupGalleryPage({
          refreshToken: this.pickupToken,
          onToast: (text: string) => {
            this.showToast(text)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(17)
      }

      if (this.showTags) {
        TagManagePage({
          onToast: (text: string) => {
            this.showToast(text)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(17)
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
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
