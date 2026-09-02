import { Theme } from '../components/design-system/Theme'
import { AccessConfig } from '../config/AccessConfig'
import { LoginPage } from './LoginPage'
import { MainTabPage } from './MainTabPage'

@Entry
@Component
struct Index {
  @State showLoginOverlay: boolean = false
  @StorageLink('appDisplayName') appName: string = '微观志'
  @StorageLink('themeEpoch') themeEpoch: number = 0

  aboutToAppear(): void {
    Theme.applyBrandPrimary('#1A2A3A')
  }

  private openLogin(): void {
    this.showLoginOverlay = true
  }

  build() {
    Stack() {
      MainTabPage({
        appName: this.appName,
        onOpenLogin: (): void => { this.openLogin() },
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
  }
}
