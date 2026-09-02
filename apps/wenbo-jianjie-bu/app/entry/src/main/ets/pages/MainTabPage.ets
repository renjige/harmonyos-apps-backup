import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { RecordPage } from './RecordPage'
import { OrganizePage } from './OrganizePage'
import { InsightPage } from './InsightPage'
import { SettingsPage } from './SettingsPage'
import { EditorSheet } from '../components/book/EditorSheet'
import { EntryDetailPane } from '../components/detail/EntryDetailPane'
import { AppButton } from '../components/design-system/AppButton'
import { InsightStore } from '../services/InsightStore'
import { InsightToolHost } from '../components/book/InsightToolHost'
import { GrowthOverlayHost } from '../components/book/GrowthOverlayHost'
import { AdvancedFilter } from '../models/GrowthModels'
import { AchievementService } from '../services/AchievementService'

class TabItem {
  index: number = 0
  name: AppIconName = 'book'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const a = new TabItem()
    a.index = 0
    a.name = 'book'
    a.label = '记录'
    tabs.push(a)
    const b = new TabItem()
    b.index = 1
    b.name = 'grid'
    b.label = '整理'
    tabs.push(b)
    const c = new TabItem()
    c.index = 2
    c.name = 'sparkle'
    c.label = '成长'
    tabs.push(c)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('achievementToastAt') @Watch('onAchievementToast') achievementToastAt: number = 0
  @StorageLink('lastAchievementUnlock') lastAchievementUnlock: string = ''
  @State current: number = 0
  @State refreshToken: number = 0
  @State showEditor: boolean = false
  @State editorId: string = ''
  @State showDetail: boolean = false
  @State detailId: string = ''
  @State showSettings: boolean = false
  @State pendingDeleteId: string = ''
  @State toastText: string = ''
  @State toolKind: string = ''
  @State overlayKind: string = ''
  @State advancedFilter: AdvancedFilter = new AdvancedFilter()
  onPrivacyRevoked: () => void = () => {}
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('themeRevision') themeRevision: number = 0
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 56
  private readonly fabClearance: number = 72

  onAchievementToast(): void {
    if (this.lastAchievementUnlock.length > 0) {
      this.showToast(`解锁徽章：${AchievementService.nameForId(this.lastAchievementUnlock)}`)
      AppStorage.setOrCreate('lastAchievementUnlock', '')
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private bumpList(): void {
    this.refreshToken++
    AppStorage.setOrCreate('entryStamp', Date.now())
  }

  private openCreate(): void {
    this.editorId = ''
    this.showEditor = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openDetail(id: string): void {
    this.detailId = id
    this.showDetail = true
    this.overlayKind = ''
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeOverlays(): void {
    this.showEditor = false
    this.showDetail = false
    this.showSettings = false
    this.toolKind = ''
    this.overlayKind = ''
    AppStorage.setOrCreate('tabBarHidden', false)
    this.bumpList()
  }

  private openTool(kind: string): void {
    this.toolKind = kind
    this.overlayKind = ''
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeTool(): void {
    this.toolKind = ''
    AppStorage.setOrCreate('tabBarHidden', false)
    this.bumpList()
  }

  private openOverlay(kind: string): void {
    this.overlayKind = kind
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeGrowthOverlay(): void {
    this.overlayKind = ''
    if (!this.showDetail && !this.showEditor && !this.showSettings && this.toolKind.length === 0) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    this.bumpList()
  }

  private openFromTool(id: string): void {
    this.toolKind = ''
    this.openDetail(id)
  }

  private openFromOverlay(id: string): void {
    this.overlayKind = ''
    this.openDetail(id)
  }

  private applyFilter(f: AdvancedFilter): void {
    this.advancedFilter = f
    this.overlayKind = ''
    AppStorage.setOrCreate('tabBarHidden', false)
    this.bumpList()
    this.showToast('筛选已应用')
  }

  private async confirmDelete(): Promise<void> {
    if (this.pendingDeleteId.length === 0) {
      return
    }
    await InsightStore.deleteEntry(this.pendingDeleteId)
    this.pendingDeleteId = ''
    this.showToast('已删除')
    this.bumpList()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          RecordPage({
            refreshToken: this.refreshToken,
            advancedFilter: this.advancedFilter,
            bottomInset: this.fabClearance,
            onCreate: (): void => { this.openCreate() },
            onOpen: (id: string) => { this.openDetail(id) },
            onAskDelete: (id: string) => { this.pendingDeleteId = id },
            onOpenOverlay: (kind: string) => { this.openOverlay(kind) },
            onOpenTool: (kind: string) => { this.openTool(kind) },
            onToast: (msg: string) => { this.showToast(msg) }
          })
            .layoutWeight(1)
            .width('100%')
        } else if (this.current === 1) {
          OrganizePage({
            refreshToken: this.refreshToken,
            bottomInset: 16,
            onOpen: (id: string) => { this.openDetail(id) }
          })
            .layoutWeight(1)
            .width('100%')
        } else {
          InsightPage({
            refreshToken: this.refreshToken,
            bottomInset: 16,
            onOpenSettings: (): void => {
              this.showSettings = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenMine: (): void => { this.openOverlay('mine') },
            onOpenAchievements: (): void => { this.openOverlay('achievement') },
            onOpenActivity: (): void => { this.openOverlay('activity') },
            onOpen: (id: string) => { this.openDetail(id) },
            onOpenTool: (kind: string) => { this.openTool(kind) }
          })
            .layoutWeight(1)
            .width('100%')
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(this.tabBarHeight)
          .padding({ left: Theme.space.s3, right: Theme.space.s3, bottom: Theme.space.s2 })
          .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s2 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(44,44,44,0.08)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.showDetail) {
        EntryDetailPane({
          entryId: this.detailId,
          onClose: (): void => { this.closeOverlays() },
          onEdit: (id: string) => {
            this.showDetail = false
            this.editorId = id
            this.showEditor = true
          },
          onDeleted: (): void => {
            this.showToast('已删除')
            this.closeOverlays()
          },
          onOpenRelated: (id: string) => {
            this.detailId = id
          },
          onMutated: (): void => { this.bumpList() }
        })
        .width('100%')
        .height('100%')
      }

      if (this.showEditor) {
        EditorSheet({
          entryId: this.editorId,
          onClose: (): void => { this.closeOverlays() },
          onSaved: (): void => {
            this.showToast('已保存')
            this.closeOverlays()
          }
        })
        .width('100%')
        .height('100%')
      }

      if (this.toolKind.length > 0 && !this.showDetail && !this.showEditor) {
        InsightToolHost({
          toolKind: this.toolKind,
          onClose: (): void => { this.closeTool() },
          onSaved: (): void => {
            this.showToast('已写入见解簿')
            this.closeTool()
          },
          onOpen: (id: string) => { this.openFromTool(id) },
          onMutated: (): void => { this.bumpList() }
        })
        .width('100%')
        .height('100%')
      }

      if (this.overlayKind.length > 0 && !this.showDetail && !this.showEditor && this.toolKind.length === 0) {
        GrowthOverlayHost({
          overlayKind: this.overlayKind,
          filter: this.advancedFilter,
          onClose: (): void => { this.closeGrowthOverlay() },
          onOpen: (id: string) => { this.openFromOverlay(id) },
          onOpenTool: (kind: string) => {
            this.overlayKind = ''
            this.openTool(kind)
          },
          onOpenSettings: (): void => {
            this.overlayKind = ''
            this.showSettings = true
          },
          onApplyFilter: (f: AdvancedFilter) => { this.applyFilter(f) },
          onOpenAchievements: (): void => { this.openOverlay('achievement') }
        })
        .width('100%')
        .height('100%')
      }

      if (this.showSettings) {
        SettingsPage({
          refreshToken: this.refreshToken,
          onClose: (): void => { this.closeOverlays() },
          onPrivacyRevoked: (): void => {
            this.closeOverlays()
            this.onPrivacyRevoked()
          }
        })
        .width('100%')
        .height('100%')
      }

      if (this.pendingDeleteId.length > 0) {
        Column() {
          Column({ space: Theme.space.s4 }) {
            Text('删除这条见解？')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('左滑删除需二次确认，删除后无法恢复。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
            AppButton({
              label: '确认删除',
              variant: 'danger',
              onTap: (): void => { void this.confirmDelete() }
            })
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.pendingDeleteId = '' }
            })
          }
          .width('86%')
          .padding(Theme.space.s6)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().overlayScrim)
        .zIndex(30)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontColor('#FFFFFF')
          .fontSize(Theme.type.footnote)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
    .opacity(this.themeRevision >= 0 ? 1 : 1)
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
