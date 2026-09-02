import { Theme, ThemeColors } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { AtelierBizService } from '../services/AtelierBizService'
import { AtelierDetailNav } from '../services/AtelierDetailNav'
import { AtelierProgress } from '../services/AtelierProgress'
import { AtelierPractice } from '../services/AtelierPractice'
import { AtelierStats } from '../models/AtelierModels'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '悦知坊'
  @Prop overlayMode: boolean = false
  @Prop settingsOnly: boolean = false
  @StorageLink('accessToken') @Watch('onAccessTokenChange') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('atelierRefresh') @Watch('onRefreshStats') atelierRefresh: number = 0
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State confirmDelete: boolean = false
  @State stats: AtelierStats = new AtelierStats()
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onCloseOverlay: () => void = () => {}

  aboutToAppear(): void {
    if (this.settingsOnly) {
      this.showSettings = true
    }
    void this.reloadStats()
  }

  onRefreshStats(): void {
    void this.reloadStats()
  }

  onAccessTokenChange(): void {
    void this.reloadStats()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async reloadStats(): Promise<void> {
    const s = new AtelierStats()
    s.minutes = AtelierProgress.totalMinutes()
    s.works = AtelierPractice.count()
    if (this.isLoggedIn()) {
      const uid = AtelierBizService.userId()
      const favs = await AtelierBizService.loadFavorites(uid)
      s.favorites = favs.length
    }
    this.stats = s
  }

  private showToast(message: string): void {
    AtelierDetailNav.showToast(message)
  }

  private async handleLogout(): Promise<void> {
    await AuthService.logout()
    this.onLogout()
    this.showToast('已退出登录')
  }

  private closeSettings(): void {
    this.showSettings = false
    if (this.overlayMode) {
      this.onCloseOverlay()
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.closeSettings()
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private handleClearCache(): void {
    void AtelierProgress.clearCache()
    this.showToast('已清除本地缓存')
  }

  private async handleDeleteAccount(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认注销账号')
      return
    }
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.closeSettings()
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private async toggleDark(): Promise<void> {
    const hostContext = this.getUIContext().getHostContext() as common.UIAbilityContext
    const nextDark = ThemeAppearance.toggle(hostContext)
    await AtelierProgress.setDark(nextDark)
    this.showToast(nextDark ? '已切换深色模式' : '已切换浅色模式')
  }

  private c(): ThemeColors {
    return Theme.colorOf(this.themeEpoch)
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings || this.settingsOnly) {
          this.SettingsPanel()
        } else {
          this.MainPanel()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.c().surfacePage)

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: (): void => { this.showLegal = false }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MainPanel() {
    Column() {
      AppHeader({ title: '我的', subtitle: this.appName })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 8 }) {
            Text(this.isLoggedIn() ? this.currentUsername : '游客')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.c().textPrimary)
              .width('100%')
            Text(this.isLoggedIn() ? '账号已登录 · 书坊可同步；课业保存在本机' : '游客可写工坊课业；登录后可收入书坊')
              .fontSize(Theme.type.footnote)
              .fontColor(this.c().textSecondary)
              .width('100%')
            Row({ space: 24 }) {
              Column() {
                Text(`${this.stats.favorites}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.c().brandPrimary)
                Text('书坊')
                  .fontSize(12)
                  .fontColor(this.c().textSecondary)
              }
              Column() {
                Text(`${this.stats.works}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.c().brandPrimary)
                Text('课业')
                  .fontSize(12)
                  .fontColor(this.c().textSecondary)
              }
              Column() {
                Text(`${this.stats.minutes}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.c().brandPrimary)
                Text('阅读分钟')
                  .fontSize(12)
                  .fontColor(this.c().textSecondary)
              }
            }
            .width('100%')
            .margin({ top: 8 })
          }
          .width('100%')
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(this.c().surfaceCard)
          .borderRadius(Theme.radius.card)

          this.MenuRow('我的课业', '三问、余味、白名单、散步与临摹', (): void => { AtelierDetailNav.openWorkList() })
          this.MenuRow('消息', '工坊广播通知', (): void => { AtelierDetailNav.openMessages() })
          this.MenuRow('智慧偏好', '问卷匹配推荐工坊', (): void => { AtelierDetailNav.openDiagnose() })
          this.MenuRow('设置与隐私', '协议 · 撤回同意 · 注销', (): void => {
            this.confirmDelete = false
            this.showSettings = true
          })
          this.MenuRow(this.darkModeOn ? '切换浅色模式' : '深色模式', '立即切换阅读外观', (): void => {
            void this.toggleDark()
          })

          if (this.isLoggedIn()) {
            AppButton({
              label: '退出登录',
              variant: 'secondary',
              onTap: (): void => { void this.handleLogout() }
            })
          } else {
            AppButton({
              label: '登录 / 注册',
              onTap: (): void => { this.onOpenLogin() }
            })
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MenuRow(title: string, sub: string, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.c().textPrimary)
        Text(sub)
          .fontSize(Theme.type.caption)
          .fontColor(this.c().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: this.c().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.c().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick(onTap)
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.closeSettings() })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.c().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
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
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => { this.handleClearCache() }
          })
          AppButton({
            label: this.confirmDelete ? '再点一次确认注销' : '注销账号',
            variant: 'danger',
            onTap: (): void => { void this.handleDeleteAccount() }
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
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.c().surfacePage)
  }
}
