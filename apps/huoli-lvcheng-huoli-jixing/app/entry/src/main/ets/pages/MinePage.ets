import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppTimePickerField } from '../components/design-system/AppDatePickerField'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { UserProfile } from '../models/VitalityModels'
import { VitalityStore } from '../services/VitalityStore'
import { PrivacyService } from '../services/PrivacyService'
import { ReminderService } from '../services/ReminderService'
import { AppContextService } from '../services/AppContextService'
import { StatsService } from '../services/StatsService'
import { pasteboard } from '@kit.BasicServicesKit'
import { Want } from '@kit.AbilityKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onDataCleared: () => void = () => {}
  @State profile: UserProfile = new UserProfile()
  @State nicknameInput: string = ''
  @State reminderTime: string = '20:00'
  @State themeMode: string = 'system'
  @State totalDays: number = 0
  @State monthRate: number = 0
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State showSettings: boolean = false
  @State toastText: string = ''
  @State confirmClear: boolean = false
  @State confirmRevoke: boolean = false
  @State reminderOn: boolean = false
  private reminderSyncing: boolean = false
  private skipNextReminderEvent: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.profile = await VitalityStore.loadProfile()
    this.nicknameInput = this.profile.nickname
    const m = this.profile.reminderMinute < 10 ? `0${this.profile.reminderMinute}` : `${this.profile.reminderMinute}`
    this.reminderTime = `${this.profile.reminderHour}:${m}`
    const mode = this.profile.themeMode.length > 0 ? this.profile.themeMode : 'system'
    this.themeMode = mode
    ThemeAppearance.apply(mode as 'light' | 'dark' | 'system', this.getUIContext().getHostContext() as common.UIAbilityContext)
    AppStorage.setOrCreate('colorMode', mode)
    this.totalDays = await StatsService.totalCheckIns()
    this.monthRate = await StatsService.monthCheckInRate()
    this.reminderOn = this.profile.reminderEnabled
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async saveNickname(): Promise<void> {
    this.profile.nickname = this.nicknameInput.trim().length > 0 ? this.nicknameInput.trim() : '活力旅人'
    await VitalityStore.saveProfile(this.profile)
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
    await VitalityStore.saveProfile(this.profile)
    const ctx = AppContextService.getContext()
    if (ctx !== null && this.reminderOn) {
      const ok = await ReminderService.scheduleDaily(this.profile, ctx)
      if (!ok) {
        this.showToast(ReminderService.lastError.length > 0 ? ReminderService.lastError : '提醒设置失败')
        return
      }
    }
    this.showToast(`提醒已设为 ${time}`)
  }

  private async toggleReminder(enabled: boolean): Promise<void> {
    if (this.reminderSyncing) {
      return
    }
    this.reminderSyncing = true
    const prev = this.profile.reminderEnabled
    this.profile.reminderEnabled = enabled
    this.reminderOn = enabled
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      await VitalityStore.saveProfile(this.profile)
      this.showToast(enabled ? '提醒偏好已保存' : '每日提醒已关闭')
      this.reminderSyncing = false
      return
    }
    if (enabled) {
      const ok = await ReminderService.scheduleDaily(this.profile, ctx)
      if (!ok) {
        this.profile.reminderEnabled = prev
        this.skipNextReminderEvent = true
        this.reminderOn = prev
        await VitalityStore.saveProfile(this.profile)
        this.showToast(ReminderService.lastError.length > 0 ? ReminderService.lastError : '提醒设置失败，请检查通知权限')
        this.reminderSyncing = false
        return
      }
      this.profile.reminderEnabled = true
      this.reminderOn = true
      await VitalityStore.saveProfile(this.profile)
      const hint = ReminderService.lastError.length > 0 ? ReminderService.lastError : '每日提醒已开启'
      this.showToast(hint)
    } else {
      this.profile.reminderEnabled = false
      this.reminderOn = false
      await VitalityStore.saveProfile(this.profile)
      await ReminderService.cancelDaily()
      this.showToast('每日提醒已关闭')
    }
    this.reminderSyncing = false
  }

  private onReminderSwitch(enabled: boolean): void {
    if (this.skipNextReminderEvent) {
      this.skipNextReminderEvent = false
      return
    }
    if (this.reminderSyncing) {
      return
    }
    void this.toggleReminder(enabled)
  }

  private async exportAndCopy(): Promise<void> {
    const text = await VitalityStore.exportJson()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('数据已复制到剪贴板，可粘贴到备忘录保存')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private async clearAllRecords(): Promise<void> {
    await VitalityStore.clearAllRecords()
    this.confirmClear = false
    this.onDataCleared()
    this.showToast('全部打卡记录已清除')
  }

  private async persistTheme(mode: string): Promise<void> {
    this.themeMode = mode
    this.profile.themeMode = mode
    ThemeAppearance.apply(mode as 'light' | 'dark' | 'system', this.getUIContext().getHostContext() as common.UIAbilityContext)
    AppStorage.setOrCreate('colorMode', mode)
    await VitalityStore.saveProfile(this.profile)
    this.showToast('主题已切换')
  }

  private clearCache(): void {
    AppStorage.setOrCreate('apiBaseUrl', '')
    this.showToast('本地缓存偏好已重置（打卡数据未删除）')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.confirmRevoke = false
    this.showSettings = false
    this.showToast('已撤回本地隐私偏好。隐私授权由系统托管服务管理，可在系统设置中查看。')
  }

  private openFeedback(): void {
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('无法打开邮件，请通过华为开发者渠道反馈')
      return
    }
    const want: Want = {
      action: 'ohos.want.action.sendToData',
      uri: 'mailto:support@huolijixing.local?subject=活力纪行反馈'
    }
    ctx.startAbility(want).catch((): void => {
      this.showToast('未找到邮件应用，请通过应用市场评论反馈')
    })
  }

  @Builder
  GoalChip(label: string, days: number) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.profile.weeklyGoalDays === days ?
        Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.profile.weeklyGoalDays === days ?
        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.saveWeeklyGoal(days) })
  }

  private async saveWeeklyGoal(days: number): Promise<void> {
    this.profile.weeklyGoalDays = days
    await VitalityStore.saveProfile(this.profile)
    this.showToast(`本周目标已设为 ${days} 天`)
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.persistTheme(mode) })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('我的')
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

          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              Text(`${this.totalDays}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
              Text('总打卡天数')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            Column({ space: 4 }) {
              Text(`${this.monthRate}%`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().success)
              Text('本月打卡率')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          }
          .width('100%')

          AppListRow({
            title: '打卡提醒',
            subtitle: this.profile.reminderEnabled ? `每日 ${this.reminderTime}` : '未开启',
            onTap: (): void => { this.showSettings = true }
          })

          AppListRow({
            title: '导出数据',
            subtitle: '复制为文本格式',
            onTap: (): void => { void this.exportAndCopy() }
          })

          AppListRow({
            title: '设置与隐私',
            subtitle: '协议 · 撤回 · 主题',
            onTap: (): void => { this.showSettings = true }
          })

          AppListRow({
            title: '关于活力纪行',
            subtitle: '版本 1.0.0 · 每日活力记录',
            onTap: (): void => { this.showToast('活力纪行 — 轻量级每日活力记录与回顾') }
          })

          AppListRow({
            title: '反馈建议',
            subtitle: '通过系统邮件联系我们',
            onTap: (): void => this.openFeedback()
          })

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      if (this.showSettings) {
        this.SettingsPanel()
      }

      if (this.showPrivacyDoc) {
        Stack() {
          LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
        }
        .width('100%')
        .height('100%')
        .zIndex(50)
      }

      if (this.showAgreementDoc) {
        Stack() {
          LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
        }
        .width('100%')
        .height('100%')
        .zIndex(50)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,42,58,0.88)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 56 })
          .markAnchor({ x: '50%', y: 0 })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SettingsPanel() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.showSettings = false })

      Column({ space: Theme.space.s4 }) {
        Row() {
          Text('设置与隐私')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
            .onClick((): void => { this.showSettings = false })
        }
        .width('100%')

        Row() {
          Text('开启每日提醒')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.reminderOn })
            .selectedColor(Theme.colors().brandPrimary)
            .onChange((v: boolean): void => { this.onReminderSwitch(v) })
        }
        .width('100%')

        if (this.reminderOn) {
          AppTimePickerField({
            label: '提醒时间',
            value: this.reminderTime,
            onChange: (v: string): void => { void this.applyReminderTime(v) }
          })
        }

        Text('本周打卡目标（天）')
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.GoalChip('3', 3)
          this.GoalChip('5', 5)
          this.GoalChip('7', 7)
        }
        .width('100%')

        Text('外观主题')
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.ThemeChip('浅色', 'light')
          this.ThemeChip('深色', 'dark')
          this.ThemeChip('跟随系统', 'system')
        }
        .width('100%')

        AppListRow({
          title: '《用户协议》',
          subtitle: '',
          onTap: (): void => {
            this.showAgreementDoc = true
          }
        })
        AppListRow({
          title: '《隐私政策》',
          subtitle: '',
          onTap: (): void => {
            this.showPrivacyDoc = true
          }
        })

        AppButton({
          label: '清除缓存',
          variant: 'secondary',
          onTap: (): void => this.clearCache()
        })

        AppButton({
          label: '清除全部打卡记录',
          variant: 'secondary',
          onTap: (): void => { this.confirmClear = true }
        })

        Row() {
          AppButton({
            label: '撤回隐私同意',
            variant: 'secondary',
            onTap: (): void => { void this.handleRevokePrivacy() }
          })
        }
        .width('100%')
        .onClick((): void => { void this.handleRevokePrivacy() })
      }
      .width('100%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
    }
    .width('100%')
    .height('100%')
    .zIndex(20)

    if (this.confirmClear) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().overlayScrim)
        Column({ space: Theme.space.s4 }) {
          Text('确认清除全部打卡记录？')
            .fontSize(Theme.type.title3)
            .fontColor(Theme.colors().textPrimary)
          Text('此操作不可恢复，成就进度也将重置。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.confirmClear = false }
            }).layoutWeight(1)
            AppButton({
              label: '确认清除',
              variant: 'primary',
              onTap: (): void => { void this.clearAllRecords() }
            }).layoutWeight(1)
          }
          .width('100%')
        }
        .width('84%')
        .padding(Theme.space.s6)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }
      .width('100%')
      .height('100%')
      .zIndex(30)
    }
  }
}
