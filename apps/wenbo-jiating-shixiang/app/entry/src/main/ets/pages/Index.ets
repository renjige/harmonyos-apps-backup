import { Theme } from '../components/design-system/Theme'
import { AuthService } from '../services/AuthService'
import { AccessConfig } from '../config/AccessConfig'
import { LoginPage } from './LoginPage'
import { MainTabPage } from './MainTabPage'
import { OnboardingOverlay } from '../components/family/OnboardingOverlay'
import { TaskLocalStore } from '../services/TaskLocalStore'

enum AppStage {
  Login = 0,
  Main = 1
}

/**
 * 启动流：无独立隐私首屏。
 * open_optional → 欢迎页（首次）→ 首页；协议勾选在登录/注册页。
 */
@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State stage: AppStage = AppStage.Main
  @State showLoginOverlay: boolean = false
  @StorageLink('appDisplayName') appName: string = '家庭事项'
  @StorageLink('onboardingDone') onboardingDone: boolean = false
  @StorageLink('themeRevision') themeRevision: number = 0

  aboutToAppear(): void {
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

  private async finishOnboard(): Promise<void> {
    await TaskLocalStore.seedWelcomeSamples()
    await TaskLocalStore.setOnboardingDone()
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
            onOpenLogin: () => this.openLogin(),
            onLogout: () => this.refreshStage()
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
          onSkip: () => { this.showLoginOverlay = false }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (!this.onboardingDone && this.stage === AppStage.Main) {
        OnboardingOverlay({
          onFinish: () => { void this.finishOnboard() }
        })
          .width('100%')
          .height('100%')
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
