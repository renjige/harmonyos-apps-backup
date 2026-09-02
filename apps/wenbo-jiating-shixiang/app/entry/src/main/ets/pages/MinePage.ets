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
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { MineSettingsPane } from '../components/family/MineSettingsPane'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '家庭事项'
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
          Text('家庭生活')
            .fontSize(Theme.type.titleM)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('轻量、温暖、清晰的家庭事务管理工具。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')

        this.EntryRow('提醒设置', '默认提醒与提前提醒时间', () => { this.panel = 'remind' })
        this.EntryRow('显示设置', '深色模式 / 跟随系统', () => { this.panel = 'display' })
        this.EntryRow('数据管理', '导出或清除本机事项', () => { this.panel = 'data' })
        this.EntryRow('关于家庭事项', '版本 1.0.0', () => { this.panel = 'about' })
        this.EntryRow('意见反馈', '通过应用市场或开发者渠道反馈', () => this.showToast('请通过华为应用市场评价，或联系开发者'))
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
      Text('只为你主动建立的事项提醒，不会推送营销内容。')
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
          ChoiceChip({ label: '提前 10 分钟', active: this.defaultReminder === '10', onPick: () => { void TaskLocalStore.setDefaultReminder('10') } })
          ChoiceChip({ label: '提前 30 分钟', active: this.defaultReminder === '30', onPick: () => { void TaskLocalStore.setDefaultReminder('30') } })
          ChoiceChip({ label: '提前 1 小时', active: this.defaultReminder === '60', onPick: () => { void TaskLocalStore.setDefaultReminder('60') } })
        }
        Text(this.notifyEnabled ? '到期事项会在首页高亮，方便你及时处理。' : '已关闭提醒提示。')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        AppButton({
          label: this.notifyEnabled ? '关闭提醒提示' : '开启提醒提示',
          variant: 'secondary',
          onTap: () => { void TaskLocalStore.setNotifyEnabled(!this.notifyEnabled) }
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
      Text('导出仅包含你在本机记录的家庭事项，不会上传到第三方。')
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
      this.BackTitle('关于家庭事项')
      Column({ space: 8 }) {
        Text('家庭事项')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        Text('版本 1.0.0')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
        Text('轻量、温暖、清晰的家庭事务管理工具。完整协议请到「设置与隐私」查看。')
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

