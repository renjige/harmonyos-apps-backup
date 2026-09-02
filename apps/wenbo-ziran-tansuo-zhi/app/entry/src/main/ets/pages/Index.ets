import { Theme } from '../components/design-system/Theme'
import { PrivacyConsentOverlay } from '../components/privacy/PrivacyConsentOverlay'
import { MainTabPage } from './MainTabPage'
import { LoginPage } from './LoginPage'
import { PrivacyService } from '../services/PrivacyService'
import { AuthService } from '../services/AuthService'
import { AccessConfig } from '../config/AccessConfig'

enum LaunchStage {
  Privacy = 0,
  Main = 1
}

enum AppStage {
  Login = 0,
  Main = 1
}

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State launchStage: LaunchStage = LaunchStage.Privacy
  @State appStage: AppStage = AppStage.Main
  @State showLoginOverlay: boolean = false
  @StorageLink('companyName') company: string = '薛茂新'
  @StorageLink('appDisplayName') appName: string = '自然探索志'
  @StorageLink('appTagline') tagline: string = '探索自然之美，记录户外足迹，发现身边森林山川与观星秘境的随身自然指南'

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    if (PrivacyService.isAccepted()) {
      this.launchStage = LaunchStage.Main
      this.refreshAppStage()
    } else {
      this.launchStage = LaunchStage.Privacy
    }
  }

  private refreshAppStage(): void {
    if (AccessConfig.mode() === 'login_required' && !AuthService.isLoggedIn()) {
      this.appStage = AppStage.Login
      this.showLoginOverlay = false
      return
    }
    this.appStage = AppStage.Main
    this.showLoginOverlay = false
  }

  private openLogin(): void {
    if (AccessConfig.mode() === 'login_required') {
      this.appStage = AppStage.Login
    } else {
      this.showLoginOverlay = true
    }
  }

  build() {
    Stack() {
      if (this.launchStage === LaunchStage.Main) {
        Column() {
          if (this.appStage === AppStage.Login) {
            LoginPage({
              allowRegister: AccessConfig.allowRegister(),
              allowSkip: false,
              onSuccess: (): void => { this.refreshAppStage() }
            })
          } else {
            MainTabPage({
              company: this.company,
              appName: this.appName,
              tagline: this.tagline,
              onOpenLogin: (): void => this.openLogin(),
              onLogout: (): void => { this.refreshAppStage() },
              onRequireAuth: (): void => this.openLogin(),
              onPrivacyRevoked: (): void => { void this.handlePrivacyRevoked() }
            })
          }
        }
        .width('100%')
        .height('100%')
      } else {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.launchStage === LaunchStage.Privacy) {
        PrivacyConsentOverlay({
          onAccept: (): void => { void this.handlePrivacyAccept() },
          onRefuse: (): void => { this.launchStage = LaunchStage.Privacy }
        })
      }

      if (this.showLoginOverlay) {
        LoginPage({
          allowRegister: AccessConfig.allowRegister(),
          allowSkip: AccessConfig.guestBrowse(),
          onSuccess: (): void => {
            this.showLoginOverlay = false
            this.refreshAppStage()
          },
          onSkip: (): void => {
            this.showLoginOverlay = false
          }
        })
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .zIndex(90)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private async handlePrivacyAccept(): Promise<void> {
    await PrivacyService.acceptAndPersist()
    this.launchStage = LaunchStage.Main
    this.refreshAppStage()
  }

  private async handlePrivacyRevoked(): Promise<void> {
    this.launchStage = LaunchStage.Privacy
  }
}
