import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { TodoSettleOverlay } from '../moment/TodoSettleOverlay'
import { MomentTodo } from '../../models/MomentModels'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'

@Component
export struct TodoDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop todoId: string = ''
  onChanged: () => void = () => {}
  @State todo: MomentTodo = new MomentTodo()
  @State confirmDelete: boolean = false
  @State showSettle: boolean = false
  @State toast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await MomentStore.findTodo(this.todoId)
    if (found !== undefined) {
      this.todo = found
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  private async toggle(): Promise<void> {
    const wasDone = this.todo.isCompleted
    await MomentStore.toggleTodo(this.todo.id)
    await this.reload()
    this.onChanged()
    if (!wasDone && this.todo.isCompleted) {
      this.showSettle = true
    }
  }

  private onSettleClosed(saved: boolean): void {
    this.showSettle = false
    if (saved) {
      this.showToast('已记入时间线')
      this.onChanged()
    }
  }

  private async moveBucket(bucket: string): Promise<void> {
    await MomentStore.moveTodoBucket(this.todo.id, bucket)
    await this.reload()
    this.onChanged()
  }

  private async doDelete(): Promise<void> {
    await MomentStore.deleteTodo(this.todo.id)
    this.onChanged()
    MomentNav.close()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '待办详情',
        onClose: (): void => MomentNav.close()
      }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.banner_todo_calm'))
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
              .borderRadius(16)
            Column()
              .width('100%')
              .height(80)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(45,45,45,0.70)', 1]]
              })
              .borderRadius({ bottomLeft: 16, bottomRight: 16 })
            Text(this.todo.bucketLabel())
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .padding({ left: 16, bottom: 14 })
          }
          .width('100%')
          .clip(true)
          .borderRadius(16)

          AppCard() {
            Column({ space: Theme.space.s2 }) {
              Text(this.todo.content)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(24)
                .width('100%')
                .decoration({
                  type: this.todo.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None
                })
              Text(`${this.todo.priorityLabel()}优先级 · ${this.todo.isCompleted ? '已完成' : '未完成'}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
          }

          AppButton({
            label: this.todo.isCompleted ? '标为未完成' : '标为完成',
            onTap: (): void => { void this.toggle() }
          })
          if (this.todo.isCompleted) {
            AppButton({
              label: '沉淀成小事',
              variant: 'secondary',
              onTap: (): void => { this.showSettle = true }
            })
          }
          Text('调整分组')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            Text('今日')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.todo.bucket === 'today' ? '#FFFFFF' : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.todo.bucket === 'today' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { void this.moveBucket('today') })
            Text('本周')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.todo.bucket === 'week' ? '#FFFFFF' : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.todo.bucket === 'week' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { void this.moveBucket('week') })
            Text('以后')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.todo.bucket === 'later' ? '#FFFFFF' : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.todo.bucket === 'later' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { void this.moveBucket('later') })
          }
          .width('100%')
          AppButton({
            label: '编辑待办',
            variant: 'secondary',
            onTap: (): void => MomentNav.openTodoEditor(this.todo.id)
          })

          if (!this.confirmDelete) {
            AppButton({
              label: '删除',
              variant: 'ghost',
              onTap: (): void => { this.confirmDelete = true }
            })
          } else {
            Column({ space: Theme.space.s2 }) {
              Text('确定删除这条待办？')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().danger)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppButton({
                    label: '取消',
                    variant: 'secondary',
                    onTap: (): void => { this.confirmDelete = false }
                  })
                }.layoutWeight(1)
                Column() {
                  AppButton({
                    label: '确认删除',
                    variant: 'danger',
                    onTap: (): void => { void this.doDelete() }
                  })
                }.layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
          }
          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
      }
      .layoutWeight(1)
      .width('100%')
      }

      if (this.showSettle) {
        Stack({ alignContent: Alignment.Top }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.36)')
            .onClick((): void => this.onSettleClosed(false))
          TodoSettleOverlay({
            todoId: this.todo.id,
            preview: this.todo.content,
            onClosed: (saved: boolean): void => this.onSettleClosed(saved)
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(30)
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }
}
