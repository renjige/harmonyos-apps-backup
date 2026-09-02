import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { FavoritesPanel, NotesPanel, RecordsPanel, MedalsPanel } from '../components/mine/MinePanels'
import { HuntProgressStore } from '../services/HuntProgressStore'
import { PoetryNav } from '../services/PoetryNav'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '诗词寻宝'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('huntCoins') coins: number = 0
  @StorageLink('huntCleared') cleared: number = 0
  @StorageLink('huntPlaces') placesOn: number = 0
  @StorageLink('poetryTick') tick: number = 0
  @State panel: string = ''
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmLogout: boolean = false
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private rankName(): string {
    if (this.cleared >= 12) {
      return '一代宗师'
    }
    if (this.cleared >= 8) {
      return '诗林高手'
    }
    if (this.cleared >= 4) {
      return '小有成就'
    }
    return '初窥门径'
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

  private async handleClearCache(): Promise<void> {
    await HuntProgressStore.clearLocalCache()
    this.showToast('已清除本地栏目缓存')
  }

  private async setMode(mode: string): Promise<void> {
    await HuntProgressStore.setColorMode(mode)
    this.showToast(mode === 'dark' ? '已切换故宫夜' : (mode === 'light' ? '已切换宣纸日间' : '已跟随系统'))
  }

  private async setScale(scale: number): Promise<void> {
    await HuntProgressStore.setFontScale(scale)
    this.showToast('字号已更新')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.panel === 'favorites') {
        FavoritesPanel({ onBack: () => { this.panel = '' } })
      } else if (this.panel === 'notes') {
        NotesPanel({ onBack: () => { this.panel = '' } })
      } else if (this.panel === 'records') {
        RecordsPanel({ onBack: () => { this.panel = '' } })
      } else if (this.panel === 'medals') {
        MedalsPanel({ onBack: () => { this.panel = '' } })
      } else if (this.showSettings) {
        this.SettingsPanel()
      } else {
        this.MainPane()
      }

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => { this.showLegal = false }
        })
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(14)
          .fontColor('#F5F0E8')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.88)')
          .borderRadius(12)
          .margin({ top: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MainPane() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Column({ space: 8 }) {
          Text(this.isLoggedIn() ? this.currentUsername : '诗途旅人')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.isLoggedIn() ? '进度保存在本机，登录可同步账号' : '打开即用，闯关进度保存在本机')
            .fontSize(14)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Row({ space: 16 }) {
            Text(`${this.rankName()}`)
              .fontSize(15)
              .fontColor(Theme.colors().brandAccent)
            Text(`${this.coins} 诗币`)
              .fontSize(15)
              .fontColor(Theme.colors().textPrimary)
            Text(`点亮 ${this.placesOn}`)
              .fontSize(15)
              .fontColor(Theme.colors().textPrimary)
          }
          .width('100%')
        }
        .padding(20)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(24)
        .width('100%')

        this.MenuRow('我的收藏', () => { this.panel = 'favorites' })
        this.MenuRow('我的笔记', () => { this.panel = 'notes' })
        this.MenuRow('闯关进度', () => { this.panel = 'records' })
        this.MenuRow('成就徽章', () => { this.panel = 'medals' })
        this.MenuRow('机构消息', () => PoetryNav.setRoute(PoetryNav.MESSAGES))
        this.MenuRow('设置与隐私', () => { this.showSettings = true })

        if (!this.isLoggedIn()) {
          AppButton({ label: '登录 / 注册', variant: 'secondary', onTap: () => this.onOpenLogin() })
        } else {
          AppButton({
            label: '退出登录',
            variant: 'ghost',
            onTap: () => { this.confirmLogout = true }
          })
        }
        if (this.confirmLogout) {
          Text('确认退出当前账号？')
            .fontSize(14)
            .fontColor(Theme.colors().textSecondary)
          AppButton({
            label: '确认退出',
            variant: 'danger',
            onTap: () => {
              this.confirmLogout = false
              void AuthService.logout()
              this.onLogout()
            }
          })
          AppButton({
            label: '取消',
            variant: 'ghost',
            onTap: () => { this.confirmLogout = false }
          })
        }
      }
      .padding({ left: 20, right: 20, top: 20, bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  MenuRow(label: string, action: () => void) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: 18, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(20)
    .onClick(() => action())
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => { this.showSettings = false })
        Blank()
        Text('设置与隐私')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
      }
      .width('100%')
      Scroll() {
        Column({ space: 12 }) {
          Text('外观')
            .fontSize(13)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          AppButton({ label: '宣纸日间', variant: 'secondary', onTap: () => { void this.setMode('light') } })
          AppButton({ label: '故宫夜', variant: 'secondary', onTap: () => { void this.setMode('dark') } })
          AppButton({ label: '跟随系统', variant: 'ghost', onTap: () => { void this.setMode('system') } })
          Text('正文相对字号')
            .fontSize(13)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          AppButton({ label: '标准', variant: 'secondary', onTap: () => { void this.setScale(100) } })
          AppButton({ label: '较大', variant: 'secondary', onTap: () => { void this.setScale(110) } })
          this.MenuRow('查看《用户协议》', () => { this.legalKind = 'agreement'; this.showLegal = true })
          this.MenuRow('查看《隐私政策》', () => { this.legalKind = 'privacy'; this.showLegal = true })
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => { void this.handleClearCache() }
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
            variant: 'danger',
            onTap: (): void => { void this.handleDeleteAccount() }
          })
        }
        .padding({ top: 8, bottom: 32 })
      }
      .layoutWeight(1)
    }
    .padding({ left: 20, right: 20, top: 16 })
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
