import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { CapsulePage } from './CapsulePage'
import { StatsPage } from './StatsPage'
import { MinePage } from './MinePage'
import { ComposePage } from './ComposePage'
import { TagManagePage } from './TagManagePage'
import { EntryDetailPane } from '../components/detail/EntryDetailPane'
import { AuthService } from '../services/AuthService'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '一隅'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'star'
    t1.label = '胶囊'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '纪事'
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
  @State composeToken: number = 0
  @State detailToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('youyuShowCompose') @Watch('onComposeFlag') showCompose: boolean = false
  @StorageLink('youyuShowDetail') @Watch('onDetailFlag') showDetail: boolean = false
  @StorageLink('youyuShowTags') showTags: boolean = false
  @StorageLink('youyuComposeId') composeId: string = ''
  @StorageLink('youyuDetailId') detailId: string = ''
  @StorageLink('youyuOpenMineSettings') @Watch('onMineJump') mineJump: boolean = false
  @StorageLink('darkModeOn') @Watch('onDarkChange') darkModeOn: boolean = false
  @Prop company: string = '悠隅生活'
  @Prop appName: string = '悠隅纪'
  @Prop tagline: string = '静谧一隅，温柔记录生活美好瞬间的私密智慧空间'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
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

  onMineJump(): void {
    if (this.mineJump) {
      this.current = 3
    }
  }

  onDarkChange(): void {
    Theme.setColorMode(this.darkModeOn ? 'dark' : 'light')
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          HomePage({
            appName: this.appName,
            tagline: this.tagline
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 0 ? Visibility.Visible : Visibility.Hidden)

          CapsulePage()
            .width('100%')
            .height('100%')
            .visibility(this.current === 1 ? Visibility.Visible : Visibility.Hidden)

          StatsPage()
            .width('100%')
            .height('100%')
            .visibility(this.current === 2 ? Visibility.Visible : Visibility.Hidden)

          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => {
              void AuthService.logout()
              this.onLogout()
            }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 3 ? Visibility.Visible : Visibility.Hidden)
        }
        .width('100%')
        .layoutWeight(1)

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
          editId: this.composeId,
          refreshToken: this.composeToken
        })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }

      if (this.showDetail) {
        EntryDetailPane({
          itemId: this.detailId
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }

      if (this.showTags) {
        TagManagePage()
          .width('100%')
          .height('100%')
          .zIndex(17)
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
