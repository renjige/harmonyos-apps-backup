import { Theme } from '../components/design-system/Theme'
import { AuthService } from '../services/AuthService'
import { AccessConfig } from '../config/AccessConfig'
import { LoginPage } from './LoginPage'
import { MainTabPage } from './MainTabPage'
import { OnboardingOverlay } from '../components/shop/OnboardingOverlay'
import { ShoppingLocalStore } from '../services/ShoppingLocalStore'
import { BrandIdentity } from '../config/BrandIdentity'

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
  @State sessionTick: number = 0
  @StorageLink('companyName') company: string = BrandIdentity.developer()
  @StorageLink('appDisplayName') appName: string = BrandIdentity.appName()
  @StorageLink('appTagline') tagline: string = '今天准备买些什么？'
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
            onSuccess: () => {
              this.sessionTick += 1
              this.refreshStage()
            }
          })
        } else {
          MainTabPage({
            appName: this.appName,
            sessionTick: this.sessionTick,
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
            this.sessionTick += 1
            this.refreshStage()
          },
          onSkip: () => { this.showLoginOverlay = false }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
      }

      if (!this.onboardingDone && this.stage === AppStage.Main) {
        OnboardingOverlay({
          onFinish: () => { void ShoppingLocalStore.setOnboardingDone() }
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
