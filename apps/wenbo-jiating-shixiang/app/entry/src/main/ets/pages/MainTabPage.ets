import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { TasksPage } from './TasksPage'
import { CalendarPage } from './CalendarPage'
import { StatsPage } from './StatsPage'
import { MinePage } from './MinePage'
import { TaskFormOverlay } from '../components/family/TaskFormOverlay'
import { TaskDetailPane } from '../components/family/TaskDetailPane'
import { CategoryDetailPane } from '../components/family/CategoryDetailPane'
import { ConfirmSheet } from '../components/family/ConfirmSheet'
import { FamilyCategory, FamilyTaskItem } from '../models/FamilyTaskModels'
import { TaskService } from '../services/TaskService'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem(); t0.index = 0; t0.name = 'home'; t0.label = '首页'; tabs.push(t0)
    const t1 = new TabItem(); t1.index = 1; t1.name = 'biz'; t1.label = '事项'; tabs.push(t1)
    const t2 = new TabItem(); t2.index = 2; t2.name = 'calendar'; t2.label = '日历'; tabs.push(t2)
    const t3 = new TabItem(); t3.index = 3; t3.name = 'chart'; t3.label = '统计'; tabs.push(t3)
    const t4 = new TabItem(); t4.index = 4; t4.name = 'user'; t4.label = '我的'; tabs.push(t4)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showForm: boolean = false
  @State formEdit: boolean = false
  @State formSeed: FamilyTaskItem = new FamilyTaskItem()
  @State showDetail: boolean = false
  @State detail: FamilyTaskItem = new FamilyTaskItem()
  @State showCat: boolean = false
  @State category: FamilyCategory = new FamilyCategory()
  @State showConfirm: boolean = false
  @State tick: number = 0
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('themeRevision') @Watch('onThemeRevision') themeRevision: number = 0
  @Prop appName: string = '家庭事项'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private onThemeRevision(): void {
    this.bump()
  }

  private bump(): void {
    this.tick += 1
  }

  private toast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private openAdd(): void {
    this.formEdit = false
    this.formSeed = new FamilyTaskItem()
    this.showForm = true
    this.hideBar(true)
  }

  private openDetail(item: FamilyTaskItem): void {
    this.detail = item
    this.showDetail = true
    this.hideBar(true)
  }

  private async toggle(item: FamilyTaskItem): Promise<void> {
    await TaskService.toggle(item)
    if (this.detail.id === item.id) {
      this.detail = TaskService.cloneItem(item)
    }
    this.bump()
  }

  private async saveForm(draft: FamilyTaskItem): Promise<void> {
    if (this.formEdit && draft.id.length > 0) {
      const row = this.detail
      row.title = draft.title
      row.category = draft.category
      row.date = draft.date
      row.time = draft.time
      row.reminder = draft.reminder
      row.repeatType = draft.repeatType
      await TaskService.update(row)
    } else {
      await TaskService.create(draft)
    }
    this.showForm = false
    this.hideBar(this.showDetail)
    this.bump()
    this.toast('已记下')
  }

  private async confirmDelete(): Promise<void> {
    await TaskService.remove(this.detail.id)
    this.showConfirm = false
    this.showDetail = false
    this.hideBar(false)
    this.bump()
    this.toast('已删除')
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.tick,
            onAdd: () => this.openAdd(),
            onOpen: (it: FamilyTaskItem) => this.openDetail(it),
            onToggle: (it: FamilyTaskItem) => { void this.toggle(it) },
            onNotify: () => { this.current = 4 }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          TasksPage({
            refreshToken: this.tick,
            onOpen: (it: FamilyTaskItem) => this.openDetail(it),
            onToggle: (it: FamilyTaskItem) => { void this.toggle(it) },
            onAdd: () => this.openAdd()
          }).layoutWeight(1)
        } else if (this.current === 2) {
          CalendarPage({
            refreshToken: this.tick,
            onOpen: (it: FamilyTaskItem) => this.openDetail(it),
            onToggle: (it: FamilyTaskItem) => { void this.toggle(it) },
            onAdd: () => this.openAdd()
          }).layoutWeight(1)
        } else if (this.current === 3) {
          StatsPage({
            refreshToken: this.tick,
            onOpenCategory: (c: FamilyCategory) => {
              this.category = c
              this.showCat = true
              this.hideBar(true)
            }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => this.onLogout()
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => { this.TabBarItem(t) }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showDetail) {
        TaskDetailPane({
          item: this.detail,
          onClose: () => { this.showDetail = false; this.hideBar(false) },
          onEdit: () => { this.formEdit = true; this.formSeed = this.detail; this.showForm = true },
          onComplete: () => { void this.toggle(this.detail).then(() => { this.showDetail = false; this.hideBar(false) }) },
          onDelete: () => { this.showConfirm = true }
        })
      }

      if (this.showCat) {
        CategoryDetailPane({
          item: this.category,
          onClose: () => { this.showCat = false; this.hideBar(false) },
          onAdd: () => { this.showCat = false; this.openAdd() }
        })
      }

      if (this.showForm) {
        TaskFormOverlay({
          isEdit: this.formEdit,
          seed: this.formSeed,
          onClose: () => { this.showForm = false; this.hideBar(this.showDetail) },
          onSave: (d: FamilyTaskItem) => { void this.saveForm(d) }
        })
      }

      if (this.showConfirm) {
        ConfirmSheet({
          title: '删除这件事？',
          message: '删除后无法恢复。',
          onCancel: () => { this.showConfirm = false },
          onConfirm: () => { void this.confirmDelete() }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.sm)
          .margin({ top: 40 })
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
          iconSize: 22,
          active: this.current === t.index,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(44)
      .height(28)
      .borderRadius(14)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : '#00000000')
      .justifyContent(FlexAlign.Center)
      Text(t.label)
        .fontSize(10)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => { this.current = t.index })
  }
}
