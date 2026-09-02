import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { TaskItem } from '../../models/TaskModels'
import { TaskBizService } from '../../services/TaskBizService'
import { TaskDetailNav } from '../../services/TaskDetailNav'
import { TaskDetailCache } from '../../services/TaskDetailCache'
import { AuthService } from '../../services/AuthService'

@Component
export struct TaskDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onEdit: (item: TaskItem) => void = () => {}
  onCompleted: () => void = () => {}
  onDeleted: () => void = () => {}
  onStartFocus: (item: TaskItem) => void = (_item: TaskItem) => {}
  @State item: TaskItem | undefined = undefined
  @State loading: boolean = true
  @State loadFailed: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onRefreshTokenChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    const cached = TaskDetailCache.peek(this.itemId)
    if (cached !== undefined) {
      this.item = cached
      this.loadFailed = false
      this.loading = false
    } else {
      this.loading = true
      this.loadFailed = false
    }
    if (!AuthService.isLoggedIn()) {
      this.loading = false
      this.loadFailed = true
      this.item = undefined
      TaskBizService.lastError = '请先登录后查看事项详情'
      return
    }
    const fresh = await TaskBizService.findTask(this.itemId)
    if (fresh !== undefined) {
      this.item = fresh
      this.loadFailed = false
    } else if (cached === undefined) {
      this.item = undefined
      this.loadFailed = true
    }
    this.loading = false
  }

  private async handleComplete(): Promise<void> {
    if (!AuthService.requireAuth('edit_task')) {
      this.onRequireAuth()
      return
    }
    const updated = await TaskBizService.patchTaskStatus(this.itemId, 'done')
    if (updated !== undefined) {
      this.item = updated
      this.showToast('事项已完成')
      this.onCompleted()
    } else {
      this.showToast(TaskBizService.lastError.length > 0 ?
        TaskBizService.lastError : '操作失败，请稍后重试')
    }
  }

  private async handleDelete(): Promise<void> {
    if (!AuthService.requireAuth('edit_task')) {
      this.onRequireAuth()
      return
    }
    const ok = await TaskBizService.deleteTask(this.itemId)
    if (ok) {
      this.showToast('事项已删除')
      this.onDeleted()
      TaskDetailNav.close()
    } else {
      this.showToast(TaskBizService.lastError.length > 0 ?
        TaskBizService.lastError : '删除失败')
    }
  }

  build() {
    Stack() {
      DetailShell({
        title: '事项详情',
        onClose: (): void => { TaskDetailNav.close() },
        body: (): void => { this.DetailBody() }
      })

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.loading && this.item === undefined) {
      AppLoading({ label: '加载事项…' })
    } else if (this.loadFailed && this.item === undefined) {
      Column({ space: Theme.space.s4 }) {
        AppEmpty({
          title: '暂时无法加载',
          description: TaskBizService.lastError.length > 0 ?
            TaskBizService.lastError : '请检查网络后重试',
          actionLabel: '重试',
          onAction: (): void => { void this.loadItem() }
        })
        AppButton({
          label: '返回',
          variant: 'secondary',
          onTap: (): void => { TaskDetailNav.close() }
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    } else if (this.item !== undefined) {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_productivity'))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(180)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.72)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.item.laneLabel() + ' · ' + this.item.slotLabel() + ' · ' +
              this.item.priorityLabel() + '优先级 · ' +
              (this.item.isDone() ? '已完成' : '待处理'))
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(this.item.tags, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
            }, (tag: string) => tag)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.item.summary.length > 0) {
          Column() {
            AppCard({ title: '摘要', variant: 'plain' }) {
              Text(this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppCard({ title: '说明', variant: 'plain' }) {
            Text(this.item.description.length > 0 ? this.item.description :
              (this.item.body.length > 0 ? this.item.body : '（无详细说明）'))
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '执行规则', variant: 'plain' }) {
            Text(this.item.focusReady ?
              `已完成专注 ${Math.floor(this.item.focusSeconds / 60)} 分钟，可以收工。` :
              '不能直接勾选完成。请先「开始专注」，计时结束后才能收工。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s3 }) {
          if (!this.item.isDone()) {
            if (this.item.focusReady) {
              AppButton({
                label: '收工完成',
                onTap: (): void => { void this.handleComplete() }
              })
                .layoutWeight(1)
            } else {
              AppButton({
                label: '开始专注',
                onTap: (): void => {
                  if (this.item !== undefined) {
                    this.onStartFocus(this.item)
                  }
                }
              })
                .layoutWeight(1)
            }
          }
          AppButton({
            label: '编辑事项',
            variant: 'secondary',
            onTap: (): void => {
              if (!AuthService.requireAuth('edit_task')) {
                this.onRequireAuth()
                return
              }
              if (this.item !== undefined) {
                this.onEdit(this.item)
              }
            }
          })
            .layoutWeight(1)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row() {
          AppButton({
            label: '删除事项',
            variant: 'danger',
            onTap: (): void => { void this.handleDelete() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
