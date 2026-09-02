import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppTimePickerField } from '../components/design-system/AppDatePickerField'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { UserProfile } from '../models/ObservationModels'
import { ObservationStore } from '../services/ObservationStore'
import { PrivacyService } from '../services/PrivacyService'
import { ReminderService } from '../services/ReminderService'
import { AppContextService } from '../services/AppContextService'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct SettingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onPrivacyRevoked: () => void = () => {}
  onDataCleared: () => void = () => {}
  @State profile: UserProfile = new UserProfile()
  @State nicknameInput: string = ''
  @State reminderTime: string = '20:00'
  @State themeMode: string = 'system'
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State toastText: string = ''
  @State confirmClear: boolean = false
  @State confirmRevoke: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.profile = await ObservationStore.loadProfile()
    this.nicknameInput = this.profile.nickname
    const m = this.profile.reminderMinute < 10 ? `0${this.profile.reminderMinute}` : `${this.profile.reminderMinute}`
    this.reminderTime = `${this.profile.reminderHour}:${m}`
    const mode = this.profile.themeMode.length > 0 ? this.profile.themeMode : 'system'
    this.themeMode = mode
    Theme.setColorMode(mode as 'light' | 'dark' | 'system')
    AppStorage.setOrCreate('colorMode', mode)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async saveNickname(): Promise<void> {
    this.profile.nickname = this.nicknameInput.trim().length > 0 ? this.nicknameInput.trim() : '漫观者'
    await ObservationStore.saveProfile(this.profile)
    this.showToast('昵称已保存')
  }

  private async applyReminderTime(time: string): Promise<void> {
    const parts = time.split(':')
    if (parts.length < 2) {
      return
    }
    this.profile.reminderHour = parseInt(parts[0], 10)
    this.profile.reminderMinute = parseInt(parts[1], 10)
    this.reminderTime = time
    await ObservationStore.saveProfile(this.profile)
    const ctx = AppContextService.getContext()
    if (ctx !== null && this.profile.reminderEnabled) {
      const ok = await ReminderService.scheduleDaily(this.profile, ctx)
      if (!ok) {
        this.showToast(ReminderService.lastError.length > 0 ? ReminderService.lastError : '提醒设置失败')
        return
      }
    }
    this.showToast(`提醒已设为 ${time}`)
  }

  private async toggleReminder(enabled: boolean): Promise<void> {
    this.profile.reminderEnabled = enabled
    await ObservationStore.saveProfile(this.profile)
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('提醒偏好已保存')
      return
    }
    if (enabled) {
      const ok = await ReminderService.scheduleDaily(this.profile, ctx)
      this.showToast(ok ? '每日提醒已开启' : ReminderService.lastError)
    } else {
      await ReminderService.cancelDaily()
      this.showToast('每日提醒已关闭')
    }
  }

  private async exportAndCopy(): Promise<void> {
    const json = await ObservationStore.exportJson()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, json)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('JSON 已复制到剪贴板，可粘贴到备忘录保存')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private async clearAllNotes(): Promise<void> {
    await ObservationStore.clearAllNotes()
    this.confirmClear = false
    this.onDataCleared()
    this.showToast('全部笔记已清除')
  }

  private async persistTheme(mode: string): Promise<void> {
    this.themeMode = mode
    this.profile.themeMode = mode
    Theme.setColorMode(mode as 'light' | 'dark' | 'system')
    AppStorage.setOrCreate('colorMode', mode)
    await ObservationStore.saveProfile(this.profile)
    this.showToast('主题已切换，杀进程后仍保持')
  }

  private setTheme(mode: string): void {
    void this.persistTheme(mode)
  }

  private clearCache(): void {
    this.showToast('界面缓存已清理（笔记数据未删除）')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.confirmRevoke = false
    this.onPrivacyRevoked()
    this.showToast('已撤回隐私同意，再次进入须重新勾选')
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => this.setTheme(mode))
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('个人设置')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s4 }) {
            Column() {
              AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
            }
            .width(56)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            Column({ space: Theme.space.s2 }) {
              TextInput({ text: this.nicknameInput, placeholder: '昵称' })
                .fontSize(Theme.type.body)
                .onChange((v: string): void => { this.nicknameInput = v })
              AppButton({
                label: '保存昵称',
                variant: 'secondary',
                onTap: (): void => { void this.saveNickname() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Text('每日记录提醒')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')

          Row() {
            Text('开启每日提醒')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.profile.reminderEnabled })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((v: boolean): void => { void this.toggleReminder(v) })
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          AppTimePickerField({
            label: '提醒时间',
            value: this.reminderTime,
            placeholder: '选择提醒时间',
            onChange: (v: string): void => { void this.applyReminderTime(v) }
          })

          Text('外观')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')

          Row({ space: Theme.space.s2 }) {
            this.ThemeChip('跟随系统', 'system')
            this.ThemeChip('浅色', 'light')
            this.ThemeChip('深色', 'dark')
          }

          Text('数据')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')

          AppButton({
            label: '导出 JSON（复制到剪贴板）',
            variant: 'secondary',
            onTap: (): void => { void this.exportAndCopy() }
          })

          AppButton({
            label: '清除缓存',
            variant: 'ghost',
            onTap: (): void => this.clearCache()
          })

          if (!this.confirmClear) {
            AppButton({
              label: '清除全部笔记',
              variant: 'danger',
              onTap: (): void => { this.confirmClear = true }
            })
          } else {
            Column({ space: Theme.space.s2 }) {
              Text('确定清除全部漫观笔记？不可恢复')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().danger)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppButton({
                    label: '取消',
                    variant: 'secondary',
                    onTap: (): void => { this.confirmClear = false }
                  })
                }.layoutWeight(1)
                Column() {
                  AppButton({
                    label: '确认清除',
                    variant: 'danger',
                    onTap: (): void => { void this.clearAllNotes() }
                  })
                }.layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
          }

          Text('协议与隐私')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')

          AppListRow({ title: '隐私政策', onTap: (): void => { this.showPrivacyDoc = true } })
          AppListRow({ title: '用户协议', onTap: (): void => { this.showAgreementDoc = true } })

          if (!this.confirmRevoke) {
            AppButton({
              label: '撤回隐私同意',
              variant: 'ghost',
              onTap: (): void => { this.confirmRevoke = true }
            })
          } else {
            Column({ space: Theme.space.s2 }) {
              Text('撤回后将返回隐私弹窗，本地笔记仍保留')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppButton({
                    label: '取消',
                    variant: 'secondary',
                    onTap: (): void => { this.confirmRevoke = false }
                  })
                }.layoutWeight(1)
                Column() {
                  AppButton({
                    label: '确认撤回',
                    variant: 'danger',
                    onTap: (): void => { void this.handleRevokePrivacy() }
                  })
                }.layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
          }

          Column({ space: 4 }) {
            Text('关于溪漫观')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text('版本 1.0.0 · 溪漫生活\n智慧生活记录与状态洞察 · 数据仅存本机')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .lineHeight(20)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(20)
      }

      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
      }
    }
    .width('100%')
    .height('100%')
  }
}
