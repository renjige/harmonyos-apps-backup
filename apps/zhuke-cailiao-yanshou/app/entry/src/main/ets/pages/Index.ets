import { Theme } from '../components/design-system/Theme'
import { AuthService } from '../services/AuthService'
import { AccessConfig } from '../config/AccessConfig'
import { LoginPage } from './LoginPage'
import { MainTabPage } from './MainTabPage'
import { SplashPage } from './SplashPage'
import { OnboardingPage } from './OnboardingPage'

enum AppStage {
  Login = 0,
  Main = 1
}

/**
 * 启动流：启动页 → 首次引导（可跳过）→ 首页。
 * 无独立隐私首屏；协议勾选在登录/注册页。
 */
@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State stage: AppStage = AppStage.Main
  @State showLoginOverlay: boolean = false
  @State showSplash: boolean = true
  @StorageLink('onboardingDone') onboardingDone: boolean = false
  @StorageLink('colorModeTick') @Watch('onColorTick') colorModeTick: number = 0
  @StorageLink('appDisplayName') appName: string = '筑科材料验收'
  @State paint: number = 0

  aboutToAppear(): void {
    this.refreshStage()
    this.paint = this.colorModeTick
    setTimeout(() => {
      this.showSplash = false
    }, 1200)
  }

  onColorTick(): void {
    this.paint = this.colorModeTick
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
            appName: this.appName,
            themeTick: this.paint,
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

      if (!this.onboardingDone && !this.showSplash) {
        OnboardingPage({
          onDone: () => {
            this.onboardingDone = true
          }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showSplash) {
        SplashPage()
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .opacity(this.paint >= 0 ? 1 : 1)
    .id(`zhuke_root_${this.themeEpoch}_${this.paint}`)
  }
}
