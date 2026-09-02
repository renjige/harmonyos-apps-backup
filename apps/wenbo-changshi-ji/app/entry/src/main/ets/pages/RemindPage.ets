import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppTimePickerField } from '../components/design-system/AppDatePickerField'
import { common } from '@kit.AbilityKit'
import { RemindPref } from '../models/CommonSenseToolModels'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CommonSenseLocalService } from '../services/CommonSenseLocalService'
import { ReminderService } from '../services/ReminderService'

@Component
export struct RemindPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State remindOn: boolean = false
  @State timeText: string = '21:00'
  @State toastText: string = ''

  aboutToAppear(): void {
    const pref = CommonSenseLocalService.remindPref()
    this.remindOn = pref.enabled
    this.timeText = pref.timeLabel()
  }

  private parseHour(): number {
    const parts = this.timeText.split(':')
    if (parts.length < 2) {
      return 21
    }
    const n = Number.parseInt(parts[0], 10)
    return Number.isNaN(n) ? 21 : n
  }

  private parseMinute(): number {
    const parts = this.timeText.split(':')
    if (parts.length < 2) {
      return 0
    }
    const n = Number.parseInt(parts[1], 10)
    return Number.isNaN(n) ? 0 : n
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    const pref = CommonSenseLocalService.remindPref()
    pref.enabled = this.remindOn
    pref.hour = this.parseHour()
    pref.minute = this.parseMinute()
    await CommonSenseLocalService.saveRemind(pref)
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext
    const ok = await ReminderService.apply(pref, ctx)
    if (ok) {
      this.showToast(this.remindOn ? `已设置每天 ${this.timeText} 提醒` : '已关闭每日提醒')
      return
    }
    if (this.remindOn) {
      this.showToast(ReminderService.lastError.length > 0 ?
        ReminderService.lastError : '偏好已保存，请允许通知与发布提醒权限')
    } else {
      this.showToast('已关闭每日提醒')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { CommonSenseDetailNav.close() })
          Text('常识提醒')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Column({ space: Theme.space.s3 }) {
          Text('每天固定时间提醒你打开「今日常识」读一条。可随时关闭。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Row() {
            Text(this.remindOn ? '每日提醒已开启' : '每日提醒已关闭')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.remindOn })
              .onChange((on: boolean): void => { this.remindOn = on })
          }
          .width('100%')
          AppTimePickerField({
            label: '提醒时间',
            value: this.timeText,
            onChange: (v: string): void => { this.timeText = v }
          })
          AppButton({
            label: '保存提醒设置',
            onTap: (): void => { void this.save() }
          })
        }
        .padding(Theme.space.pageX)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
