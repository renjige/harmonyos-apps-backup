import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { ChoiceChip } from '../components/family/ChoiceChip'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { TaskLocalStore } from '../services/TaskLocalStore'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { TaskService } from '../services/TaskService'
import { ReminderService } from '../services/ReminderService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { MineSettingsPane } from '../components/family/MineSettingsPane'
import { FeedbackPane } from '../components/jujia/FeedbackPane'
import { AppVersion } from '../config/AppVersion'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '居家章'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('notifyEnabled') notifyEnabled: boolean = true
  @StorageLink('appearance') appearance: string = 'system'
  @StorageLink('defaultReminder') defaultReminder: string = 'none'
  @State panel: string = ''
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onOpenMembers: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onOpenDiscover: () => void = () => {}

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.panel = ''
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.panel = ''
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private applyAppearance(mode: string): void {
    this.appearance = mode
    void TaskLocalStore.setAppearance(mode)
    const host = this.getUIContext().getHostContext() as common.UIAbilityContext
    ThemeAppearance.apply(mode, host)
  }

  private async toggleNotify(): Promise<void> {
    const next = !this.notifyEnabled
    await TaskLocalStore.setNotifyEnabled(next)
    if (next) {
      const host = this.getUIContext().getHostContext() as common.UIAbilityContext
      const ok = await ReminderService.ensurePermission(host)
      if (ok) {
        await ReminderService.syncAll(host)
        this.showToast('已开启系统通知提醒')
        return
      }
      this.showToast(ReminderService.lastError.length > 0 ? ReminderService.lastError : '请允许通知权限')
      return
    }
    await ReminderService.cancelAll()
    this.showToast('已关闭系统提醒')
  }

  private async ringTest(): Promise<void> {
    const host = this.getUIContext().getHostContext() as common.UIAbilityContext
    const ok = await ReminderService.testRing(host, '到期提醒')
    this.showToast(ok ? ReminderService.lastAction :
      (ReminderService.lastError.length > 0 ? ReminderService.lastError : '提醒未开启'))
  }

  build() {
    Stack() {
      Column() {
        if (this.panel === 'settings') {
          MineSettingsPane({
            onBack: () => { this.panel = '' },
            onOpenAgreement: () => { this.legalKind = 'agreement'; this.showLegal = true },
            onOpenPrivacy: () => { this.legalKind = 'privacy'; this.showLegal = true },
            onRevoke: (): void => { void this.handleRevokePrivacy() },
            onDeleteAccount: (): void => { void this.handleDeleteAccount() }
          })
        } else if (this.panel === 'remind') {
          this.RemindPanel()
        } else if (this.panel === 'display') {
          this.DisplayPanel()
        } else if (this.panel === 'data') {
          this.DataPanel()
        } else if (this.panel === 'about') {
          this.AboutPanel()
        } else if (this.panel === 'feedback') {
          FeedbackPane({
            onBack: () => { this.panel = '' },
            onToast: (msg: string) => this.showToast(msg)
          })
        } else {
          this.MainPanel()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => { this.showLegal = false }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.sm)
          .margin({ top: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  MainPanel() {
    Scroll() {
      Column({ space: 12 }) {
        Column({ space: 8 }) {
          Image($r('app.media.home_hero'))
            .width('100%')
            .height(120)
            .borderRadius(Theme.radius.xl)
            .objectFit(ImageFit.Cover)
          Text('居家生活协同')
            .fontSize(Theme.type.titleM)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('看板盖章、物品到期系统提醒、家人轮值与共享备忘。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')

        this.EntryRow('家人与轮值', '倒垃圾 / 洗碗 / 浇花按星期轮值', () => this.onOpenMembers())
        this.EntryRow('我的收藏', '常用计划、物品与备忘集中查看', () => this.onOpenFavorites())
        this.EntryRow('生活发现', '8 大场景包 · 居家指南 · 维护模板', () => this.onOpenDiscover())
        this.EntryRow('家庭成长', '统计 · 时间轴 · 成就 · 本周回顾', () => this.onOpenGrowth())
        this.EntryRow('提醒设置', '系统通知 · 试响通道 · 默认提前量', () => { this.panel = 'remind' })
        this.EntryRow('显示设置', '深色模式 / 跟随系统', () => { this.panel = 'display' })
        this.EntryRow('数据管理', '导出或清除本机事项', () => { this.panel = 'data' })
        this.EntryRow('关于居家章', `版本 ${AppVersion.displayName()}`, () => { this.panel = 'about' })
        this.EntryRow('意见反馈', '提交建议与体验问题', () => { this.panel = 'feedback' })
        this.EntryRow('设置与隐私', '协议 · 撤回 · 注销', () => { this.panel = 'settings' })
        this.EntryRow(this.isLoggedIn() ? `已登录 · ${this.currentUsername}` : '登录以同步事项', this.isLoggedIn() ? '退出后仍可本机使用' : '游客可直接记录，登录后可同步', () => {
          if (this.isLoggedIn()) {
            void AuthService.logout().then(() => this.onLogout())
          } else {
            this.onOpenLogin()
          }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: Theme.space.s10 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  EntryRow(title: string, sub: string, action: () => void) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(sub)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(() => action())
  }

  @Builder
  BackTitle(title: string) {
    Row({ space: 8 }) {
      AppIcon({ name: 'chevron', iconSize: 18, color: Theme.colors().textSecondary })
        .rotate({ angle: 180 })
      Text(title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 18, bottom: 8 })
    .onClick(() => { this.panel = '' })
  }

  @Builder
  RemindPanel() {
    Column({ space: 12 }) {
      this.BackTitle('提醒设置')
      Text('到期提醒与计划提醒会写入系统通知栏。请允许通知权限；可用「试响通道」立即验证。不会推送营销内容。')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: 16, right: 16 })
      Column({ space: 10 }) {
        Text('默认提醒')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ChoiceChip({ label: '不提醒', active: this.defaultReminder === 'none', onPick: () => { void TaskLocalStore.setDefaultReminder('none') } })
          ChoiceChip({ label: '准时', active: this.defaultReminder === '0', onPick: () => { void TaskLocalStore.setDefaultReminder('0') } })
          ChoiceChip({ label: '提前 10 分钟', active: this.defaultReminder === '10', onPick: () => { void TaskLocalStore.setDefaultReminder('10') } })
          ChoiceChip({ label: '提前 30 分钟', active: this.defaultReminder === '30', onPick: () => { void TaskLocalStore.setDefaultReminder('30') } })
          ChoiceChip({ label: '提前 1 小时', active: this.defaultReminder === '60', onPick: () => { void TaskLocalStore.setDefaultReminder('60') } })
        }
        Text(this.notifyEnabled ? '到达提醒时间后会弹出系统通知；看板也可点「试响通道」。' : '已关闭系统提醒。')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: '试响到期提醒',
          variant: 'primary',
          onTap: () => { void this.ringTest() }
        })
        AppButton({
          label: this.notifyEnabled ? '关闭系统提醒' : '开启系统提醒',
          variant: 'secondary',
          onTap: () => { void this.toggleNotify() }
        })
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DisplayPanel() {
    Column({ space: 12 }) {
      this.BackTitle('显示设置')
      Text('深色模式使用主题色：到期提醒为深底危险色，不再使用浅粉硬编码。')
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: 16, right: 16 })
      Column({ space: 8 }) {
        ChoiceChip({ label: '跟随系统', active: this.appearance === 'system', onPick: () => this.applyAppearance('system') })
        ChoiceChip({ label: '浅色', active: this.appearance === 'light', onPick: () => this.applyAppearance('light') })
        ChoiceChip({ label: '深色', active: this.appearance === 'dark', onPick: () => this.applyAppearance('dark') })
      }
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }

  @Builder
  DataPanel() {
    Column({ space: 12 }) {
      this.BackTitle('数据管理')
      Text('导出仅包含你在本机记录的计划、物品、备忘与家人轮值，不会上传到第三方。')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .padding({ left: 16, right: 16 })
      AppButton({
        label: '导出数据',
        variant: 'secondary',
        onTap: () => { this.showToast(`已整理本机 ${TaskLocalStore.tasks().length} 件事项，可截图保存`) }
      })
        .padding({ left: 16, right: 16 })
      AppButton({
        label: '清除本机事项',
        variant: 'danger',
        onTap: () => { void TaskService.clearAll().then(() => this.showToast('本机事项已清除')) }
      })
        .padding({ left: 16, right: 16 })
    }
    .width('100%')
  }

  @Builder
  AboutPanel() {
    Column({ space: 12 }) {
      this.BackTitle('关于居家章')
      Column({ space: 8 }) {
        Text('居家章')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        Text(`版本 ${AppVersion.displayName()}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
        Text('家庭事务管理：计划分类、居家清单、物品维护、日记与实用技巧。完整协议请到「设置与隐私」查看。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .margin({ top: 8 })
      }
      .padding(20)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }
}

