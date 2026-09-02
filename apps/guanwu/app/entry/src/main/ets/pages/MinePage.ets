import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppTimePickerField } from '../components/design-system/AppDatePickerField'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { UserProfile } from '../models/ObserveModels'
import { ObserveStore } from '../services/ObserveStore'
import { PrivacyService } from '../services/PrivacyService'
import { ReminderService } from '../services/ReminderService'
import { AppContextService } from '../services/AppContextService'
import { AuthService } from '../services/AuthService'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @Prop appName: string = '观物'
  onPrivacyRevoked: () => void = () => {}
  onDataCleared: () => void = () => {}
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State profile: UserProfile = new UserProfile()
  @State nicknameInput: string = ''
  @State signatureInput: string = ''
  @State reminderTime: string = '21:00'
  @State themeMode: string = 'system'
  @State totalCount: number = 0
  @State streakDays: number = 0
  @State uniqueDays: number = 0
  @State showSettings: boolean = false
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State toastText: string = ''
  @State confirmClear: boolean = false
  @State confirmRevoke: boolean = false
  @State confirmDeleteAccount: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async reload(): Promise<void> {
    this.profile = await ObserveStore.loadProfile()
    this.nicknameInput = this.profile.nickname
    this.signatureInput = this.profile.signature
    const m = this.profile.reminderMinute < 10 ? `0${this.profile.reminderMinute}` : `${this.profile.reminderMinute}`
    this.reminderTime = `${this.profile.reminderHour}:${m}`
    this.themeMode = this.profile.themeMode.length > 0 ? this.profile.themeMode : 'system'
    const all = await ObserveStore.loadAll()
    this.totalCount = all.length
    this.streakDays = await ObserveStore.streakDays()
    this.uniqueDays = await ObserveStore.uniqueDays()
  }

  private async saveProfile(): Promise<void> {
    this.profile.nickname = this.nicknameInput.trim().length > 0 ? this.nicknameInput.trim() : '观物者'
    this.profile.signature = this.signatureInput.trim()
    await ObserveStore.saveProfile(this.profile)
    this.showToast('资料已保存')
  }

  private async toggleReminder(enabled: boolean): Promise<void> {
    this.profile.reminderEnabled = enabled
    await ObserveStore.saveProfile(this.profile)
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('提醒偏好已保存')
      return
    }
    if (enabled) {
      const ok = await ReminderService.scheduleDaily(this.profile, ctx)
      if (!ok) {
        this.profile.reminderEnabled = false
        await ObserveStore.saveProfile(this.profile)
      }
      this.showToast(ok ?
        (ReminderService.lastError.length > 0 ? ReminderService.lastError : '智慧提醒已开启') :
        ReminderService.lastError)
    } else {
      await ReminderService.cancelDaily()
      this.showToast('智慧提醒已关闭')
    }
  }

  private async applyReminderTime(time: string): Promise<void> {
    const parts = time.split(':')
    if (parts.length < 2) {
      return
    }
    this.profile.reminderHour = parseInt(parts[0], 10)
    this.profile.reminderMinute = parseInt(parts[1], 10)
    this.reminderTime = time
    await ObserveStore.saveProfile(this.profile)
    const ctx = AppContextService.getContext()
    if (ctx !== null && this.profile.reminderEnabled) {
      const ok = await ReminderService.scheduleDaily(this.profile, ctx)
      if (!ok) {
        this.profile.reminderEnabled = false
        await ObserveStore.saveProfile(this.profile)
      }
      this.showToast(ok ?
        (ReminderService.lastError.length > 0 ? ReminderService.lastError : `已预约提醒 ${time}`) :
        ReminderService.lastError)
      return
    }
    this.showToast(`提醒时间已保存为 ${time}，开启开关后才会预约`)
  }

  private async exportData(): Promise<void> {
    const json = await ObserveStore.exportJson()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, json)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('JSON 已复制到剪贴板')
    } catch {
      this.showToast('导出失败')
    }
  }

  private async clearRecords(): Promise<void> {
    await ObserveStore.clearAllRecords()
    this.confirmClear = false
    this.onDataCleared()
    this.showToast('全部观察记录已清除')
    await this.reload()
  }

  private async setTheme(mode: string): Promise<void> {
    this.themeMode = mode
    this.profile.themeMode = mode
    const ctx = AppContextService.getContext()
    ThemeAppearance.apply(mode, ctx !== null ? ctx : undefined)
    await ObserveStore.saveProfile(this.profile)
    this.showToast(mode === 'light' ? '已切换浅色模式' : (mode === 'dark' ? '已切换深色模式' : '已跟随系统外观'))
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.showSettings = false
    this.confirmRevoke = false
    this.onPrivacyRevoked()
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
    if (!this.confirmDeleteAccount) {
      this.confirmDeleteAccount = true
      this.showToast('再点一次确认注销账号')
      return
    }
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.showSettings = false
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.setTheme(mode) })
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'user', iconSize: 32, color: Theme.colors().brandPrimary })
            }
            .width(72)
            .height(72)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(36)
            Text(this.profile.nickname)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text(this.profile.signature)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
            Text(this.isLoggedIn() ? `账号：${this.currentUsername}` : '游客模式 · 可选登录')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Row({ space: Theme.space.s3 }) {
            Column() {
              Text(`${this.uniqueDays}`)
                .fontSize(Theme.type.title2)
                .fontColor(Theme.colors().textPrimary)
              Text('累计天数')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }.layoutWeight(1)
            Column() {
              Text(`${this.totalCount}`)
                .fontSize(Theme.type.title2)
                .fontColor(Theme.colors().textPrimary)
              Text('总记录')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }.layoutWeight(1)
            Column() {
              Text(`${this.streakDays}`)
                .fontSize(Theme.type.title2)
                .fontColor(Theme.colors().textPrimary)
              Text('连续天数')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }.layoutWeight(1)
          }
          .width('100%')

          if (!this.isLoggedIn()) {
            AppButton({ label: '登录 / 注册', variant: 'secondary', onTap: (): void => this.onOpenLogin() })
          } else {
            AppButton({
              label: '退出登录',
              variant: 'ghost',
              onTap: (): void => {
                AuthService.logout()
                this.onLogout()
                this.showToast('已退出登录')
              }
            })
          }

          AppListRow({
            title: '设置与隐私',
            subtitle: '主题、提醒、导出与协议',
            onTap: (): void => { this.showSettings = true }
          })

          Text('观物 v1.0.5')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4, bottom: this.bottomInset })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showSettings) {
        this.SettingsPanel()
      }

      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
          .zIndex(25)
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
          .zIndex(25)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SettingsPanel() {
    Column() {
      Row() {
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('关闭')
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.showSettings = false })
      }
      .width('100%')
      .padding(Theme.space.s4)

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.nicknameInput, placeholder: '昵称' })
            .onChange((v: string): void => { this.nicknameInput = v })
          TextInput({ text: this.signatureInput, placeholder: '个性签名' })
            .onChange((v: string): void => { this.signatureInput = v })
          AppButton({ label: '保存资料', variant: 'secondary', onTap: (): void => { void this.saveProfile() } })

          Text('外观模式').fontSize(Theme.type.subhead).fontColor(Theme.colors().textSecondary).width('100%')
          Row({ space: Theme.space.s2 }) {
            this.ThemeChip('浅色', 'light')
            this.ThemeChip('深色', 'dark')
            this.ThemeChip('跟随系统', 'system')
          }

          Row() {
            Text('智慧提醒').layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.profile.reminderEnabled })
              .onChange((v: boolean): void => { void this.toggleReminder(v) })
          }
          .width('100%')
          AppTimePickerField({
            label: '提醒时间（到点才响，不会立刻弹出）',
            value: this.reminderTime,
            onChange: (v: string): void => { void this.applyReminderTime(v) }
          })

          AppButton({ label: '导出 JSON 到剪贴板', variant: 'secondary', onTap: (): void => { void this.exportData() } })
          AppButton({
            label: this.confirmClear ? '再次点击确认清除全部记录' : '清除全部观察记录',
            variant: 'danger',
            onTap: (): void => {
              if (!this.confirmClear) {
                this.confirmClear = true
                return
              }
              void this.clearRecords()
            }
          })
          AppButton({ label: '清除界面缓存', variant: 'ghost', onTap: (): void => this.showToast('已清除界面缓存') })

          AppListRow({ title: '用户协议', onTap: (): void => { this.showAgreementDoc = true } })
          AppListRow({ title: '隐私政策', onTap: (): void => { this.showPrivacyDoc = true } })

          Row() {
            AppButton({
              label: this.confirmRevoke ? '再次点击确认撤回' : '撤回隐私同意',
              variant: 'secondary',
              onTap: (): void => { void this.handleRevokePrivacy() }
            })
          }
          .width('100%')
          .onClick((): void => { void this.handleRevokePrivacy() })

          if (this.isLoggedIn()) {
            AppButton({
              label: this.confirmDeleteAccount ? '再次点击确认注销' : '注销账号',
              variant: 'danger',
              onTap: (): void => { void this.handleDeleteAccount() }
            })
          }
        }
        .padding(Theme.space.s4)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(10)
  }
}
