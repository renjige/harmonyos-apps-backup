import { Theme } from '../design-system/Theme'
import { AppTextInput } from '../design-system/AppTextInput'
import { AppTextArea } from '../design-system/AppTextArea'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CreateHabitRequest } from '../../models/TaskModels'
import { TaskBizService } from '../../services/TaskBizService'
import { AuthService } from '../../services/AuthService'

@Component
export struct CreateHabitOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onSaved: () => void = () => {}
  @State newTitle: string = ''
  @State newDesc: string = ''
  @State newTargetDays: number = 21
  @State saving: boolean = false
  @State errorText: string = ''
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  private targetOptions: number[] = [7, 14, 21, 30, 60, 90]

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async handleSave(): Promise<void> {
    if (!AuthService.requireAuth('create_habit')) {
      this.onRequireAuth()
      return
    }
    if (this.newTitle.trim().length === 0) {
      this.errorText = '请填写习惯名称'
      return
    }
    this.errorText = ''
    this.saving = true
    try {
      const req = new CreateHabitRequest()
      req.title = this.newTitle.trim()
      req.description = this.newDesc
      req.targetDays = this.newTargetDays
      req.userId = this.currentUsername
      const created = await TaskBizService.createHabit(req)
      if (created !== undefined) {
        this.showToast('习惯已创建')
        this.onSaved()
        this.onClose()
      } else {
        this.errorText = TaskBizService.lastError.length > 0 ?
          TaskBizService.lastError : '创建失败，请稍后重试'
      }
    } catch {
      this.errorText = TaskBizService.lastError.length > 0 ?
        TaskBizService.lastError : '创建失败，请稍后重试'
    } finally {
      this.saving = false
    }
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => this.onClose())
          Text('新建习惯')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column({ space: 6 }) {
              Text('习惯名称')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              AppTextInput({
                text: this.newTitle,
                placeholder: '如：早起、阅读、运动',
                onChange: (v: string) => { this.newTitle = v }
              })
            }
            .width('100%')

            Column({ space: 6 }) {
              Text('习惯说明')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              AppTextArea({
                text: this.newDesc,
                placeholder: '补充习惯目标或提醒（选填）',
                onChange: (v: string) => { this.newDesc = v }
              })
            }
            .width('100%')

            Column({ space: 8 }) {
              Text('目标天数')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.targetOptions, (days: number) => {
                  Text(`${days} 天`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.newTargetDays === days ?
                      Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(this.newTargetDays === days ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                    .onClick((): void => { this.newTargetDays = days })
                }, (days: number) => `${days}`)
              }
              .width('100%')
            }
            .width('100%')

            AppButton({
              label: this.saving ? '保存中…' : '保存习惯',
              disabled: this.saving,
              onTap: (): void => { void this.handleSave() }
            })
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
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

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
}
