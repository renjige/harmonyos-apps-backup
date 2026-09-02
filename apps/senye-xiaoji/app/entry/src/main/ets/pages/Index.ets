import { Theme } from '../components/design-system/Theme'
import { AuthService } from '../services/AuthService'
import { AccessConfig } from '../config/AccessConfig'
import { PrivacyService } from '../services/PrivacyService'
import { PrivacyConsentOverlay } from '../components/legal/PrivacyConsentOverlay'
import { LoginPage } from './LoginPage'
import { MainTabPage } from './MainTabPage'

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
  @State showPrivacyGate: boolean = false
  @StorageLink('companyName') company: string = '森野文化'
  @StorageLink('appDisplayName') appName: string = '森野小记'
  @StorageLink('appTagline') tagline: string = '智慧记录，森野随行'

  aboutToAppear(): void {
    this.showPrivacyGate = !PrivacyService.isAccepted()
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
            onSuccess: (): void => { this.refreshStage() }
          })
        } else {
          MainTabPage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            onOpenLogin: (): void => { this.openLogin() },
            onLogout: (): void => { this.refreshStage() }
          })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showLoginOverlay) {
        LoginPage({
          allowRegister: AccessConfig.allowRegister(),
          allowSkip: AccessConfig.guestBrowse(),
          onSuccess: (): void => {
            this.showLoginOverlay = false
            this.refreshStage()
          },
          onSkip: (): void => {
            this.showLoginOverlay = false
          }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.showPrivacyGate) {
        PrivacyConsentOverlay({
          onAccepted: (): void => { this.showPrivacyGate = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
