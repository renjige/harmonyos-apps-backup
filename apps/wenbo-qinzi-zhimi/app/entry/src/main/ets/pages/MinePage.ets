import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { FavoritesPanel, RecordsPanel, MedalsPanel, GuidePanel } from '../components/mine/MinePanels'
import { WrongPanel } from '../components/mine/MineExtraPanels'
import { CollectionPanel } from '../components/growth/CollectionPanel'
import { QuizNav } from '../services/QuizNav'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '亲子智谜'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('doneCount') doneCount: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @State panel: string = ''
  @State showSettings: boolean = false
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
    this.showSettings = false
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleLogout(): Promise<void> {
    await AuthService.logout()
    this.onLogout()
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

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.panel === 'favorites') {
        FavoritesPanel({ onBack: () => { this.panel = '' } })
      } else if (this.panel === 'wrongs') {
        WrongPanel({ onBack: () => { this.panel = '' } })
      } else if (this.panel === 'collections') {
        CollectionPanel({ onBack: () => { this.panel = '' } })
      } else if (this.panel === 'records') {
        RecordsPanel({ onBack: () => { this.panel = '' } })
      } else if (this.panel === 'medals') {
        MedalsPanel({ onBack: () => { this.panel = '' } })
      } else if (this.panel === 'guide') {
        GuidePanel({ onBack: () => { this.panel = '' } })
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
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(30,42,58,0.88)')
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
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 8 }) {
            Text('小小探索家')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.isLoggedIn() ? this.currentUsername : '打开即用，进度保存在本机')
              .fontSize(14)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Row({ space: 16 }) {
              Text(`累计完成 ${this.doneCount} 题`)
                .fontSize(15)
                .fontColor(Theme.colors().textPrimary)
              Text(`连续挑战 ${this.streakDays} 天`)
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
          this.MenuRow('收藏夹管理', () => { this.panel = 'collections' })
          this.MenuRow('错题本', () => { this.panel = 'wrongs' })
          this.MenuRow('成长中心', () => {
            AppStorage.setOrCreate('mainTab', 3)
            QuizNav.bump()
          })
          this.MenuRow('家庭谜题', () => { QuizNav.openCustom() })
          this.MenuRow('挑战记录', () => { this.panel = 'records' })
          this.MenuRow('我的勋章', () => { this.panel = 'medals' })
          this.MenuRow('使用说明', () => { this.panel = 'guide' })
          this.MenuRow('隐私政策', () => { this.legalKind = 'privacy'; this.showLegal = true })
          this.MenuRow('用户协议', () => { this.legalKind = 'agreement'; this.showLegal = true })
          this.MenuRow('关于亲子智谜', () => { this.panel = 'about' })
          this.MenuRow('设置与隐私', () => { this.showSettings = true })

          if (!this.isLoggedIn()) {
            AppButton({ label: '登录 / 注册', variant: 'secondary', onTap: () => this.onOpenLogin() })
          } else {
            AppButton({
              label: '退出登录',
              variant: 'ghost',
              onTap: (): void => { void this.handleLogout() }
            })
          }
        }
        .padding({ left: 20, right: 20, top: 20, bottom: 40 })
      }
      .layoutWeight(1)

      if (this.panel === 'about') {
        this.AboutSheet()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  AboutSheet() {
    Column({ space: 10 }) {
      Text('关于亲子智谜')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('一起动脑，一起开心。面向 6 到 12 岁儿童及家长的轻量亲子益智互动。无支付、无商城、无公开社区。不进行智力测评。')
        .fontSize(15)
        .lineHeight(24)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Text('运营者：魏文波')
        .fontSize(13)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      AppButton({ label: '关闭', variant: 'secondary', onTap: () => { this.panel = '' } })
    }
    .padding(20)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(24)
    .margin({ left: 20, right: 20, bottom: 20 })
  }

  @Builder
  MenuRow(label: string, action: () => void) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: 18, color: Theme.colors().textTertiary })
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
          this.MenuRow('查看《用户协议》', () => { this.legalKind = 'agreement'; this.showLegal = true })
          this.MenuRow('查看《隐私政策》', () => { this.legalKind = 'privacy'; this.showLegal = true })
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
