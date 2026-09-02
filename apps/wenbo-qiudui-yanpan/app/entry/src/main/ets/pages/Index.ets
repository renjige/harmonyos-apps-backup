import { Theme } from '../components/design-system/Theme'
import { AuthService } from '../services/AuthService'
import { AccessConfig } from '../config/AccessConfig'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { LoginPage } from './LoginPage'
import { MainTabPage } from './MainTabPage'
import { common } from '@kit.AbilityKit'

enum AppStage {
  Login = 0,
  Main = 1
}

/**
 * 启动流：不再单独展示隐私授权首屏。
 * open_optional → 可直接进首页；login_required → 登录页。
 * 隐私同意勾选在登录/注册页完成。
 */
@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State stage: AppStage = AppStage.Main
  @State showLoginOverlay: boolean = false
  @StorageLink('companyName') company: string = '魏文波'
  @StorageLink('appDisplayName') appName: string = '球队研判'
  @StorageLink('appTagline') tagline: string = '专业球队信息分析工具，查看球队资料、近期表现、对比球队、关注喜欢的球队并接收智慧提醒'
  @StorageLink('themeColorMode') themeColorMode: string = 'system'
  @StorageLink('themeRevision') themeRevision: number = 0

  aboutToAppear(): void {
    try {
      const host = this.getUIContext().getHostContext() as common.UIAbilityContext
      ThemeAppearance.syncFromHost(host)
    } catch {
    }
    this.refreshStage()
  }

  private refreshStage(): void {
    if (AccessConfig.mode() === 'login_required' && !AuthService.isLoggedIn()) {
      this.stage = AppStage.Login
      this.showLoginOverlay = false
      return
    }
    this.stage = AppStage.Main
    this.showLoginOverlay = false
  }

  private openLogin(): void {
    if (AccessConfig.mode() === 'login_required') {
      this.stage = AppStage.Login
    } else {
      this.showLoginOverlay = true
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.stage === AppStage.Login) {
          LoginPage({
            allowRegister: AccessConfig.allowRegister(),
            allowSkip: false,
            onSuccess: () => this.refreshStage()
          })
        } else {
          MainTabPage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            onOpenLogin: () => this.openLogin(),
            onLogout: () => this.refreshStage(),
            onRequireAuth: () => this.openLogin()
          })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showLoginOverlay) {
        LoginPage({
          allowRegister: AccessConfig.allowRegister(),
          allowSkip: AccessConfig.guestBrowse(),
          onSuccess: () => {
            this.showLoginOverlay = false
            this.refreshStage()
          },
          onSkip: () => {
            this.showLoginOverlay = false
          }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeRevision >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
