import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppConfirmDialog } from '../design-system/AppConfirmDialog'
import { DetailShell } from './DetailShell'
import { YdTagPicker } from '../yuedong/YdTagPicker'
import { YdTaskItem } from '../../models/YdModels'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdDetailNav } from '../../services/YdDetailNav'

@Component
export struct TaskDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop taskId: string = ''
  onChanged: () => void = () => {}
  @State task: YdTaskItem = new YdTaskItem()
  @State note: string = ''
  @State confirmDelete: boolean = false
  @State isFavorite: boolean = false
  @State toast: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const t = await YdLocalStore.findTask(this.taskId)
    if (t !== undefined) {
      this.task = YdLocalStore.cloneTask(t)
      this.note = t.note
      this.isFavorite = await YdLocalStore.isFavorite('task', t.id)
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  build() {
    DetailShell({
      title: this.task.title.length > 0 ? this.task.title : '任务详情',
      onClose: (): void => { YdDetailNav.closeTaskDetail() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_ambient'))
              .width('100%')
              .height(148)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Text(this.task.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.55)', 1]]
              })
          }
          .width('100%')

          Text(`${this.task.timeSlot} · ${this.task.domainLabel()} · ${this.task.priorityLabel()}优先 · 已投入 ${this.task.durationMin} 分钟`)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

          Column({ space: Theme.space.s2 }) {
            Text('执行备注')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            TextArea({ text: this.note, placeholder: '卡住的点、下一步、需要准备什么…' })
              .height(88)
              .onChange((v: string) => { this.note = v })
            AppButton({
              label: '保存备注',
              variant: 'secondary',
              onTap: (): void => { void this.saveNote() }
            })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          YdTagPicker({
            entityType: 'task',
            entityId: this.task.id,
            onChanged: (): void => { this.onChanged() }
          })

          Text('补记实际投入（计入复盘时间账）')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Row({ space: Theme.space.s2 }) {
            this.FocusChip(15)
            this.FocusChip(25)
            this.FocusChip(50)
          }

          AppButton({
            label: this.task.done ? '标记为未完成' : '完成本步',
            variant: 'primary',
            onTap: (): void => {
              const targetDone = !this.task.done
              this.task.done = targetDone
              void YdLocalStore.setTaskDone(this.task.id, targetDone).then(async () => {
                await this.load()
                this.onChanged()
                this.showToast(targetDone ? '已记入今日章' : '已恢复为进行中')
              })
            }
          })
          AppButton({
            label: this.isFavorite ? '取消收藏' : '收藏任务',
            variant: 'secondary',
            onTap: (): void => { void this.toggleFavorite() }
          })
          AppButton({
            label: '删除任务',
            variant: 'secondary',
            onTap: (): void => { this.confirmDelete = true }
          })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(20)
      }

      if (this.confirmDelete) {
        AppConfirmDialog({
          title: '删除任务',
          message: '确认删除此任务？已投入的分钟数将从时间账中移除。',
          confirmLabel: '删除',
          cancelLabel: '取消',
          danger: true,
          onConfirm: (): void => {
            void YdLocalStore.deleteTask(this.task.id).then((): void => {
              this.confirmDelete = false
              this.onChanged()
              YdDetailNav.closeTaskDetail()
            })
          },
          onCancel: (): void => { this.confirmDelete = false }
        })
      }
    }
  }

  @Builder
  FocusChip(n: number) {
    Text(`+${n} 分钟`)
      .fontSize(Theme.type.subhead)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        void YdLocalStore.addFocusMinutes(this.task.id, n).then(async () => {
          await this.load()
          this.onChanged()
          this.showToast(`已补记 ${n} 分钟`)
        })
      })
  }

  private async saveNote(): Promise<void> {
    this.task.note = this.note
    await YdLocalStore.updateTask(this.task)
    this.onChanged()
    this.showToast('备注已保存')
  }

  private async toggleFavorite(): Promise<void> {
    this.isFavorite = await YdLocalStore.toggleFavorite('task', this.task.id, this.task.title)
    this.onChanged()
    this.showToast(this.isFavorite ? '已加入收藏' : '已取消收藏')
  }
}
