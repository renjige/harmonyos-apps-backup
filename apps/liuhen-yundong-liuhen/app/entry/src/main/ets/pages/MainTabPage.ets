import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { PlanPage } from './PlanPage'
import { HistoryPage } from './HistoryPage'
import { TracePage } from './TracePage'
import { MinePage } from './MinePage'
import { WorkoutSessionOverlay } from '../components/workout/WorkoutSessionOverlay'
import { WorkoutEditorSheet } from '../components/workout/WorkoutEditorSheet'
import { WorkoutDetailPane } from '../components/detail/WorkoutDetailPane'
import { SnapshotDetailPane } from '../components/detail/SnapshotDetailPane'
import { WeeklySnapshot, WorkoutRecord } from '../models/WorkoutModels'
import { DataBus } from '../services/DataBus'
import { WorkoutStore } from '../services/WorkoutStore'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '首页'],
      ['1', 'biz', '计划'],
      ['2', 'ai', '留痕'],
      ['3', 'chart', '历史'],
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
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @State current: number = 0
  @State refreshToken: number = 0
  @State showSession: boolean = false
  @State showDetail: boolean = false
  @State showEditor: boolean = false
  @State editorCreate: boolean = false
  @State showSnapshot: boolean = false
  @State detailRecord: WorkoutRecord = new WorkoutRecord()
  @State snapshot: WeeklySnapshot = new WeeklySnapshot()
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private tabs: TabItem[] = TabItem.all()
  private controller: TabsController = new TabsController()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 28

  private hideBar(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private showBar(): void {
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private finishSave(): void {
    this.closeOverlays()
    this.refreshToken++
  }

  private handleDataCleared(): void {
    this.refreshToken++
  }

  private onDataEpochChange(): void {
    this.refreshToken++
  }

  private openSession(): void {
    this.showSession = true
    this.hideBar()
  }

  private openDetail(rec: WorkoutRecord): void {
    this.detailRecord = rec
    this.showDetail = true
    this.hideBar()
  }

  private openEditor(isCreate: boolean): void {
    this.editorCreate = isCreate
    this.showEditor = true
    this.hideBar()
  }

  private openSnapshot(snap: WeeklySnapshot): void {
    void this.openSnapshotAsync(snap)
  }

  private async openSnapshotAsync(snap: WeeklySnapshot): Promise<void> {
    const saved = await WorkoutStore.loadSnapshots()
    for (const s of saved) {
      if (s.id === snap.id) {
        snap.pinned = s.pinned
        snap.reflection = s.reflection
      }
    }
    this.snapshot = snap
    this.showSnapshot = true
    this.hideBar()
  }

  private closeOverlays(): void {
    this.showSession = false
    this.showDetail = false
    this.showEditor = false
    this.showSnapshot = false
    this.showBar()
  }

  private bottomPad(): number {
    return this.tabBarHeight + this.tabSafeBottom + Theme.space.s4
  }

  build() {
    Stack() {
      Column() {
        Tabs({ index: this.current, controller: this.controller }) {
          TabContent() {
            HomePage({
              refreshToken: this.refreshToken,
              bottomInset: this.bottomPad(),
              onStartWorkout: (): void => { this.openSession() },
              onOpenDetail: (rec: WorkoutRecord): void => { this.openDetail(rec) }
            })
          }
          .tabBar('首页')
          TabContent() {
            PlanPage({
              refreshToken: this.refreshToken,
              bottomInset: this.bottomPad()
            })
          }
          .tabBar('计划')
          TabContent() {
            TracePage({
              refreshToken: this.refreshToken,
              bottomInset: this.bottomPad(),
              onOpenWorkout: (rec: WorkoutRecord): void => { this.openDetail(rec) },
              onOpenSnapshot: (snap: WeeklySnapshot): void => { this.openSnapshot(snap) },
              onManual: (): void => { this.openEditor(true) }
            })
          }
          .tabBar('留痕')
          TabContent() {
            HistoryPage({
              refreshToken: this.refreshToken,
              bottomInset: this.bottomPad(),
              onOpenDetail: (rec: WorkoutRecord): void => { this.openDetail(rec) }
            })
          }
          .tabBar('历史')
          TabContent() {
            MinePage({
              refreshToken: this.refreshToken,
              bottomInset: this.bottomPad(),
              onDataCleared: (): void => { this.handleDataCleared() }
            })
          }
          .tabBar('我的')
        }
        .barHeight(0)
        .onChange((idx: number): void => {
          this.current = idx
          DataBus.setTab(idx)
          this.refreshToken++
        })
        .layoutWeight(1)

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
          .shadow({ radius: 16, color: 'rgba(26,26,46,0.08)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.showSession) {
        WorkoutSessionOverlay({
          onClose: (): void => { this.closeOverlays() },
          onSaved: (): void => { this.finishSave() }
        })
      }

      if (this.showDetail) {
        WorkoutDetailPane({
          record: this.detailRecord,
          onClose: (): void => { this.closeOverlays() },
          onChanged: (): void => { this.finishSave() },
          onEdit: (): void => {
            this.showDetail = false
            this.openEditor(false)
          }
        })
      }

      if (this.showEditor) {
        WorkoutEditorSheet({
          isCreate: this.editorCreate,
          seed: this.detailRecord,
          onClose: (): void => { this.closeOverlays() },
          onSaved: (): void => { this.finishSave() }
        })
      }

      if (this.showSnapshot) {
        SnapshotDetailPane({
          snapshot: this.snapshot,
          onClose: (): void => { this.closeOverlays() },
          onSaved: (): void => { this.finishSave() }
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
        Theme.colors().brandPrimaryContainer : Color.Transparent)
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(11)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Regular)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick((): void => {
      this.current = t.index
      this.controller.changeIndex(t.index)
      DataBus.setTab(t.index)
      this.refreshToken++
    })
  }
}
