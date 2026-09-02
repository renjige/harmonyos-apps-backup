import { Theme } from '../components/design-system/Theme'
import { AuthService } from '../services/AuthService'
import { AccessConfig } from '../config/AccessConfig'
import { LoginPage } from './LoginPage'
import { MainTabPage } from './MainTabPage'
import { WelcomeOverlay } from '../components/math/WelcomeOverlay'
import { MathLocalStore } from '../services/MathLocalStore'

enum AppStage {
  Login = 0,
  Main = 1
}

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State stage: AppStage = AppStage.Main
  @State showLoginOverlay: boolean = false
  @StorageLink('appDisplayName') appName: string = '童趣算坊'
  @StorageLink('onboardingDone') onboardingDone: boolean = false

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
        WelcomeOverlay({
          onFinish: () => { void MathLocalStore.setOnboardingDone() }
        })
          .width('100%')
          .height('100%')
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }
}
