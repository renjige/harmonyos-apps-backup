import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import {
  MineAboutPane,
  MineFeedbackPane,
  MineSettingsPane,
  MineSimplePane
} from '../components/mine/MineSheets'
import { PrivacyService } from '../services/PrivacyService'
import { AuthService } from '../services/AuthService'
import { TripStore } from '../services/TripStore'

@Component
export struct MinePage {
  @Prop appName: string = '行程备忘'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('smartRemindOn') smartRemindOn: boolean = true
  @StorageLink('fontLevel') fontLevel: number = 1
  @State showSettings: boolean = false
  @State showAbout: boolean = false
  @State showFeedback: boolean = false
  @State showRemind: boolean = false
  @State showTheme: boolean = false
  @State showFont: boolean = false
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
    AppStorage.setOrCreate('toastText', message)
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.closePanel()
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.closePanel()
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private fontLabel(): string {
    if (this.fontLevel <= 0) {
      return '较小'
    }
    if (this.fontLevel >= 2) {
      return '较大'
    }
    return '标准'
  }

  private async toggleTheme(): Promise<void> {
    const next = !this.darkModeOn
    await TripStore.setDark(next)
  }

  private async toggleFont(): Promise<void> {
    let next = this.fontLevel + 1
    if (next > 2) {
      next = 0
    }
    Theme.setFontLevel(next)
    await TripStore.setFontLevel(next)
  }

  private openPanel(kind: string): void {
    AppStorage.setOrCreate('minePanelOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    this.showSettings = kind === 'settings'
    this.showAbout = kind === 'about'
    this.showFeedback = kind === 'feedback'
    this.showRemind = kind === 'remind'
    this.showTheme = kind === 'theme'
    this.showFont = kind === 'font'
  }

  private closePanel(): void {
    this.showSettings = false
    this.showAbout = false
    this.showFeedback = false
    this.showRemind = false
    this.showTheme = false
    this.showFont = false
    AppStorage.setOrCreate('minePanelOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  build() {
    Stack() {
      Column() {
        Text('我的')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.palette(this.darkModeOn).textPrimary)
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.pageY,
            bottom: Theme.space.s4
          })
        Scroll() {
          Column({ space: 10 }) {
            this.Row('提醒设置', this.smartRemindOn ? '已开启智慧提醒' : '提醒已关闭',
              (): void => { this.openPanel('remind') })
            this.Row('主题设置', this.darkModeOn ? '深色' : '浅色',
              (): void => { this.openPanel('theme') })
            this.Row('字体大小', this.fontLabel(), (): void => { this.openPanel('font') })
            this.Row('隐私政策', '查看全文', (): void => {
              this.legalKind = 'privacy'
              this.showLegal = true
            })
            this.Row('用户协议', '查看全文', (): void => {
              this.legalKind = 'agreement'
              this.showLegal = true
            })
            this.Row('反馈建议', '', (): void => { this.openPanel('feedback') })
            this.Row('关于行程备忘', '1.0.0', (): void => { this.openPanel('about') })
            this.Row('设置与隐私', '协议 · 撤回 · 注销', (): void => { this.openPanel('settings') })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 88 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)

      if (this.showSettings) {
        MineSettingsPane({
          onBack: (): void => { this.closePanel() },
          onPrivacy: (): void => { this.legalKind = 'privacy'; this.showLegal = true },
          onAgreement: (): void => { this.legalKind = 'agreement'; this.showLegal = true },
          onRevoke: (): void => { void this.handleRevokePrivacy() },
          onDeleteAccount: (): void => { void this.handleDeleteAccount() }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }
      if (this.showAbout) {
        MineAboutPane({ onBack: (): void => { this.closePanel() } })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }
      if (this.showFeedback) {
        MineFeedbackPane({
          onBack: (): void => { this.closePanel() },
          onSend: (text: string): void => {
            if (text.trim().length === 0) {
              this.showToast('请先写下你的建议')
              return
            }
            this.closePanel()
            this.showToast('已记下，我们会认真看')
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }
      if (this.showRemind) {
        MineSimplePane({
          title: '提醒设置',
          body: '智慧提醒会在首页提示尚未开始的事项。第一版为应用内提示，不申请系统通知。',
          action: this.smartRemindOn ? '关闭智慧提醒' : '开启智慧提醒',
          onBack: (): void => { this.closePanel() },
          onAction: (): void => { void TripStore.setRemind(!this.smartRemindOn) }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }
      if (this.showTheme) {
        MineSimplePane({
          title: '主题设置',
          body: '浅色适合白天。深色降低屏幕亮度。',
          action: this.darkModeOn ? '切换为浅色' : '切换为深色',
          onBack: (): void => { this.closePanel() },
          onAction: (): void => { void this.toggleTheme() }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }
      if (this.showFont) {
        MineSimplePane({
          title: '字体大小',
          body: `当前：${this.fontLabel()}`,
          action: '切换字号',
          onBack: (): void => { this.closePanel() },
          onAction: (): void => { void this.toggleFont() }
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }
      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: (): void => { this.showLegal = false }
        })
          .width('100%')
          .height('100%')
          .zIndex(22)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.palette(this.darkModeOn).brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.palette(this.darkModeOn).brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .align(Alignment.Top)
          .zIndex(24)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Row(title: string, hint: string, onTap: () => void) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.subtitleM)
          .fontColor(Theme.palette(this.darkModeOn).textPrimary)
          .width('100%')
        if (hint.length > 0) {
          Text(hint)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.palette(this.darkModeOn).textTertiary)
            .width('100%')
        }
      }
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.palette(this.darkModeOn).textTertiary })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick(onTap)
  }
}
