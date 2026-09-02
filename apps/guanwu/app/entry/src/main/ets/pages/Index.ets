import { Theme } from '../components/design-system/Theme'
import { MainTabPage } from './MainTabPage'
import { LoginPage } from './LoginPage'
import { AuthService } from '../services/AuthService'
import { AccessConfig } from '../config/AccessConfig'

/**
 * 已接入华为隐私声明托管：首次打开不再展示自建隐私弹窗。
 * 协议勾选仅在登录/注册页；设置内可再阅读全文与撤回。
 */
@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State showLoginOverlay: boolean = false
  @StorageLink('appDisplayName') appName: string = '观物'

  build() {
    Stack() {
      MainTabPage({
        appName: this.appName,
        onPrivacyRevoked: (): void => { void this.handlePrivacyRevoked() },
        onOpenLogin: (): void => this.openLogin(),
        onLogout: (): void => { this.showLoginOverlay = false }
      })

      if (this.showLoginOverlay) {
        LoginPage({
          allowRegister: AccessConfig.allowRegister(),
          allowSkip: AccessConfig.guestBrowse(),
          onSuccess: (): void => { this.showLoginOverlay = false },
          onSkip: (): void => { this.showLoginOverlay = false }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().surfacePage)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  private openLogin(): void {
    this.showLoginOverlay = true
  }

  private async handlePrivacyRevoked(): Promise<void> {
    if (AuthService.isLoggedIn()) {
      await AuthService.logout()
    }
    this.showLoginOverlay = false
  }
}
