import { Theme } from '../components/design-system/Theme'
import { AuthService } from '../services/AuthService'
import { AccessConfig } from '../config/AccessConfig'
import { LoginPage } from './LoginPage'
import { MainTabPage } from './MainTabPage'

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
  @StorageLink('companyName') company: string = '慧忆智能'
  @StorageLink('appDisplayName') appName: string = '慧忆册'
  @StorageLink('appTagline') tagline: string = '智慧记忆管家，帮助用户极简记录生活信息并通过智能标签归类回顾'

  aboutToAppear(): void {
    Theme.applyBrandPrimary('#1A6DF5')
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
  }
}
