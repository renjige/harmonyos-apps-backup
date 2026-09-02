import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { ZhaConfirmDialog } from '../components/zha/ZhaConfirmDialog'
import { ZhaTodoRow } from '../components/zha/ZhaTodoRow'
import { ZhaLocalStore } from '../services/ZhaLocalStore'
import { ZhaDetailNav } from '../services/ZhaDetailNav'
import { ZhaTodoItem } from '../models/ZhaModels'

enum TodoTab {
  All = 0,
  Active = 1,
  Done = 2
}

@Component
export struct TodoPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State tab: TodoTab = TodoTab.All
  @State todos: ZhaTodoItem[] = []
  @State visible: ZhaTodoItem[] = []
  @State inputText: string = ''
  @State priority: string = 'medium'
  @State dueDate: string = ''
  @State toast: string = ''
  @State pendingDeleteId: string = ''
  @State confirmClearDone: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    if (this.refreshToken > 0) {
      void this.reload()
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout(() => { this.toast = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.todos = await ZhaLocalStore.loadTodos()
    this.applyTab()
  }

  private applyTab(): void {
    const sorted = this.sortTodos(this.todos)
    if (this.tab === TodoTab.Active) {
      const out: ZhaTodoItem[] = []
      for (const t of sorted) {
        if (!t.done) {
          out.push(t)
        }
      }
      this.visible = out
      return
    }
    if (this.tab === TodoTab.Done) {
      const out: ZhaTodoItem[] = []
      for (const t of sorted) {
        if (t.done) {
          out.push(t)
        }
      }
      this.visible = out
      return
    }
    this.visible = sorted
  }

  private sortTodos(items: ZhaTodoItem[]): ZhaTodoItem[] {
    const copy: ZhaTodoItem[] = []
    for (const it of items) {
      copy.push(it)
    }
    copy.sort((a, b) => {
      if (a.done !== b.done) {
        return a.done ? 1 : -1
      }
      const pa = a.priority === 'high' ? 0 : a.priority === 'medium' ? 1 : 2
      const pb = b.priority === 'high' ? 0 : b.priority === 'medium' ? 1 : 2
      if (pa !== pb) {
        return pa - pb
      }
      if (a.dueDate.length > 0 && b.dueDate.length > 0 && a.dueDate !== b.dueDate) {
        return a.dueDate < b.dueDate ? -1 : 1
      }
      return b.createdAt - a.createdAt
    })
    return copy
  }

  private async addTodo(): Promise<void> {
    const text = this.inputText.trim()
    if (text.length === 0) {
      this.showToast('请输入待办内容')
      return
    }
    await ZhaLocalStore.createTodo(text, this.priority, this.dueDate)
    this.inputText = ''
    this.dueDate = ''
    await this.reload()
  }

  private async clearDone(): Promise<void> {
    const n = await ZhaLocalStore.clearCompletedTodos()
    this.showToast(n > 0 ? `已归档 ${n} 条已完成` : '暂无已完成事项')
    await this.reload()
  }

  private async doDelete(): Promise<void> {
    const id = this.pendingDeleteId
    this.pendingDeleteId = ''
    if (id.length > 0) {
      await ZhaLocalStore.deleteTodo(id)
      await this.reload()
    }
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Text('全部')
            .fontSize(Theme.type.subhead)
            .fontColor(this.tab === TodoTab.All ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.tab === TodoTab.All ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick(() => { this.tab = TodoTab.All; this.applyTab() })
          Text('进行中')
            .fontSize(Theme.type.subhead)
            .fontColor(this.tab === TodoTab.Active ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.tab === TodoTab.Active ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick(() => { this.tab = TodoTab.Active; this.applyTab() })
          Text('已完成')
            .fontSize(Theme.type.subhead)
            .fontColor(this.tab === TodoTab.Done ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.tab === TodoTab.Done ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick(() => { this.tab = TodoTab.Done; this.applyTab() })
          Blank()
          if (this.tab === TodoTab.Done) {
            Text('清空已完成')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick(() => { this.confirmClearDone = true })
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        if (this.visible.length === 0) {
          AppEmpty({
            title: this.tab === TodoTab.Done ? '暂无已完成事项' : '暂无待办',
            description: '在底部输入框快速添加'
          }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s2 }) {
              ForEach(this.visible, (t: ZhaTodoItem) => {
                ZhaTodoRow({
                  todo: t,
                  onToggle: () => {
                    void ZhaLocalStore.toggleTodoDone(t.id).then(() => this.reload())
                  },
                  onDelete: () => { this.pendingDeleteId = t.id },
                  onEdit: () => ZhaDetailNav.openTodoEdit(t.id)
                })
              }, (t: ZhaTodoItem) => t.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s2,
              bottom: Theme.space.s4
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }

        Column({ space: Theme.space.s2 }) {
          Row({ space: Theme.space.s2 }) {
            Text('高')
              .fontSize(Theme.type.caption)
              .fontColor(this.priority === 'high' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor(this.priority === 'high' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.priority = 'high' })
            Text('中')
              .fontSize(Theme.type.caption)
              .fontColor(this.priority === 'medium' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor(this.priority === 'medium' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.priority = 'medium' })
            Text('低')
              .fontSize(Theme.type.caption)
              .fontColor(this.priority === 'low' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor(this.priority === 'low' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.priority = 'low' })
          }
          AppDatePickerField({
            label: '截止日期（可选）',
            value: this.dueDate,
            placeholder: '添加时可设截止日期',
            minDaysFromToday: 0,
            maxDaysFromToday: 365,
            onChange: (v: string) => { this.dueDate = v }
          })
          Row({ space: Theme.space.s2 }) {
            TextInput({ text: this.inputText, placeholder: '快速添加待办…' })
              .layoutWeight(1)
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.inputText = v })
            Text('添加')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().brandOnPrimary)
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.sm)
              .onClick(() => { void this.addTodo() })
          }
          .width('100%')
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s10
        })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.pendingDeleteId.length > 0) {
        ZhaConfirmDialog({
          title: '删除待办',
          message: '删除后无法恢复。是否继续？',
          confirmLabel: '确认删除',
          danger: true,
          onConfirm: () => { void this.doDelete() },
          onCancel: () => { this.pendingDeleteId = '' }
        })
      }

      if (this.confirmClearDone) {
        ZhaConfirmDialog({
          title: '清空已完成',
          message: '将从清单中移除全部已完成事项。是否继续？',
          confirmLabel: '确认清空',
          danger: true,
          onConfirm: () => {
            this.confirmClearDone = false
            void this.clearDone()
          },
          onCancel: () => { this.confirmClearDone = false }
        })
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
