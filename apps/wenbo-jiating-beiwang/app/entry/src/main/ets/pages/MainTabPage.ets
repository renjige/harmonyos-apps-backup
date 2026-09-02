import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { TasksPage } from './TasksPage'
import { RemindersPage } from './RemindersPage'
import { MinePage } from './MinePage'
import { AddItemSheet } from '../components/family/AddItemSheet'
import { CreateListSheet } from '../components/family/CreateListSheet'
import { ListDetailOverlay } from '../components/family/ListDetailOverlay'
import { TemplateDetailOverlay } from '../components/family/TemplateDetailOverlay'
import { MemoFormOverlay } from '../components/family/MemoFormOverlay'
import { ReminderSheet } from '../components/family/ReminderSheet'
import { FamilyNote, FamilyTemplate } from '../models/FamilyModels'
import { FamilyService } from '../services/FamilyService'
import { FamilyLocalStore } from '../services/FamilyLocalStore'
import { ClipService } from '../services/ClipService'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem(); t0.index = 0; t0.name = 'home'; t0.label = '首页'; tabs.push(t0)
    const t1 = new TabItem(); t1.index = 1; t1.name = 'biz'; t1.label = '事项'; tabs.push(t1)
    const t2 = new TabItem(); t2.index = 2; t2.name = 'bell'; t2.label = '提醒'; tabs.push(t2)
    const t3 = new TabItem(); t3.index = 3; t3.name = 'user'; t3.label = '我的'; tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showDetail: boolean = false
  @State showAdd: boolean = false
  @State showCreate: boolean = false
  @State showTemplate: boolean = false
  @State showMemo: boolean = false
  @State showRemind: boolean = false
  @State activeListId: string = ''
  @State remain: number = 0
  @State template: FamilyTemplate = new FamilyTemplate()
  @State memo: FamilyNote = new FamilyNote()
  @State memoIsNew: boolean = true
  @State toastText: string = ''
  @State homeTick: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('themeRevision') @Watch('onThemeRevision') themeRevision: number = 0
  @Prop appName: string = '家庭备忘'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private toast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private bump(): void {
    this.homeTick += 1
  }

  private onThemeRevision(): void {
    this.bump()
  }

  private async startRemind(): Promise<void> {
    const list = await FamilyService.ensureTodayList()
    this.activeListId = list.id
    const items = await FamilyService.items(list.id)
    this.remain = items.length - FamilyService.doneCount(items)
    this.showRemind = true
    this.hideBar(true)
  }

  private openList(id: string): void {
    this.activeListId = id
    this.showDetail = true
    this.hideBar(true)
  }

  private async startAdd(): Promise<void> {
    const list = await FamilyService.ensureTodayList()
    this.activeListId = list.id
    this.showAdd = true
    this.hideBar(true)
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.homeTick,
            onAddItem: () => { void this.startAdd() },
            onOpenList: (id: string) => this.openList(id),
            onCreateList: () => { this.showCreate = true; this.hideBar(true) },
            onOpenLists: () => { this.current = 1 },
            onOpenReminders: () => { void this.startRemind() }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          TasksPage({
            refreshToken: this.homeTick,
            onOpenList: (id: string) => this.openList(id),
            onCreateList: () => { this.showCreate = true; this.hideBar(true) },
            onOpenTemplate: (tpl: FamilyTemplate) => {
              this.template = tpl
              this.showTemplate = true
              this.hideBar(true)
            }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          RemindersPage({
            refreshToken: this.homeTick,
            onCreate: (): void => { void this.startRemind() }
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => this.onLogout(),
            onOpenLists: () => { this.current = 1 },
            onOpenTemplates: () => { this.current = 1 }
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
        ListDetailOverlay({
          listId: this.activeListId,
          refreshToken: this.homeTick,
          onClose: () => { this.showDetail = false; this.hideBar(false); this.bump() },
          onAddItem: () => { this.showAdd = true },
          onRemind: (): void => {
            void FamilyService.items(this.activeListId).then((items) => {
              this.remain = items.length - FamilyService.doneCount(items)
              this.showRemind = true
            })
          },
          onDeleted: () => { this.showDetail = false; this.hideBar(false); this.toast('家庭清单已删除'); this.bump() },
          onShare: (text: string): void => {
            void ClipService.copy(text).then((ok: boolean) => {
              this.toast(ok ? '已复制到剪贴板，可粘贴分享' : '复制失败，请重试')
            })
          }
        }).width('100%').height('100%').zIndex(10)
      }
      if (this.showAdd) {
        AddItemSheet({
          onClose: () => { this.showAdd = false; this.hideBar(this.showDetail) },
          onConfirm: (name: string, qty: string, remark: string, category: string): void => {
            void FamilyService.addItem(this.activeListId, name, category, qty, remark).then(() => {
              this.showAdd = false
              this.hideBar(this.showDetail)
              this.toast('已记下')
              this.bump()
            })
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showCreate) {
        CreateListSheet({
          onClose: () => { this.showCreate = false; this.hideBar(false) },
          onConfirm: (title: string): void => {
            void FamilyService.createList(title, FamilyLocalStore.today(), '', '').then((row) => {
              this.showCreate = false
              this.openList(row.id)
              this.toast('家庭清单已创建')
            })
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showTemplate) {
        TemplateDetailOverlay({
          template: this.template,
          onClose: () => { this.showTemplate = false; this.hideBar(false) },
          onCreate: (): void => {
            void FamilyService.createList(this.template.title, FamilyLocalStore.today(), this.template.coverKey, this.template.id).then((row) => {
              this.showTemplate = false
              this.openList(row.id)
              this.toast('已用模板创建家庭清单')
            })
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showMemo) {
        MemoFormOverlay({
          note: this.memo,
          isNew: this.memoIsNew,
          onClose: (): void => { this.showMemo = false; this.hideBar(false) },
          onSave: (note: FamilyNote): void => {
            void FamilyService.saveMemo(note, this.memoIsNew).then((ok: boolean) => {
              if (!ok) {
                this.toast('保存失败，请填写标题后重试')
                return
              }
              this.showMemo = false
              this.hideBar(false)
              this.toast('备忘已保存')
              this.bump()
            })
          },
          onDelete: (): void => {
            void FamilyService.deleteMemo(this.memo.id).then((ok: boolean) => {
              if (!ok) {
                this.toast('删除失败，请重试')
                return
              }
              this.showMemo = false
              this.hideBar(false)
              this.toast('备忘已删除')
              this.bump()
            })
          }
        }).width('100%').height('100%').zIndex(16)
      }
      if (this.showRemind) {
        ReminderSheet({
          remain: this.remain,
          onClose: () => { this.showRemind = false; this.hideBar(this.showDetail) },
          onConfirm: (whenText: string, message: string, cycle: string): void => {
            void FamilyService.createReminder(message, this.activeListId, whenText, cycle).then((ok: boolean) => {
              this.showRemind = false
              this.hideBar(false)
              const err = FamilyService.lastNotifyError()
              if (!ok && err.length > 0) {
                this.toast(err)
              } else {
                this.toast('提醒已设置，到点会通知你')
              }
              this.bump()
            })
          }
        }).width('100%').height('100%').zIndex(18)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: Theme.space.pageX, y: Theme.space.s6 })
          .zIndex(30)
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
    .onClick((): void => {
      this.hideBar(false)
      this.current = t.index
      this.bump()
    })
  }
}
