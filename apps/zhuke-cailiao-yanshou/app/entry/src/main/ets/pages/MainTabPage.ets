import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { InspectListPage } from './InspectListPage'
import { RecordsPage } from './RecordsPage'
import { MinePage } from './MinePage'
import { InspectFormOverlay } from '../components/inspect/InspectFormOverlay'
import { DetailShell } from '../components/detail/DetailShell'
import { InspectDetailPane } from '../components/detail/InspectDetailPane'
import { ConfirmDialog } from '../components/inspect/ConfirmDialog'
import { GuideOverlay } from '../components/inspect/GuideOverlay'
import { FollowUpSheet } from '../components/inspect/FollowUpSheet'
import { FollowListOverlay } from '../components/inspect/FollowListOverlay'
import { BoardListOverlay } from '../components/inspect/BoardListOverlay'
import { InspectRecord } from '../models/InspectModels'
import { InspectService } from '../services/InspectService'
import { InspectNav } from '../services/InspectNav'
import { AuthService } from '../services/AuthService'
import { InspectLocalStore } from '../services/InspectLocalStore'

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
    t1.name = 'check'
    t1.label = '验收'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'biz'
    t2.label = '记录'
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
  @State showDelete: boolean = false
  @State detail: InspectRecord = new InspectRecord()
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('inspectNavMode') @Watch('onNavChange') navMode: string = ''
  @StorageLink('inspectNavId') @Watch('onNavChange') navId: string = ''
  @StorageLink('inspectTick') @Watch('onNavChange') tick: number = 0
  @StorageLink('inspectExtraMode') extraMode: string = ''
  @StorageLink('inspectExtraKey') extraKey: string = ''
  @StorageLink('inspectBoardFilter') boardFilter: string = ''
  @Prop appName: string = '筑科材料验收'
  @Prop themeTick: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.loadDetail()
  }

  onNavChange(): void {
    this.loadDetail()
  }

  private loadDetail(): void {
    if (this.navMode === 'detail' && this.navId.length > 0) {
      const row = InspectService.find(this.navId)
      if (row !== null) {
        this.detail = row
      }
    }
  }

  private openMineSettings(): void {
    this.current = 3
    AppStorage.setOrCreate('mineOpenSettings', true)
  }

  private async confirmDelete(): Promise<void> {
    const id = this.navId
    this.showDelete = false
    await InspectService.remove(id)
    InspectNav.close()
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          if (this.current === 0) {
            HomePage({
              refreshToken: this.tick + this.themeTick + this.themeEpoch,
              onOpenSettings: () => this.openMineSettings()
            })
          } else if (this.current === 1) {
            InspectListPage({ refreshToken: this.tick + this.themeTick + this.themeEpoch })
          } else if (this.current === 2) {
            RecordsPage({ refreshToken: this.tick + this.themeTick + this.themeEpoch })
          } else {
            MinePage({
              refreshToken: this.tick + this.themeTick + this.themeEpoch,
              appName: this.appName,
              onOpenLogin: () => this.onOpenLogin(),
              onLogout: () => {
                AuthService.logout()
                this.onLogout()
              }
            })
          }
        }
        .id(`zhuke_tabs_${this.current}_${this.themeEpoch}`)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeStrong })
        }
      }
      .width('100%')
      .height('100%')

      if (this.navMode === 'create' || this.navMode === 'edit') {
        InspectFormOverlay({
          recordId: this.navId,
          isEdit: this.navMode === 'edit'
        })
          .width('100%')
          .height('100%')
      }

      if (this.navMode === 'detail') {
        Column() {
          DetailShell({
            title: '验收详情',
            onBack: () => InspectNav.close()
          }) {
            InspectDetailPane({
              record: this.detail,
              stamp: this.tick,
              onEdit: () => InspectNav.openEdit(this.navId),
              onDelete: () => { this.showDelete = true }
            })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.extraMode === 'guide') {
        GuideOverlay({ category: this.extraKey })
          .width('100%')
          .height('100%')
      }

      if (this.extraMode === 'followList') {
        FollowListOverlay()
          .width('100%')
          .height('100%')
      }

      if (this.extraMode === 'follow') {
        FollowUpSheet({ recordId: this.extraKey })
          .width('100%')
          .height('100%')
      }

      if (this.extraMode === 'board') {
        BoardListOverlay({
          mode: this.extraKey,
          boardKey: this.boardFilter
        })
          .width('100%')
          .height('100%')
      }

      if (this.showDelete) {
        ConfirmDialog({
          title: '删除记录',
          message: '确定删除这条验收记录吗？',
          confirmLabel: '删除',
          onCancel: () => { this.showDelete = false },
          onConfirm: () => { void this.confirmDelete() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .opacity(this.themeTick >= 0 ? 1 : 1)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandOnPrimary : Theme.colors().textPrimary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimary : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      if (t.index === 0) {
        InspectLocalStore.bumpTick()
      }
    })
  }
}
