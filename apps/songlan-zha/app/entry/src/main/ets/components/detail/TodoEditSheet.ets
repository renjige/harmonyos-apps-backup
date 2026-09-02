import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { AppIcon } from '../design-system/AppIcon'
import { ZhaConfirmDialog } from '../zha/ZhaConfirmDialog'
import { ZhaTodoItem } from '../../models/ZhaModels'
import { ZhaLocalStore } from '../../services/ZhaLocalStore'
import { ZhaDetailNav } from '../../services/ZhaDetailNav'

@Component
export struct TodoEditSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop todoId: string = ''
  @State todo: ZhaTodoItem = new ZhaTodoItem()
  @State content: string = ''
  @State priority: string = 'medium'
  @State dueDate: string = ''
  @State toast: string = ''
  @State confirmDelete: boolean = false
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await ZhaLocalStore.findTodo(this.todoId)
    if (found !== undefined) {
      this.todo = found
      this.content = found.content
      this.priority = found.priority
      this.dueDate = found.dueDate
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout(() => { this.toast = '' }, 2000)
  }

  private async save(): Promise<void> {
    if (this.content.trim().length === 0) {
      this.showToast('请填写待办内容')
      return
    }
    this.todo.content = this.content.trim()
    this.todo.priority = this.priority
    this.todo.dueDate = this.dueDate
    await ZhaLocalStore.saveTodo(this.todo)
    this.onSaved()
    ZhaDetailNav.closeTodoEdit()
  }

  private async doDelete(): Promise<void> {
    this.confirmDelete = false
    await ZhaLocalStore.deleteTodo(this.todoId)
    this.onSaved()
    ZhaDetailNav.closeTodoEdit()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('编辑待办')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
            .onClick(() => ZhaDetailNav.closeTodoEdit())
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextArea({ text: this.content, placeholder: '待办内容' })
              .height(100)
              .fontSize(Theme.type.body)
              .onChange((v: string) => { this.content = v })

            Text('优先级')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Row({ space: Theme.space.s2 }) {
              Text('高')
                .fontSize(Theme.type.caption)
                .fontColor(this.priority === 'high' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.priority === 'high' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.priority = 'high' })
              Text('中')
                .fontSize(Theme.type.caption)
                .fontColor(this.priority === 'medium' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.priority === 'medium' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.priority = 'medium' })
              Text('低')
                .fontSize(Theme.type.caption)
                .fontColor(this.priority === 'low' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.priority === 'low' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.priority = 'low' })
            }

            AppDatePickerField({
              label: '截止日期（可选）',
              value: this.dueDate,
              placeholder: '请选择日期',
              minDaysFromToday: -365,
              maxDaysFromToday: 730,
              onChange: (v: string) => { this.dueDate = v }
            })

            AppButton({
              label: '保存',
              variant: 'primary',
              onTap: () => { void this.save() }
            })
            AppButton({
              label: '删除待办',
              variant: 'danger',
              onTap: () => { this.confirmDelete = true }
            })
          }
          .padding(Theme.space.pageX)
          .width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.confirmDelete) {
        ZhaConfirmDialog({
          title: '删除待办',
          message: '删除后无法恢复。是否继续？',
          confirmLabel: '确认删除',
          danger: true,
          onConfirm: () => { void this.doDelete() },
          onCancel: () => { this.confirmDelete = false }
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
