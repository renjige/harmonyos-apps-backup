import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { TaskItem } from '../../models/TaskModels'
import { TaskBizService } from '../../services/TaskBizService'
import { CommitmentRules } from '../../services/CommitmentRules'
import { AuthService } from '../../services/AuthService'

@Component
export struct CloseDayOverlay {
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State items: TaskItem[] = []
  @State reason: string = '时间不够'
  @State saving: boolean = false
  @State errorText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  private reasons: string[] = ['时间不够', '被打断', '估时不准', '优先级变化']

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const today = TaskBizService.todayLocal()
    const all = await TaskBizService.loadTasks(this.currentUsername, '', '', today)
    const open: TaskItem[] = []
    for (const item of CommitmentRules.commitmentsOf(all, today)) {
      if (!item.isDone() && item.closeReason.length === 0) {
        open.push(item)
      }
    }
    this.items = open
  }

  private async handleSave(): Promise<void> {
    if (!AuthService.requireAuth('edit_task')) {
      this.onRequireAuth()
      return
    }
    this.saving = true
    this.errorText = ''
    for (const item of this.items) {
      const ok = await TaskBizService.setCloseReason(item.id, item, this.reason)
      if (ok === undefined) {
        this.errorText = TaskBizService.lastError
        this.saving = false
        return
      }
    }
    this.saving = false
    this.onSaved()
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
        .onClick((): void => this.onClose())
        Text('今日关帐')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('未兑现的承诺需要写明原因，才能结束今天。这不是备忘勾选，而是对限量承诺负责。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .lineHeight(22)

          if (this.items.length === 0) {
            AppEmpty({
              title: '没有待关帐承诺',
              description: '今日承诺已完成或尚未创建'
            })
          } else {
            ForEach(this.items, (item: TaskItem) => {
              Text(`${item.slotLabel()} · ${item.title}`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
            }, (item: TaskItem) => item.id)

            Text('未完成原因')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.reasons, (r: string) => {
                Text(r)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.reason === r ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.reason === r ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.reason = r })
              }, (r: string) => r)
            }
            .width('100%')

            if (this.errorText.length > 0) {
              Text(this.errorText)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().danger)
                .width('100%')
            }

            AppButton({
              label: this.saving ? '提交中…' : '确认关帐',
              disabled: this.saving,
              onTap: (): void => { void this.handleSave() }
            })
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
