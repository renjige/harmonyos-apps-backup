import { common } from '@kit.AbilityKit'
import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { ConfirmSheet } from '../components/journal/ConfirmSheet'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { ReminderService } from '../services/ReminderService'
import { YouyuMedia } from '../services/YouyuMedia'
import { YouyuStore } from '../services/YouyuStore'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '悠隅纪'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('youyuOpenMineSettings') showSettings: boolean = false
  @State toastText: string = ''
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State showExport: boolean = false
  @State exportText: string = ''
  @State confirmClear: boolean = false
  @State confirmAccount: boolean = false
  @State remindOn: boolean = false
  @State remindLabel: string = '21:30'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    const s = YouyuStore.settings()
    this.remindOn = s.reminderEnabled
    this.remindLabel = MinePage.padTime(s.reminderHour, s.reminderMinute)
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  private static padTime(h: number, m: number): string {
    const hs = h < 10 ? `0${h}` : `${h}`
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${hs}:${ms}`
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.showSettings = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
    const ok = await PrivacyService.deleteAccount()
    this.confirmAccount = false
    if (ok) {
      await AuthService.logout()
      this.showSettings = false
      AppStorage.setOrCreate('tabBarHidden', false)
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private async toggleDark(on: boolean): Promise<void> {
    ThemeAppearance.apply(on ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    const s = YouyuStore.settings()
    s.darkMode = on
    await YouyuStore.saveSettings(s)
  }

  private async toggleRemind(on: boolean): Promise<void> {
    const s = YouyuStore.settings()
    s.reminderEnabled = on
    this.remindOn = on
    const ctx = getContext(this) as common.UIAbilityContext
    const ok = await ReminderService.scheduleDaily(s, ctx)
    if (!ok) {
      this.remindOn = false
      s.reminderEnabled = false
      await YouyuStore.saveSettings(s)
      this.showToast(ReminderService.lastError)
      return
    }
    this.showToast(on ? '已开启每日记录提醒' : '已关闭提醒')
  }

  private pickRemindTime(): void {
    const s = YouyuStore.settings()
    const selected = new Date()
    selected.setHours(s.reminderHour, s.reminderMinute, 0, 0)
    TimePickerDialog.show({
      selected: selected,
      useMilitaryTime: true,
      onAccept: (value: TimePickerResult) => {
        void this.applyRemindTime(value.hour, value.minute)
      }
    })
  }

  private async applyRemindTime(hour: number, minute: number): Promise<void> {
    const s = YouyuStore.settings()
    s.reminderHour = hour
    s.reminderMinute = minute
    this.remindLabel = MinePage.padTime(hour, minute)
    if (s.reminderEnabled) {
      const ctx = getContext(this) as common.UIAbilityContext
      await ReminderService.scheduleDaily(s, ctx)
    } else {
      await YouyuStore.saveSettings(s)
    }
  }

  private async copyExport(): Promise<void> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.exportText)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('已复制到剪贴板')
    } catch {
      this.showToast('复制失败，请长按文字自行复制')
    }
  }

  private handleClearCache(): void {
    AppStorage.setOrCreate('localCacheEpoch', Date.now())
    this.showToast('已清除本地缓存')
  }

  private async doClearRecords(): Promise<void> {
    const ok = await YouyuStore.clearAll()
    this.confirmClear = false
    this.showToast(ok ? '本机记录已清空' : '清空失败')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          this.MainPanel()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.confirmClear) {
        ConfirmSheet({
          title: '清空本机全部记录？',
          subtitle: '心情、正文与标签都会从这台设备移除，无法恢复。',
          keepLabel: '留下它们',
          leaveLabel: '清空',
          onKeep: (): void => { this.confirmClear = false },
          onLeave: (): void => { void this.doClearRecords() }
        })
      }

      if (this.confirmAccount) {
        ConfirmSheet({
          title: '确定注销账号？',
          subtitle: '注销后需重新注册才能登录。本机记录仍保留在这台设备上。',
          keepLabel: '再想想',
          leaveLabel: '注销账号',
          onKeep: (): void => { this.confirmAccount = false },
          onLeave: (): void => { void this.handleDeleteAccount() }
        })
      }

      if (this.showExport) {
        this.ExportPanel()
      }

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: (): void => { this.showLegal = false }
        })
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .maxLines(3)
        }
        .width('100%')
        .padding({ top: 48 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MainPanel() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Image(YouyuMedia.emptyCorner())
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Row({ space: 12 }) {
          Column() {
            AppIcon({ name: 'user', iconSize: Theme.icon.xl, color: Theme.colors().brandOnPrimary })
          }
          .width(56)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          Column({ space: 4 }) {
            Text(this.isLoggedIn() ? this.currentUsername : '游客')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.isLoggedIn() ? '记录仍保存在本机' : '未登录也可写下每一隅')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        if (!this.isLoggedIn()) {
          AppButton({
            label: '登录 / 注册',
            variant: 'primary',
            onTap: (): void => this.onOpenLogin()
          })
        } else {
          AppButton({
            label: '退出登录',
            variant: 'secondary',
            onTap: (): void => {
              void AuthService.logout()
              this.onLogout()
              this.showToast('已退出登录')
            }
          })
        }

        this.PrefRow('深色模式', this.darkModeOn ? '已开启' : '已关闭', 'moon', (): void => {
          void this.toggleDark(!this.darkModeOn)
        })
        this.PrefRow('记录提醒', this.remindOn ? this.remindLabel : '未开启', 'bell', (): void => {
          void this.toggleRemind(!this.remindOn)
        })
        if (this.remindOn) {
          this.PrefRow('提醒时间', this.remindLabel, 'clock', (): void => this.pickRemindTime())
        }
        this.PrefRow('导出记录', '复制到剪贴板', 'bookmark', (): void => {
          this.exportText = YouyuStore.exportText()
          this.showExport = true
        })
        this.PrefRow('设置与隐私', '协议 · 撤回 · 注销', 'gear', (): void => {
          this.showSettings = true
          AppStorage.setOrCreate('tabBarHidden', true)
        })
        Blank().height(Theme.space.s10)
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s6
      })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  PrefRow(title: string, subtitle: string, icon: string, tap: () => void) {
    Row({ space: 12 }) {
      Column() {
        AppIcon({
          name: icon === 'moon' ? 'moon' : (icon === 'bell' ? 'bell' : (icon === 'clock' ? 'clock' :
            (icon === 'bookmark' ? 'bookmark' : 'gear'))),
          iconSize: Theme.icon.md,
          color: Theme.colors().brandDeep
        })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.sm)
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .constraintSize({ minHeight: 56 })
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick(() => tap())
  }

  @Builder
  SettingsPanel() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => {
          this.showSettings = false
          AppStorage.setOrCreate('tabBarHidden', false)
        })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('协议 · 撤回 · 注销')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '查看《用户协议》',
            variant: 'secondary',
            onTap: (): void => {
              this.legalKind = 'agreement'
              this.showLegal = true
            }
          })
          AppButton({
            label: '查看《隐私政策》',
            variant: 'secondary',
            onTap: (): void => {
              this.legalKind = 'privacy'
              this.showLegal = true
            }
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
          AppButton({
            label: '注销账号',
            variant: 'secondary',
            onTap: (): void => { this.confirmAccount = true }
          })
          AppButton({
            label: '清除缓存',
            variant: 'ghost',
            onTap: (): void => this.handleClearCache()
          })
          AppButton({
            label: '清空本机记录',
            variant: 'ghost',
            onTap: (): void => { this.confirmClear = true }
          })
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ExportPanel() {
    Column() {
      Column()
        .width('100%')
        .layoutWeight(1)
        .onClick(() => { this.showExport = false })
      Column({ space: Theme.space.s3 }) {
        Text('导出记录')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(this.exportText.length > 0 ? this.exportText : '还没有可导出的记录')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(12)
          .width('100%')
        AppButton({
          label: '复制到剪贴板',
          variant: 'primary',
          onTap: (): void => { void this.copyExport() }
        })
        AppButton({
          label: '关闭',
          variant: 'ghost',
          onTap: (): void => { this.showExport = false }
        })
      }
      .width('100%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({ topLeft: Theme.radius.sheet, topRight: Theme.radius.sheet })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().overlayScrim)
  }
}
