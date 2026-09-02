import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { AppIcon } from '../design-system/AppIcon'
import { YunConfirmDialog } from '../yun/YunConfirmDialog'
import { YunTodoItem } from '../../models/YunModels'
import { YunDateHelper, YunLocalStore } from '../../services/YunLocalStore'
import { YunDetailNav } from '../../services/YunDetailNav'
import { ReminderService } from '../../services/ReminderService'
import { AppContextService } from '../../services/AppContextService'

@Component
export struct TodoEditSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop todoId: string = ''
  @State todo: YunTodoItem = new YunTodoItem()
  @State content: string = ''
  @State dueDate: string = ''
  @State dueTime: string = ''
  @State repeatType: string = 'none'
  @State listKind: string = 'remind'
  @State toast: string = ''
  @State confirmDelete: boolean = false
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.todoId === 'new') {
      this.todo = YunTodoItem.create('', '')
      this.content = ''
      this.dueDate = YunDateHelper.todayKey()
      this.dueTime = YunDateHelper.soonTime(5)
      this.repeatType = 'none'
      this.listKind = 'remind'
      return
    }
    const found = await YunLocalStore.findTodo(this.todoId)
    if (found !== undefined) {
      this.todo = found
      this.content = found.content
      this.dueDate = found.dueDate
      this.dueTime = found.dueTime.length > 0 ? found.dueTime : YunDateHelper.soonTime(5)
      this.repeatType = found.repeatType
      this.listKind = found.listKind.length > 0 ? found.listKind : 'remind'
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  private setRepeat(type: string): void {
    this.repeatType = type
  }

  private setKind(kind: string): void {
    this.listKind = kind
  }

  private kindLabel(kind: string): string {
    if (kind === 'shopping') {
      return '购物'
    }
    if (kind === 'chore') {
      return '家务'
    }
    if (kind === 'trip') {
      return '出行'
    }
    if (kind === 'study') {
      return '学习'
    }
    return '提醒'
  }

  private async save(): Promise<void> {
    if (this.content.trim().length === 0) {
      this.showToast('请填写内容')
      return
    }
    if (this.dueDate.length === 0 || this.dueTime.length === 0) {
      this.showToast('请选择提醒日期和时间，否则系统无法到点通知')
      return
    }
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('提醒服务未就绪，请关闭后重开应用')
      return
    }
    let scheduled = false
    if (this.todoId === 'new' || this.todo.id.length === 0) {
      const created = await YunLocalStore.createTodo(
        this.content.trim(),
        this.dueDate,
        this.dueTime,
        this.repeatType,
        this.listKind
      )
      scheduled = await ReminderService.scheduleTodo(created, ctx)
    } else {
      this.todo.content = this.content.trim()
      this.todo.dueDate = this.dueDate
      this.todo.dueTime = this.dueTime
      this.todo.repeatType = this.repeatType
      this.todo.listKind = this.listKind
      await YunLocalStore.saveTodo(this.todo)
      scheduled = await ReminderService.scheduleTodo(this.todo, ctx)
    }
    if (!scheduled) {
      this.showToast(ReminderService.lastError.length > 0 ?
        ReminderService.lastError : '系统提醒未写入，请允许通知与发布提醒')
      return
    }
    this.onSaved()
    YunDetailNav.closeTodoEdit()
  }

  private async doDelete(): Promise<void> {
    this.confirmDelete = false
    if (this.todo.reminderAgentId > 0) {
      await ReminderService.cancelTodo(this.todo.reminderAgentId)
    }
    await YunLocalStore.deleteTodo(this.todoId)
    this.onSaved()
    YunDetailNav.closeTodoEdit()
  }

  @Builder
  KindChip(kind: string) {
    Text(this.kindLabel(kind))
      .fontSize(Theme.type.caption)
      .fontColor(this.listKind === kind ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.listKind === kind ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.setKind(kind) })
  }

  @Builder
  RepeatChip(label: string, type: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.repeatType === type ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.repeatType === type ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.setRepeat(type) })
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text(this.todoId === 'new' ? '新建提醒' : '编辑提醒')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
            .onClick((): void => { YunDetailNav.closeTodoEdit() })
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextArea({ text: this.content, placeholder: '清单或提醒内容' })
              .height(100)
              .fontSize(Theme.type.body)
              .onChange((v: string) => { this.content = v })

            Text('清单类型')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Flex({ wrap: FlexWrap.Wrap }) {
              this.KindChip('remind')
              this.KindChip('shopping')
              this.KindChip('chore')
              this.KindChip('trip')
              this.KindChip('study')
            }
            .width('100%')

            AppDatePickerField({
              label: '提醒日期',
              value: this.dueDate,
              placeholder: '请选择日期',
              minDaysFromToday: 0,
              maxDaysFromToday: 730,
              onChange: (v: string) => { this.dueDate = v }
            })

            AppTimePickerField({
              label: '提醒时间',
              value: this.dueTime,
              placeholder: '请选择时间',
              onChange: (v: string) => { this.dueTime = v }
            })

            Text('重复')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Row({ space: Theme.space.s2 }) {
              this.RepeatChip('不重复', 'none')
              this.RepeatChip('每日', 'daily')
              this.RepeatChip('每周', 'weekly')
              this.RepeatChip('每月', 'monthly')
            }

            AppButton({
              label: '保存并写入系统提醒',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })

            if (this.todoId !== 'new') {
              AppButton({
                label: '删除提醒',
                variant: 'danger',
                onTap: (): void => { this.confirmDelete = true }
              })
            }
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
        YunConfirmDialog({
          title: '删除提醒',
          message: '删除后无法恢复。是否继续？',
          confirmLabel: '确认删除',
          danger: true,
          onConfirm: (): void => { void this.doDelete() },
          onCancel: (): void => { this.confirmDelete = false }
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
