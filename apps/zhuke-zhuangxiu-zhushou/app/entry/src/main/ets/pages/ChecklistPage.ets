import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ChoiceChip } from '../components/reno/ChoiceChip'
import { TaskRow } from '../components/reno/TaskRow'
import { MaterialRow } from '../components/reno/MaterialRow'
import { NoteRow } from '../components/reno/NoteRow'
import { RenoMaterial, RenoNote, RenoExpense, RenoTask } from '../models/RenoModels'
import { RenoService } from '../services/RenoService'
import { RenoLedger } from '../services/RenoLedger'
import { ExpenseRow } from '../components/reno/ExpenseRow'

@Component
export struct ChecklistPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  @StorageLink('renoRev') @Watch('onRev') renoRev: number = 0
  @State tab: string = 'task'
  @State filter: string = 'todo'
  @State tasks: RenoTask[] = []
  @State materials: RenoMaterial[] = []
  @State notes: RenoNote[] = []
  @State expenses: RenoExpense[] = []
  onOpenTask: (item: RenoTask) => void = (_i: RenoTask) => {}
  onToggleTask: (item: RenoTask) => void = (_i: RenoTask) => {}
  onOpenMaterial: (item: RenoMaterial) => void = (_i: RenoMaterial) => {}
  onOpenNote: (item: RenoNote) => void = (_i: RenoNote) => {}
  onOpenExpense: (item: RenoExpense) => void = (_i: RenoExpense) => {}
  onAdd: () => void = () => {}
  onSmart: () => void = () => {}
  onCalc: () => void = () => {}
  onInspect: () => void = () => {}
  onDiagnose: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const current = RenoService.currentProject()
    const pid = current !== null ? current.id : ''
    this.tasks = await RenoService.tasks(pid)
    this.materials = await RenoService.materials(pid)
    this.notes = await RenoService.notes(pid)
    this.expenses = RenoLedger.expenses(pid)
  }

  private visibleTasks(): RenoTask[] {
    const out: RenoTask[] = []
    for (const row of this.tasks) {
      if (this.filter === 'all' || row.status === this.filter) {
        out.push(row)
      }
    }
    return out
  }

  build() {
    Column() {
      Row() {
        Column({ space: 4 }) {
          Text('清单')
            .fontSize(Theme.type.titleM)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('事项 · 材料 · 记录 · 费用')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .layoutWeight(1)
        Column() {
          AppIcon({ name: 'add', iconSize: 22, color: Theme.colors().brandOnPrimary })
        }
        .width(44).height(44).borderRadius(22)
        .backgroundColor(Theme.colors().brandPrimary)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onAdd())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: 8 })

      Row({ space: 8 }) {
        ChoiceChip({ label: '事项', active: this.tab === 'task', onPick: () => { this.tab = 'task' } })
        ChoiceChip({ label: '材料', active: this.tab === 'material', onPick: () => { this.tab = 'material' } })
        ChoiceChip({ label: '记录', active: this.tab === 'note', onPick: () => { this.tab = 'note' } })
        ChoiceChip({ label: '费用', active: this.tab === 'expense', onPick: () => { this.tab = 'expense' } })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      Row({ space: 8 }) {
        Text('智能清单').fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(Theme.colors().brandPrimaryContainer).borderRadius(Theme.radius.sm)
          .onClick(() => this.onSmart())
        Text('计算').fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(Theme.colors().brandPrimaryContainer).borderRadius(Theme.radius.sm)
          .onClick(() => this.onCalc())
        Text('验收').fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(Theme.colors().brandPrimaryContainer).borderRadius(Theme.radius.sm)
          .onClick(() => this.onInspect())
        Text('进度自检').fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(Theme.colors().brandPrimaryContainer).borderRadius(Theme.radius.sm)
          .onClick(() => this.onDiagnose())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      if (this.tab === 'task') {
        Row({ space: 8 }) {
          ChoiceChip({ label: '待办', active: this.filter === 'todo', onPick: () => { this.filter = 'todo' } })
          ChoiceChip({ label: '进行中', active: this.filter === 'doing', onPick: () => { this.filter = 'doing' } })
          ChoiceChip({ label: '已完成', active: this.filter === 'done', onPick: () => { this.filter = 'done' } })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, bottom: 8 })
      }

      Scroll() {
        Column({ space: 10 }) {
          this.ListBody()
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  ListBody() {
    if (this.tab === 'task') {
      if (this.visibleTasks().length === 0) {
        AppEmpty({
          title: '暂无待办',
          description: '当前阶段暂时没有待处理事项',
          actionLabel: '添加事项',
          onAction: () => this.onAdd()
        })
      } else {
        ForEach(this.visibleTasks(), (it: RenoTask) => {
          TaskRow({
            item: it,
            onOpen: (row: RenoTask) => this.onOpenTask(row),
            onToggle: (row: RenoTask) => this.onToggleTask(row)
          })
        }, (it: RenoTask) => `${it.id}_${it.status}_${it.title}`)
      }
    } else if (this.tab === 'material') {
      if (this.materials.length === 0) {
        AppEmpty({
          title: '暂无材料',
          description: '把规格和房间记下来，避免记错',
          actionLabel: '记材料',
          onAction: () => this.onAdd()
        })
      } else {
        ForEach(this.materials, (it: RenoMaterial) => {
          MaterialRow({ item: it, onOpen: (row: RenoMaterial) => this.onOpenMaterial(row) })
        }, (it: RenoMaterial) => `${it.id}_${it.status}_${it.spec}_${it.title}`)
      }
    } else if (this.tab === 'note') {
      if (this.notes.length === 0) {
        AppEmpty({
          title: '暂无现场记录',
          description: '把今天的施工情况记录下来吧',
          actionLabel: '添加记录',
          onAction: () => this.onAdd()
        })
      } else {
        ForEach(this.notes, (it: RenoNote) => {
          NoteRow({ item: it, onOpen: (row: RenoNote) => this.onOpenNote(row) })
        }, (it: RenoNote) => `${it.id}_${it.updatedAt}_${it.title}`)
      }
    } else {
      if (this.expenses.length === 0) {
        AppEmpty({
          title: '暂无费用',
          description: '记下材料定金、人工节点款等，方便对照预算',
          actionLabel: '记一笔费用',
          onAction: () => this.onAdd()
        })
      } else {
        ForEach(this.expenses, (it: RenoExpense) => {
          ExpenseRow({ item: it, onOpen: (row: RenoExpense) => this.onOpenExpense(row) })
        }, (it: RenoExpense) => `${it.id}_${it.amount}_${it.title}`)
      }
    }
  }
}
