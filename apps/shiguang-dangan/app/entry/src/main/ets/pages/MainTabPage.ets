import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { ArchiveDetailPane } from '../components/detail/ArchiveDetailPane'
import { NodeDetailPane } from '../components/detail/NodeDetailPane'
import { CreateArchiveSheet } from '../components/detail/CreateArchiveSheet'
import { NodeEditorSheet } from '../components/detail/NodeEditorSheet'
import { ProductIntroOverlay } from '../components/onboarding/ProductIntroOverlay'
import { GlobalSearchSheet } from '../components/search/GlobalSearchSheet'
import { InspirationEditorSheet } from '../components/life/InspirationEditorSheet'
import { MomentEditorSheet } from '../components/life/MomentEditorSheet'
import { ThemeAlbumListSheet } from '../components/album/ThemeAlbumListSheet'
import { ChecklistSheet } from '../components/checklist/ChecklistSheet'
import { ExperienceLibrarySheet } from '../components/experience/ExperienceLibrarySheet'
import { FavoritesCenterSheet } from '../components/favorites/FavoritesCenterSheet'
import { PlanDetailPane } from '../components/plan/PlanDetailPane'
import { HomePage } from './HomePage'
import { ArchiveLibraryPage } from './ArchiveLibraryPage'
import { PlanPage } from './PlanPage'
import { ReviewPage } from './ReviewPage'
import { MinePage } from './MinePage'
import { ArchiveDetailNav } from '../services/ArchiveDetailNav'
import { LifeStore } from '../services/LifeStore'

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
    t1.name = 'biz'
    t1.label = '档案'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'check'
    t2.label = '计划'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'calendar'
    t3.label = '回顾'
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
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State refreshToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('archiveDetailId') archiveDetailId: string = ''
  @StorageLink('nodeDetailId') nodeDetailId: string = ''
  @StorageLink('createArchiveOpen') createArchiveOpen: boolean = false
  @StorageLink('nodeEditorOpen') nodeEditorOpen: boolean = false
  @StorageLink('searchOpen') searchOpen: boolean = false
  @StorageLink('inspirationEditorOpen') inspirationEditorOpen: boolean = false
  @StorageLink('momentEditorOpen') momentEditorOpen: boolean = false
  @StorageLink('themeAlbumListOpen') themeAlbumListOpen: boolean = false
  @StorageLink('checklistSheetOpen') checklistSheetOpen: boolean = false
  @StorageLink('experienceLibraryOpen') experienceLibraryOpen: boolean = false
  @StorageLink('favoritesCenterOpen') favoritesCenterOpen: boolean = false
  @StorageLink('planDetailId') planDetailId: string = ''
  @State showOnboarding: boolean = false
  onPrivacyRevoked: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 16

  aboutToAppear(): void {
    void this.checkOnboarding()
  }

  private async checkOnboarding(): Promise<void> {
    const seen = await LifeStore.isOnboardingSeen()
    this.showOnboarding = !seen
  }

  private bumpRefresh(): void {
    this.refreshToken++
  }

  private switchTab(index: number): void {
    AppStorage.setOrCreate('tabBarHidden', false)
    this.current = index
    this.refreshToken++
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onSwitchTab: (index: number): void => { this.switchTab(index) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          ArchiveLibraryPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else if (this.current === 2) {
          PlanPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else if (this.current === 3) {
          ReviewPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else {
          MinePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onPrivacyRevoked: (): void => { this.onPrivacyRevoked() },
            onDataChanged: (): void => { this.bumpRefresh() },
            onSwitchTab: (index: number): void => { this.switchTab(index) }
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
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(24,35,51,0.08)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.archiveDetailId.length > 0) {
        DetailShell({
          title: '档案详情',
          onClose: (): void => { ArchiveDetailNav.closeArchiveDetail() },
          body: this.ArchiveDetailBody
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.nodeDetailId.length > 0) {
        DetailShell({
          title: '节点详情',
          onClose: (): void => { ArchiveDetailNav.closeNodeDetail() },
          body: this.NodeDetailBody
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.createArchiveOpen) {
        CreateArchiveSheet({
          onSaved: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(55)
      }

      if (this.nodeEditorOpen) {
        NodeEditorSheet({
          onSaved: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(56)
      }

      if (this.searchOpen) {
        GlobalSearchSheet({
          onClose: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
      }

      if (this.inspirationEditorOpen) {
        InspirationEditorSheet({
          onSaved: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
      }

      if (this.momentEditorOpen) {
        MomentEditorSheet({
          onSaved: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
      }

      if (this.themeAlbumListOpen) {
        ThemeAlbumListSheet({
          onClose: (): void => {
            AppStorage.setOrCreate('themeAlbumListOpen', false)
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onChanged: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(55)
      }

      if (this.checklistSheetOpen) {
        ChecklistSheet({
          onClose: (): void => {
            AppStorage.setOrCreate('checklistSheetOpen', false)
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onChanged: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(55)
      }

      if (this.experienceLibraryOpen) {
        ExperienceLibrarySheet({
          onClose: (): void => {
            AppStorage.setOrCreate('experienceLibraryOpen', false)
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onChanged: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(55)
      }

      if (this.favoritesCenterOpen) {
        FavoritesCenterSheet({
          onClose: (): void => {
            AppStorage.setOrCreate('favoritesCenterOpen', false)
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onChanged: (): void => { this.bumpRefresh() }
        })
          .width('100%')
          .height('100%')
          .zIndex(55)
      }

      if (this.planDetailId.length > 0) {
        DetailShell({
          title: '计划详情',
          onClose: (): void => {
            AppStorage.setOrCreate('planDetailId', '')
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          body: this.PlanDetailBody
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.showOnboarding) {
        ProductIntroOverlay({
          onDismiss: (): void => { this.showOnboarding = false }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  ArchiveDetailBody() {
    ArchiveDetailPane({
      refreshToken: this.refreshToken,
      onChanged: (): void => { this.bumpRefresh() }
    })
  }

  @Builder
  NodeDetailBody() {
    NodeDetailPane({
      refreshToken: this.refreshToken,
      onChanged: (): void => { this.bumpRefresh() }
    })
  }

  @Builder
  PlanDetailBody() {
    PlanDetailPane({
      planId: this.planDetailId,
      onChanged: (): void => { this.bumpRefresh() },
      onDeleted: (): void => {
        AppStorage.setOrCreate('planDetailId', '')
        AppStorage.setOrCreate('tabBarHidden', false)
        this.bumpRefresh()
      }
    })
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
      this.switchTab(t.index)
    })
  }
}
