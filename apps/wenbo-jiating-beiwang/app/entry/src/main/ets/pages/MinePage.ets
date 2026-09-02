import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { FamilyLocalStore } from '../services/FamilyLocalStore'
import { FamilyReminder } from '../models/FamilyModels'
import { FamilyService } from '../services/FamilyService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '家庭备忘'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('notifyEnabled') notifyEnabled: boolean = true
  @StorageLink('appearance') appearance: string = 'system'
  @StorageLink('themeRevision') themeRevision: number = 0
  @State showSettings: boolean = false
  @State showReminders: boolean = false
  @State showAppearance: boolean = false
  @State reminders: FamilyReminder[] = []
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State notifyHint: string = '已开启温和提醒'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onOpenLists: () => void = () => {}
  onOpenTemplates: () => void = () => {}

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
    this.showSettings = false
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
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

  aboutToAppear(): void {
    this.syncNotifyHint()
  }

  private syncNotifyHint(): void {
    this.notifyHint = this.notifyEnabled ? '已开启温和提醒' : '已关闭提醒'
  }

  private async toggleNotify(): Promise<void> {
    const next = !this.notifyEnabled
    await FamilyLocalStore.setNotifyEnabled(next)
    this.notifyHint = next ? '已开启温和提醒' : '已关闭提醒'
    this.showToast(this.notifyHint)
  }

  private async openReminders(): Promise<void> {
    this.reminders = await FamilyService.reminders()
    this.showReminders = true
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else if (this.showReminders) {
          this.RemindersPanel()
        } else if (this.showAppearance) {
          this.AppearancePanel()
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              Column({ space: 8 }) {
                Text(this.isLoggedIn() ? this.currentUsername : '游客')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(this.isLoggedIn() ? '家庭清单将同步到云端，方便换机继续勾选' : '家庭清单保存在本机，登录后可同步')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)

              this.MenuRow('我的家庭清单', '查看进行中与已完成的家庭清单', () => this.onOpenLists())
              this.MenuRow('我的模板', '家庭采购、日常用品等一键创建', () => this.onOpenTemplates())
              this.MenuRow('智慧提醒', '今天、明天或自定义时间', () => { void this.openReminders() })
              this.MenuRow('通知设置', this.notifyHint, () => { void this.toggleNotify() })
              this.MenuRow('外观设置', '浅色 / 深色 / 跟随系统', () => { this.showAppearance = true })
              this.MenuRow('关于家庭备忘', '版本 1.0.2 · 家庭生活事务工具', () => {
                this.showToast('家庭备忘 1.0.2，用于记录事项与提醒，不是购物商城')
              })
              this.MenuRow('用户协议', '查看全文', () => {
                this.legalKind = 'agreement'
                this.showLegal = true
              })
              this.MenuRow('隐私政策', '查看全文', () => {
                this.legalKind = 'privacy'
                this.showLegal = true
              })
              this.MenuRow('设置与隐私', '协议 · 撤回同意 · 注销', () => { this.showSettings = true })

              if (this.isLoggedIn()) {
                AppButton({
                  label: '退出登录',
                  variant: 'secondary',
                  onTap: (): void => {
                    void AuthService.logout()
                    this.onLogout()
                  }
                })
              } else {
                AppButton({ label: '登录 / 注册', onTap: (): void => { this.onOpenLogin() } })
              }
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: Theme.space.pageX, y: Theme.space.s6 })
          .zIndex(20)
      }
      if (this.showLegal) {
        LegalDocOverlay({ kind: this.legalKind, onClose: () => { this.showLegal = false } })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MenuRow(title: string, caption: string, action: () => void) {
    Row() {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(caption)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick(() => action())
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      this.BackRow('设置与隐私', () => { this.showSettings = false })
      Column({ space: Theme.space.s3 }) {
        AppButton({
          label: '查看《用户协议》',
          variant: 'secondary',
          onTap: (): void => { this.legalKind = 'agreement'; this.showLegal = true }
        })
        AppButton({
          label: '查看《隐私政策》',
          variant: 'secondary',
          onTap: (): void => { this.legalKind = 'privacy'; this.showLegal = true }
        })
        AppButton({ label: '注销账号', variant: 'danger', onTap: (): void => { void this.handleDeleteAccount() } })
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
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  RemindersPanel() {
    Column({ space: Theme.space.s4 }) {
      this.BackRow('智慧提醒', () => { this.showReminders = false })
      Scroll() {
        Column({ space: 10 }) {
          if (this.reminders.length === 0) {
            Text('还没有提醒。在家庭清单详情里可以设置今天或明天。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          ForEach(this.reminders, (r: FamilyReminder) => {
            Column({ space: 4 }) {
              Text(r.title)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(r.remindAt)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
          }, (r: FamilyReminder) => r.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AppearancePanel() {
    Column({ space: Theme.space.s4 }) {
      this.BackRow('外观设置', () => { this.showAppearance = false })
      Column({ space: 10 }) {
        this.AppearChip('浅色', 'light')
        this.AppearChip('深色', 'dark')
        this.AppearChip('跟随系统', 'system')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AppearChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.body)
      .fontColor(this.appearance === mode ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .width('100%')
      .padding(16)
      .backgroundColor(this.appearance === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .onClick(() => {
        void FamilyLocalStore.setAppearance(mode).then(() => {
          const host = this.getUIContext().getHostContext() as common.UIAbilityContext
          ThemeAppearance.apply(mode, host)
          this.showToast(mode === 'dark' ? '已切换深色模式' : (mode === 'light' ? '已切换浅色模式' : '已跟随系统外观'))
        })
      })
  }

  @Builder
  BackRow(title: string, back: () => void) {
    Row({ space: 8 }) {
      Text('返回')
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.colors().brandPrimary)
        .onClick(() => back())
      Text(title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12 })
  }
}
