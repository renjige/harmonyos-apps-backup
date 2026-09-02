import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { TaskItem } from '../../models/TaskModels'
import { TaskBizService } from '../../services/TaskBizService'
import { CommitmentRules } from '../../services/CommitmentRules'
import { AuthService } from '../../services/AuthService'

@Component
export struct FocusSessionOverlay {
  @Prop item: TaskItem = new TaskItem()
  onClose: () => void = () => {}
  onFinished: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State remain: number = 60
  @State selectedSeconds: number = 60
  @State running: boolean = false
  @State saving: boolean = false
  @State errorText: string = ''
  private timerId: number = -1

  aboutToDisappear(): void {
    this.clearTimer()
  }

  private clearTimer(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  private pickDuration(seconds: number): void {
    if (this.running) {
      return
    }
    this.selectedSeconds = seconds
    this.remain = seconds
  }

  private startTimer(): void {
    if (this.running) {
      return
    }
    this.errorText = ''
    this.running = true
    this.remain = this.selectedSeconds
    this.timerId = setInterval((): void => {
      this.tick()
    }, 1000)
  }

  private tick(): void {
    if (this.remain <= 1) {
      this.clearTimer()
      this.remain = 0
      this.running = false
      void this.submitFocus()
      return
    }
    this.remain -= 1
  }

  private async submitFocus(): Promise<void> {
    if (!AuthService.requireAuth('edit_task')) {
      this.onRequireAuth()
      return
    }
    this.saving = true
    const updated = await TaskBizService.recordFocus(this.item.id, this.selectedSeconds)
    this.saving = false
    if (updated === undefined) {
      this.errorText = TaskBizService.lastError.length > 0 ?
        TaskBizService.lastError : '专注记录失败'
      return
    }
    this.onFinished()
    this.onClose()
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => {
          this.clearTimer()
          this.onClose()
        })
        Text('专注工位')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`${this.item.slotLabel()} · 计时结束才能收工完成`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Text(CommitmentRules.formatRemain(this.remain))
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
            .textAlign(TextAlign.Center)

          if (this.errorText.length > 0) {
            Text(this.errorText)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }

          if (!this.running) {
            Text('选择时长（1 分钟可供审核快速走通）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Row({ space: 8 }) {
              Text('1 分钟')
                .fontSize(Theme.type.caption)
                .fontColor(this.selectedSeconds === 60 ?
                  Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.selectedSeconds === 60 ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.pickDuration(60) })
              Text('5 分钟')
                .fontSize(Theme.type.caption)
                .fontColor(this.selectedSeconds === 300 ?
                  Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.selectedSeconds === 300 ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.pickDuration(300) })
              Text('15 分钟')
                .fontSize(Theme.type.caption)
                .fontColor(this.selectedSeconds === 900 ?
                  Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.selectedSeconds === 900 ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.pickDuration(900) })
              Text('25 分钟')
                .fontSize(Theme.type.caption)
                .fontColor(this.selectedSeconds === 1500 ?
                  Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.selectedSeconds === 1500 ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.pickDuration(1500) })
            }
            .width('100%')
            AppButton({
              label: this.saving ? '记录中…' : '开始专注',
              disabled: this.saving,
              onTap: (): void => { this.startTimer() }
            })
          } else {
            Text('请保持本页直至计时结束，中途关闭将不会记为有效专注。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
