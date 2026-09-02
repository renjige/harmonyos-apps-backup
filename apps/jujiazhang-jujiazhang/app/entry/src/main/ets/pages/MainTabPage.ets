import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ItemsPage } from './ItemsPage'
import { LifeHubPage } from './LifeHubPage'
import { MinePage } from './MinePage'
import { SearchHubPage } from './SearchHubPage'
import { FavoritesPage } from './FavoritesPage'
import { GrowthHubPage } from './GrowthHubPage'
import { DiscoverHubPage } from './DiscoverHubPage'
import { CalendarPage } from './CalendarPage'
import { TaskFormOverlay } from '../components/family/TaskFormOverlay'
import { TaskDetailPane } from '../components/detail/TaskDetailPane'
import { ItemDetailPane } from '../components/detail/ItemDetailPane'
import { ItemFormOverlay } from '../components/jujia/ItemFormOverlay'
import { MembersPane } from '../components/jujia/MembersPane'
import { ConfirmSheet } from '../components/family/ConfirmSheet'
import { FamilyTaskItem } from '../models/FamilyTaskModels'
import { HomeItem, SearchHit, FavoriteRecord, ActivityEvent } from '../models/JujiaModels'
import { TaskService } from '../services/TaskService'
import { ItemService } from '../services/ItemService'
import { MemoService } from '../services/MemoService'
import { ChecklistService } from '../services/ChecklistService'
import { TaskLocalStore } from '../services/TaskLocalStore'
import { FavoriteService } from '../services/FavoriteService'
import { GoalService } from '../services/GoalService'
import { GoalFormOverlay } from '../components/jujia/GoalFormOverlay'
import { ReminderService } from '../services/ReminderService'
import { ScenePackService } from '../services/ScenePackService'
import { CategorySuggest } from '../services/CategorySuggest'
import { common } from '@kit.AbilityKit'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem(); t0.index = 0; t0.name = 'search'; t0.label = '发现'; tabs.push(t0)
    const t1 = new TabItem(); t1.index = 1; t1.name = 'home'; t1.label = '总览'; tabs.push(t1)
    const t2 = new TabItem(); t2.index = 2; t2.name = 'grid'; t2.label = '物品'; tabs.push(t2)
    const t3 = new TabItem(); t3.index = 3; t3.name = 'edit'; t3.label = '生活'; tabs.push(t3)
    const t4 = new TabItem(); t4.index = 4; t4.name = 'user'; t4.label = '我的'; tabs.push(t4)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showTaskForm: boolean = false
  @State taskFormEdit: boolean = false
  @State taskFormSeed: FamilyTaskItem = new FamilyTaskItem()
  @State showTaskDetail: boolean = false
  @State taskDetail: FamilyTaskItem = new FamilyTaskItem()
  @State showItemForm: boolean = false
  @State itemFormEdit: boolean = false
  @State itemFormSeed: HomeItem = new HomeItem()
  @State showItemDetail: boolean = false
  @State itemDetail: HomeItem = new HomeItem()
  @State showMembers: boolean = false
  @State showSearch: boolean = false
  @State showFavorites: boolean = false
  @State showGrowth: boolean = false
  @State showGoalForm: boolean = false
  @State confirmKind: string = ''
  @State showConfirm: boolean = false
  @State tick: number = 0
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('themeRevision') @Watch('onThemeRevision') themeRevision: number = 0
  @StorageLink('accessToken') @Watch('onAuthChange') accessToken: string = ''
  @StorageLink('mainTabIndex') @Watch('onMainTabPick') mainTabIndex: number = 0
  @Prop appName: string = '居家章'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private onThemeRevision(): void {
    this.bump()
  }

  private onAuthChange(): void {
    void TaskService.onAuthChanged().then(() => {
      this.bump()
    })
  }

  private onMainTabPick(): void {
    if (this.mainTabIndex >= 0 && this.mainTabIndex <= 4) {
      this.current = this.mainTabIndex
    }
  }

  private switchTab(index: number): void {
    this.current = index
    AppStorage.setOrCreate('mainTabIndex', index)
  }

  private openLifeSegment(segment: string): void {
    AppStorage.setOrCreate('lifeHubSegment', segment)
    this.switchTab(3)
  }

  private bump(): void {
    this.tick += 1
  }

  private toast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private host(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private anyOverlayOpen(): boolean {
    return this.showTaskDetail || this.showItemDetail || this.showMembers || this.showSearch ||
      this.showFavorites || this.showGrowth || this.showGoalForm
  }

  private openDiscover(): void {
    this.switchTab(0)
  }

  private openSearch(): void {
    this.showSearch = true
    this.hideBar(true)
  }

  private openFavorites(): void {
    this.showFavorites = true
    this.hideBar(true)
  }

  private openGrowth(): void {
    this.showGrowth = true
    this.hideBar(true)
  }

  private openGoalForm(): void {
    this.showGoalForm = true
    this.hideBar(true)
  }

  private async saveGoalForm(title: string, target: number): Promise<void> {
    if (title.trim().length === 0) {
      this.toast('请填写目标标题')
      return
    }
    await GoalService.create(title, target, '项')
    this.showGoalForm = false
    this.hideBar(this.anyOverlayOpen())
    this.bump()
    this.toast('家庭目标已创建')
  }

  private async openSearchHit(hit: SearchHit): Promise<void> {
    this.showSearch = false
    if (hit.entityType === 'task') {
      for (const row of TaskLocalStore.tasks()) {
        if (row.id === hit.entityId) {
          this.openTaskDetail(row)
          return
        }
      }
    }
    if (hit.entityType === 'item') {
      const item = await ItemService.find(hit.entityId)
      if (item !== null) {
        this.openItemDetail(item)
        return
      }
    }
    if (hit.entityType === 'memo') {
      this.openLifeSegment('memo')
      return
    }
    if (hit.entityType === 'checklist') {
      this.openLifeSegment('checklist')
      return
    }
    if (hit.entityType === 'diary') {
      this.openLifeSegment('diary')
      return
    }
    this.hideBar(false)
  }

  private async openFavorite(fav: FavoriteRecord): Promise<void> {
    const hit = new SearchHit()
    hit.entityType = fav.targetType
    hit.entityId = fav.targetId
    this.showFavorites = false
    await this.openSearchHit(hit)
  }

  private async openActivity(ev: ActivityEvent): Promise<void> {
    const hit = new SearchHit()
    hit.entityType = ev.entityType
    hit.entityId = ev.entityId
    await this.openSearchHit(hit)
  }

  private async toggleTaskFavorite(): Promise<void> {
    const ok = await FavoriteService.toggle('task', this.taskDetail.id, this.taskDetail.title)
    this.toast(ok ? '已加入收藏' : '已取消收藏')
    this.bump()
  }

  private async toggleItemFavorite(): Promise<void> {
    const ok = await FavoriteService.toggle('item', this.itemDetail.id, this.itemDetail.name)
    this.toast(ok ? '已加入收藏' : '已取消收藏')
    this.bump()
  }

  private openMembers(): void {
    this.showMembers = true
    this.hideBar(true)
  }

  private openAddTask(): void {
    this.taskFormEdit = false
    this.taskFormSeed = new FamilyTaskItem()
    this.showTaskForm = true
    this.hideBar(true)
  }

  private openTaskDetail(item: FamilyTaskItem): void {
    this.taskDetail = item
    this.showTaskDetail = true
    this.hideBar(true)
  }

  private openAddItem(): void {
    this.itemFormEdit = false
    this.itemFormSeed = new HomeItem()
    this.showItemForm = true
    this.hideBar(true)
  }

  private openItemDetail(item: HomeItem): void {
    this.itemDetail = item
    this.showItemDetail = true
    this.hideBar(true)
  }

  private openAddMemo(): void {
    this.openLifeSegment('memo')
  }

  private openMemoDetail(_item: object): void {
    this.openLifeSegment('memo')
  }

  private async toggleTask(item: FamilyTaskItem): Promise<void> {
    await TaskService.toggle(item)
    if (item.completed) {
      await ReminderService.cancelTask(item)
      await TaskService.update(item)
    }
    await ReminderService.syncAll(this.host())
    if (this.taskDetail.id === item.id) {
      this.taskDetail = TaskService.cloneItem(item)
    }
    this.bump()
  }

  private async saveTaskForm(draft: FamilyTaskItem): Promise<void> {
    let row: FamilyTaskItem
    if (this.taskFormEdit && draft.id.length > 0) {
      row = this.taskDetail
      row.title = draft.title
      row.category = CategorySuggest.normalize(draft.category)
      row.date = draft.date
      row.time = draft.time
      row.reminder = draft.reminder
      row.repeatType = draft.repeatType
      row.assignee = draft.assignee
      await TaskService.update(row)
    } else {
      row = await TaskService.create(draft)
    }
    await ReminderService.scheduleTask(row, this.host())
    this.showTaskForm = false
    this.hideBar(this.anyOverlayOpen())
    this.bump()
    this.toast(ReminderService.lastAction.length > 0 ? ReminderService.lastAction :
      (ReminderService.lastError.length > 0 ? ReminderService.lastError : '已记下'))
  }

  private async saveItemForm(draft: HomeItem): Promise<void> {
    let row: HomeItem
    if (this.itemFormEdit && draft.id.length > 0) {
      row = ItemService.clone(this.itemDetail)
      row.name = draft.name
      row.category = draft.category
      row.purchaseDate = draft.purchaseDate
      row.expiryDate = draft.expiryDate
      row.location = draft.location
      row.room = draft.room
      row.customTag = draft.customTag
      row.remark = draft.remark
      row.remindLeadDays = draft.remindLeadDays
      await ItemService.update(row)
      this.itemDetail = row
    } else {
      row = await ItemService.create(draft)
    }
    await ReminderService.scheduleItem(row, this.host())
    this.showItemForm = false
    this.hideBar(this.anyOverlayOpen())
    this.bump()
    this.toast(ReminderService.lastAction.length > 0 ? ReminderService.lastAction :
      (ReminderService.lastError.length > 0 ? ReminderService.lastError : '已登记'))
  }

  private async confirmDelete(): Promise<void> {
    if (this.confirmKind === 'task') {
      await ReminderService.cancelTask(this.taskDetail)
      await TaskService.remove(this.taskDetail.id)
      this.showTaskDetail = false
    }
    if (this.confirmKind === 'item') {
      await ReminderService.cancelItem(this.itemDetail)
      await ItemService.remove(this.itemDetail.id)
      this.showItemDetail = false
    }
    this.showConfirm = false
    this.hideBar(false)
    this.bump()
    this.toast('已删除')
  }

  private async applyScene(code: string): Promise<void> {
    const result = await ScenePackService.apply(code)
    this.bump()
    this.toast(result.message)
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          DiscoverHubPage({
            embedded: true,
            refreshToken: this.tick,
            onApplyScene: (code: string) => { void this.applyScene(code) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          HomePage({
            refreshToken: this.tick,
            onOpenItems: () => { this.switchTab(2) },
            onOpenMemos: () => { this.openLifeSegment('memo') },
            onOpenTasks: () => { this.openLifeSegment('plan') },
            onOpenMembers: () => this.openMembers(),
            onOpenSearch: () => this.openSearch(),
            onOpenFavorites: () => this.openFavorites(),
            onOpenGrowth: () => this.openGrowth(),
            onCreateGoal: () => this.openGoalForm(),
            onOpenActivity: (ev: ActivityEvent) => { void this.openActivity(ev) },
            onApplyScene: (code: string) => { void this.applyScene(code) },
            onOpenDiscover: () => this.openDiscover(),
            onToast: (m: string) => this.toast(m)
          }).layoutWeight(1)
        } else if (this.current === 2) {
          ItemsPage({
            refreshToken: this.tick,
            onOpen: (it: HomeItem) => this.openItemDetail(it),
            onAdd: () => this.openAddItem()
          }).layoutWeight(1)
        } else if (this.current === 3) {
          LifeHubPage({
            refreshToken: this.tick,
            taskRefreshToken: this.tick,
            onOpenTask: (it: FamilyTaskItem) => this.openTaskDetail(it),
            onToggleTask: (it: FamilyTaskItem) => { void this.toggleTask(it) },
            onAddTask: () => this.openAddTask(),
            onToast: (m: string) => this.toast(m),
            onDataChanged: () => this.bump()
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => this.onLogout(),
            onOpenMembers: () => this.openMembers(),
            onOpenFavorites: () => this.openFavorites(),
            onOpenGrowth: () => this.openGrowth(),
            onOpenDiscover: () => this.openDiscover()
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

      if (this.showTaskDetail) {
        TaskDetailPane({
          item: this.taskDetail,
          onClose: () => { this.showTaskDetail = false; this.hideBar(false) },
          onEdit: () => { this.taskFormEdit = true; this.taskFormSeed = this.taskDetail; this.showTaskForm = true },
          onComplete: () => { void this.toggleTask(this.taskDetail).then(() => { this.showTaskDetail = false; this.hideBar(false) }) },
          onDelete: () => { this.confirmKind = 'task'; this.showConfirm = true },
          onFavorite: () => { void this.toggleTaskFavorite() }
        })
      }

      if (this.showItemDetail) {
        ItemDetailPane({
          item: this.itemDetail,
          onClose: () => { this.showItemDetail = false; this.hideBar(false) },
          onEdit: () => { this.itemFormEdit = true; this.itemFormSeed = this.itemDetail; this.showItemForm = true },
          onDelete: () => { this.confirmKind = 'item'; this.showConfirm = true },
          onFavorite: () => { void this.toggleItemFavorite() }
        })
      }

      if (this.showTaskForm) {
        TaskFormOverlay({
          isEdit: this.taskFormEdit,
          seed: this.taskFormSeed,
          onClose: () => { this.showTaskForm = false; this.hideBar(this.anyOverlayOpen()) },
          onSave: (d: FamilyTaskItem) => { void this.saveTaskForm(d) }
        })
      }

      if (this.showItemForm) {
        ItemFormOverlay({
          isEdit: this.itemFormEdit,
          seed: this.itemFormSeed,
          onClose: () => { this.showItemForm = false; this.hideBar(this.anyOverlayOpen()) },
          onSave: (d: HomeItem) => { void this.saveItemForm(d) }
        })
      }

      if (this.showMembers) {
        MembersPane({
          onClose: () => { this.showMembers = false; this.hideBar(this.anyOverlayOpen()) },
          onChanged: () => this.bump()
        })
      }

      if (this.showSearch) {
        SearchHubPage({
          onClose: () => { this.showSearch = false; this.hideBar(this.anyOverlayOpen()) },
          onOpenHit: (hit: SearchHit) => { void this.openSearchHit(hit) }
        })
          .width('100%')
          .height('100%')
          .zIndex(35)
      }

      if (this.showFavorites) {
        FavoritesPage({
          refreshToken: this.tick,
          onClose: () => { this.showFavorites = false; this.hideBar(this.anyOverlayOpen()) },
          onOpenItem: (fav: FavoriteRecord) => { void this.openFavorite(fav) }
        })
          .width('100%')
          .height('100%')
          .zIndex(35)
      }

      if (this.showGrowth) {
        GrowthHubPage({
          refreshToken: this.tick,
          onClose: () => { this.showGrowth = false; this.hideBar(this.anyOverlayOpen()) }
        })
          .width('100%')
          .height('100%')
          .zIndex(35)
      }

      if (this.showGoalForm) {
        GoalFormOverlay({
          onClose: () => { this.showGoalForm = false; this.hideBar(this.anyOverlayOpen()) },
          onSave: (title: string, target: number) => { void this.saveGoalForm(title, target) }
        })
          .width('100%')
          .height('100%')
          .zIndex(35)
      }

      if (this.showConfirm) {
        ConfirmSheet({
          title: '确认删除？',
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
    .onClick(() => { this.switchTab(t.index) })
  }
}
