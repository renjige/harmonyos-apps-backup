import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ProjectsPage } from './ProjectsPage'
import { ChecklistPage } from './ChecklistPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AIAssistantPage } from './AIAssistantPage'
import { ActionSheet } from '../components/reno/ActionSheet'
import { ConfirmSheet } from '../components/reno/ConfirmSheet'
import { ProjectFormOverlay } from '../components/reno/ProjectFormOverlay'
import { TaskFormOverlay } from '../components/reno/TaskFormOverlay'
import { MaterialFormOverlay } from '../components/reno/MaterialFormOverlay'
import { NoteFormOverlay } from '../components/reno/NoteFormOverlay'
import { ExpenseFormOverlay } from '../components/reno/ExpenseFormOverlay'
import { InspectListPane } from '../components/reno/InspectListPane'
import { TimelinePane } from '../components/reno/TimelinePane'
import { ExpenseDetailPane } from '../components/detail/ExpenseDetailPane'
import { SmartListPane } from '../components/reno/SmartListPane'
import { CalcPane } from '../components/reno/CalcPane'
import { ProjectDetailPane } from '../components/detail/ProjectDetailPane'
import { StageDetailPane } from '../components/detail/StageDetailPane'
import { TaskDetailPane } from '../components/detail/TaskDetailPane'
import { MaterialDetailPane } from '../components/detail/MaterialDetailPane'
import { NoteDetailPane } from '../components/detail/NoteDetailPane'
import { InspectDetailPane } from '../components/detail/InspectDetailPane'
import { SuggestionDetailPane } from '../components/detail/SuggestionDetailPane'
import {
  RenoExpense, RenoEvent, RenoInspect, RenoMaterial, RenoNote, RenoProject, RenoSuggestion, RenoTask
} from '../models/RenoModels'
import { RenoService } from '../services/RenoService'
import { RenoLedger } from '../services/RenoLedger'
import { RenoLocalStore } from '../services/RenoLocalStore'
import { AppButton } from '../components/design-system/AppButton'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem(); t0.index = 0; t0.name = 'home'; t0.label = '首页'; tabs.push(t0)
    const t1 = new TabItem(); t1.index = 1; t1.name = 'biz'; t1.label = '项目'; tabs.push(t1)
    const t2 = new TabItem(); t2.index = 2; t2.name = 'check'; t2.label = '清单'; tabs.push(t2)
    const t3 = new TabItem(); t3.index = 3; t3.name = 'user'; t3.label = '我的'; tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State paneKind: string = ''
  @State paneId: string = ''
  @State extra: string = ''
  @State formEdit: boolean = false
  @State tick: number = 0
  @State toastText: string = ''
  @State project: RenoProject = new RenoProject()
  @State task: RenoTask = new RenoTask()
  @State material: RenoMaterial = new RenoMaterial()
  @State note: RenoNote = new RenoNote()
  @State inspect: RenoInspect = new RenoInspect()
  @State suggestion: RenoSuggestion = new RenoSuggestion()
  @State expense: RenoExpense = new RenoExpense()
  @State eventRow: RenoEvent = new RenoEvent()
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop appName: string = '筑科装修助手'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private bump(): void {
    this.tick += 1
    RenoLocalStore.bumpRev()
  }

  private toast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private open(kind: string, id: string, extra: string): void {
    this.paneKind = kind
    this.paneId = id
    this.extra = extra
    this.hideBar(true)
  }

  private closeOverlay(): void {
    this.paneKind = ''
    this.hideBar(false)
  }

  private openQuick(id: string): void {
    this.formEdit = false
    this.project = new RenoProject()
    this.task = new RenoTask()
    this.material = new RenoMaterial()
    this.note = new RenoNote()
    this.expense = new RenoExpense()
    if (id === 'inspect') {
      this.open('inspectList', '', '')
      return
    }
    if (id === 'expense') {
      this.open('formExpense', '', '')
      return
    }
    this.open(id === 'note' ? 'formNote' : (id === 'material' ? 'formMaterial' : (id === 'task' ? 'formTask' : 'addSheet')), '', '')
  }

  private async saveProject(d: RenoProject): Promise<void> {
    const id = await RenoService.saveProject(d, this.formEdit)
    this.project = RenoService.findProject(id)
    this.closeOverlay()
    this.bump()
    this.toast(this.formEdit ? '项目已保存' : '项目已创建')
  }

  private async saveTask(d: RenoTask): Promise<void> {
    if (RenoService.currentProject() === null && d.projectId.length === 0) {
      this.toast('请先创建装修项目')
      this.formEdit = false
      this.paneKind = 'formProject'
      return
    }
    await RenoService.saveTask(d, this.formEdit)
    this.task = RenoService.findTask(d.id.length > 0 ? d.id : this.task.id)
    this.closeOverlay()
    this.bump()
    this.toast(this.formEdit ? '事项已保存' : '事项已添加')
  }

  private async saveMaterial(d: RenoMaterial): Promise<void> {
    await RenoService.saveMaterial(d, this.formEdit)
    this.material = RenoService.findMaterial(d.id.length > 0 ? d.id : this.material.id)
    this.closeOverlay()
    this.bump()
    this.toast('已确认')
  }

  private async saveNote(d: RenoNote): Promise<void> {
    await RenoService.saveNote(d, this.formEdit)
    this.note = RenoService.findNote(d.id.length > 0 ? d.id : this.note.id)
    this.closeOverlay()
    this.bump()
    this.toast('记录已保存')
  }

  private async saveExpense(d: RenoExpense): Promise<void> {
    if (RenoService.currentProject() === null && d.projectId.length === 0) {
      this.toast('请先创建装修项目')
      this.formEdit = false
      this.paneKind = 'formProject'
      return
    }
    const id = await RenoLedger.saveExpense(d, this.formEdit)
    this.expense = RenoLedger.findExpense(id)
    this.closeOverlay()
    this.bump()
    this.toast(this.formEdit ? '费用已保存' : '费用已记入')
  }

  private async exportCurrent(): Promise<void> {
    const current = RenoService.currentProject()
    if (current === null) {
      this.toast('请先创建装修项目')
      this.formEdit = false
      this.open('formProject', '', '')
      return
    }
    const ok = await RenoLedger.exportProject(current)
    this.toast(ok ? '项目纪要已复制到剪贴板' : '导出失败，请稍后重试')
  }

  private openTimelineEvent(it: RenoEvent): void {
    if (it.kind === 'task') {
      this.task = RenoService.findTask(it.targetId)
      this.paneKind = 'task'
      return
    }
    if (it.kind === 'material') {
      this.material = RenoService.findMaterial(it.targetId)
      this.paneKind = 'material'
      return
    }
    if (it.kind === 'expense') {
      this.expense = RenoLedger.findExpense(it.targetId)
      this.paneKind = 'expense'
      return
    }
    this.note = RenoService.findNote(it.targetId)
    this.paneKind = 'note'
  }

  private async doDelete(): Promise<void> {
    if (this.extra === 'project') {
      await RenoService.removeProject(this.paneId)
    } else if (this.extra === 'task') {
      await RenoService.removeTask(this.paneId)
    } else if (this.extra === 'material') {
      await RenoService.removeMaterial(this.paneId)
    } else if (this.extra === 'note') {
      await RenoService.removeNote(this.paneId)
    } else if (this.extra === 'expense') {
      await RenoLedger.removeExpense(this.paneId)
    }
    this.paneKind = ''
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
            onOpenMessages: () => this.open('messages', '', ''),
            onOpenSettings: () => { this.current = 3 },
            onCreateProject: () => { this.formEdit = false; this.project = new RenoProject(); this.open('formProject', '', '') },
            onOpenProject: (it: RenoProject) => { this.project = it; this.open('project', it.id, '') },
            onOpenStage: (s: string) => this.open('stage', s, s),
            onOpenTask: (it: RenoTask) => { this.task = it; this.open('task', it.id, '') },
            onToggleTask: (it: RenoTask) => { void RenoService.cycleTask(it.id).then(() => { this.bump(); this.toast('已完成') }) },
            onOpenMaterial: (it: RenoMaterial) => { this.material = it; this.open('material', it.id, '') },
            onOpenNote: (it: RenoNote) => { this.note = it; this.open('note', it.id, '') },
            onQuick: (id: string) => this.openQuick(id),
            onAllTasks: () => { this.current = 2 },
            onOpenTimeline: () => this.open('timeline', '', ''),
            onOpenExpense: () => { this.formEdit = false; this.expense = new RenoExpense(); this.open('formExpense', '', '') },
            onExport: () => { void this.exportCurrent() }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          ProjectsPage({
            refreshToken: this.tick,
            onOpen: (it: RenoProject) => { this.project = it; this.open('project', it.id, '') },
            onAdd: () => { this.formEdit = false; this.project = new RenoProject(); this.open('formProject', '', '') }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          ChecklistPage({
            refreshToken: this.tick,
            onOpenTask: (it: RenoTask) => { this.task = it; this.open('task', it.id, '') },
            onToggleTask: (it: RenoTask) => { void RenoService.cycleTask(it.id).then(() => this.bump()) },
            onOpenMaterial: (it: RenoMaterial) => { this.material = it; this.open('material', it.id, '') },
            onOpenNote: (it: RenoNote) => { this.note = it; this.open('note', it.id, '') },
            onOpenExpense: (it: RenoExpense) => { this.expense = it; this.open('expense', it.id, '') },
            onAdd: () => this.open('addSheet', '', ''),
            onSmart: () => this.open('smart', '', ''),
            onCalc: () => this.open('calc', '', ''),
            onInspect: () => this.open('inspectList', '', ''),
            onDiagnose: () => this.open('diagnose', '', '')
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => this.onLogout(),
            onOpenProjects: () => { this.current = 1 },
            onOpenNotes: () => { this.current = 2 },
            onCleared: () => { this.bump(); this.toast('本地数据已清空') }
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

      this.Overlays()

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.sm)
          .margin({ top: 40 })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  Overlays() {
    if (this.paneKind === 'addSheet') {
      ActionSheet({
        title: '新增',
        onPick: (id: string) => this.openQuick(id),
        onCancel: () => this.closeOverlay()
      })
    } else if (this.paneKind === 'confirm') {
      ConfirmSheet({
        onCancel: () => {
          this.paneKind = this.extra === 'project' ? 'project' : (this.extra === 'task' ? 'task' : (this.extra === 'material' ? 'material' : (this.extra === 'expense' ? 'expense' : 'note')))
        },
        onConfirm: () => { void this.doDelete() }
      })
    } else if (this.paneKind === 'formProject') {
      ProjectFormOverlay({ isEdit: this.formEdit, seed: this.project, onClose: () => this.closeOverlay(), onSave: (d: RenoProject) => { void this.saveProject(d) } })
    } else if (this.paneKind === 'formTask') {
      TaskFormOverlay({ isEdit: this.formEdit, seed: this.task, onClose: () => this.closeOverlay(), onSave: (d: RenoTask) => { void this.saveTask(d) } })
    } else if (this.paneKind === 'formMaterial') {
      MaterialFormOverlay({ isEdit: this.formEdit, seed: this.material, onClose: () => this.closeOverlay(), onSave: (d: RenoMaterial) => { void this.saveMaterial(d) } })
    } else if (this.paneKind === 'formNote') {
      NoteFormOverlay({ isEdit: this.formEdit, seed: this.note, onClose: () => this.closeOverlay(), onSave: (d: RenoNote) => { void this.saveNote(d) } })
    } else if (this.paneKind === 'formExpense') {
      ExpenseFormOverlay({ isEdit: this.formEdit, seed: this.expense, onClose: () => this.closeOverlay(), onSave: (d: RenoExpense) => { void this.saveExpense(d) } })
    } else if (this.paneKind === 'project') {
      ProjectDetailPane({
        item: this.project,
        onClose: () => this.closeOverlay(),
        onEdit: () => { this.formEdit = true; this.paneKind = 'formProject' },
        onDelete: () => { this.extra = 'project'; this.paneKind = 'confirm' },
        onOpenStage: (s: string) => this.open('stage', s, s),
        onAddTask: () => { this.formEdit = false; this.task = new RenoTask(); this.paneKind = 'formTask' },
        onOpenExpense: () => { this.formEdit = false; this.expense = new RenoExpense(); this.paneKind = 'formExpense' },
        onOpenTimeline: () => { this.paneKind = 'timeline' },
        onExport: () => { void this.exportCurrent() },
        onSetCurrent: () => this.bump()
      })
    } else if (this.paneKind === 'stage') {
      StageDetailPane({
        stageTitle: this.extra,
        onClose: () => this.closeOverlay(),
        onOpenTask: (it: RenoTask) => { this.task = it; this.paneKind = 'task' },
        onToggleTask: (it: RenoTask) => { void RenoService.cycleTask(it.id).then(() => this.bump()) },
        onAddTask: () => { this.formEdit = false; this.task = new RenoTask(); this.paneKind = 'formTask' },
        onSmart: () => { this.paneKind = 'smart' }
      })
    } else if (this.paneKind === 'task') {
      TaskDetailPane({
        item: this.task,
        onClose: () => this.closeOverlay(),
        onEdit: () => { this.formEdit = true; this.paneKind = 'formTask' },
        onCycle: () => { void RenoService.cycleTask(this.task.id).then(() => { this.task = RenoService.findTask(this.task.id); this.bump(); this.toast(this.task.status === 'done' ? '已完成' : '状态已更新') }) },
        onDelete: () => { this.extra = 'task'; this.paneKind = 'confirm' }
      })
    } else if (this.paneKind === 'material') {
      MaterialDetailPane({
        item: this.material,
        onClose: () => this.closeOverlay(),
        onEdit: () => { this.formEdit = true; this.paneKind = 'formMaterial' },
        onDelete: () => { this.extra = 'material'; this.paneKind = 'confirm' }
      })
    } else if (this.paneKind === 'note') {
      NoteDetailPane({
        item: this.note,
        onClose: () => this.closeOverlay(),
        onEdit: () => { this.formEdit = true; this.paneKind = 'formNote' },
        onDelete: () => { this.extra = 'note'; this.paneKind = 'confirm' }
      })
    } else if (this.paneKind === 'expense') {
      ExpenseDetailPane({
        item: this.expense,
        onClose: () => this.closeOverlay(),
        onEdit: () => { this.formEdit = true; this.paneKind = 'formExpense' },
        onDelete: () => { this.extra = 'expense'; this.paneKind = 'confirm' }
      })
    } else if (this.paneKind === 'inspect') {
      InspectDetailPane({
        item: this.inspect,
        onClose: () => { this.paneKind = 'inspectList' },
        onPass: () => { void RenoService.setInspectResult(this.inspect, 'pass').then(() => { this.toast('验收进度已更新'); this.paneKind = 'inspectList'; this.bump() }) },
        onPending: () => { void RenoService.setInspectResult(this.inspect, 'pending').then(() => { this.paneKind = 'inspectList'; this.bump() }) },
        onNa: () => { void RenoService.setInspectResult(this.inspect, 'na').then(() => { this.toast('验收进度已更新'); this.paneKind = 'inspectList'; this.bump() }) }
      })
    } else if (this.paneKind === 'suggestion') {
      SuggestionDetailPane({
        item: this.suggestion,
        onClose: () => { this.paneKind = 'smart' },
        onAdded: () => this.bump(),
        onNeedProject: () => { this.formEdit = false; this.paneKind = 'formProject' }
      })
    } else if (this.paneKind === 'inspectList') {
      InspectListPane({
        refreshToken: this.tick,
        onClose: () => this.closeOverlay(),
        onOpen: (it: RenoInspect) => { this.inspect = it; this.paneKind = 'inspect' },
        onNeedProject: () => { this.formEdit = false; this.paneKind = 'formProject' }
      })
    } else if (this.paneKind === 'smart') {
      SmartListPane({
        refreshToken: this.tick,
        onClose: () => this.closeOverlay(),
        onOpen: (it: RenoSuggestion) => { this.suggestion = it; this.paneKind = 'suggestion' },
        onNeedProject: () => { this.formEdit = false; this.paneKind = 'formProject' },
        onAdded: () => this.bump()
      })
    } else if (this.paneKind === 'calc') {
      CalcPane({ onClose: () => this.closeOverlay() })
    } else if (this.paneKind === 'timeline') {
      TimelinePane({
        onClose: () => this.closeOverlay(),
        onOpen: (it: RenoEvent) => this.openTimelineEvent(it),
        onNeedProject: () => { this.formEdit = false; this.paneKind = 'formProject' }
      })
    } else if (this.paneKind === 'messages') {
      Column() {
        MessagesPage().layoutWeight(1)
        AppButton({ label: '返回', variant: 'secondary', onTap: () => this.closeOverlay() })
          .margin(Theme.space.pageX)
      }
      .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.paneKind === 'diagnose') {
      Column() {
        Row() {
          Text('关闭').fontSize(Theme.type.body).fontColor(Theme.colors().textSecondary)
            .padding(Theme.space.pageX).onClick(() => this.closeOverlay())
        }.width('100%')
        AIAssistantPage({
          onBookFromAi: (cat: string) => {
            if (cat.indexOf('验收') >= 0) {
              this.open('inspectList', '', '')
            } else if (cat.indexOf('材料') >= 0) {
              this.closeOverlay()
              this.current = 2
            } else {
              this.open('smart', '', '')
            }
          }
        }).layoutWeight(1)
      }
      .width('100%').height('100%').backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
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
      .width(44).height(28).borderRadius(14)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : '#00000000')
      .justifyContent(FlexAlign.Center)
      Text(t.label)
        .fontSize(10)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1).height('100%').justifyContent(FlexAlign.Center)
    .onClick(() => { this.hideBar(false); this.current = t.index })
  }
}
