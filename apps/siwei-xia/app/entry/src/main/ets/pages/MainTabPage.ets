import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ThinkPage } from './ThinkPage'
import { MindMapPage } from './MindMapPage'
import { TagsPage } from './TagsPage'
import { MinePage } from './MinePage'
import { ThoughtDetailPane } from '../components/detail/ThoughtDetailPane'
import { ThoughtCard } from '../models/ThoughtModels'
import { ThoughtStore } from '../services/ThoughtStore'
import { ThinkStore } from '../services/ThinkStore'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '灵感'],
      ['1', 'ai', '思考'],
      ['2', 'chart', '导图'],
      ['3', 'biz', '标签'],
      ['4', 'user', '我的']
    ]
    for (const row of defs) {
      const t = new TabItem()
      t.index = parseInt(row[0], 10)
      t.name = row[1] as AppIconName
      t.label = row[2]
      tabs.push(t)
    }
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State reloadToken: number = 0
  @State detail: ThoughtCard = new ThoughtCard()
  @State showDetail: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('tbReload') tbReload: number = 0
  @Prop appName: string = '思维匣'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bump(): void {
    this.reloadToken = this.reloadToken + 1
  }

  private async openCard(id: string): Promise<void> {
    const card = await ThoughtStore.findById(id)
    if (card === undefined) {
      return
    }
    this.detail = card
    this.showDetail = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeDetail(): void {
    this.showDetail = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.bump()
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          HomePage({
            reloadToken: this.reloadToken + this.tbReload,
            onOpenCard: (id: string): void => { void this.openCard(id) }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 0 ? Visibility.Visible : Visibility.None)

          ThinkPage({
            reloadToken: this.reloadToken + this.tbReload,
            tabVisible: this.current === 1,
            onSwitchHome: (): void => {
              AppStorage.setOrCreate('tabBarHidden', false)
              this.current = 0
              this.bump()
            }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 1 ? Visibility.Visible : Visibility.None)

          MindMapPage({
            reloadToken: this.reloadToken + this.tbReload,
            onOpenCard: (id: string): void => { void this.openCard(id) }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 2 ? Visibility.Visible : Visibility.None)

          TagsPage({
            reloadToken: this.reloadToken + this.tbReload,
            onOpenCard: (id: string): void => { void this.openCard(id) }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 3 ? Visibility.Visible : Visibility.None)

          MinePage({
            appName: this.appName,
            reloadToken: this.reloadToken + this.tbReload,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => { this.onLogout() },
            onOpenCard: (id: string): void => { void this.openCard(id) }
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
          .padding({ bottom: 4 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showDetail) {
        ThoughtDetailPane({
          card: this.detail,
          cardId: this.detail.id,
          onClose: (): void => { this.closeDetail() },
          onChanged: (): void => { this.bump() }
        })
          .width('100%')
          .height('100%')
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
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      this.bump()
      if (t.index === 1) {
        void ThinkStore.syncGrowthToAppStorage()
      }
    })
  }
}
