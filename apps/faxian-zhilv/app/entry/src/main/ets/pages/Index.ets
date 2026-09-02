import { Theme } from '../components/design-system/Theme'
import { AuthService } from '../services/AuthService'
import { AccessConfig } from '../config/AccessConfig'
import { LoginPage } from './LoginPage'
import { MainTabPage } from './MainTabPage'

enum AppStage {
  Splash = 0,
  Login = 1,
  Main = 2
}

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State stage: AppStage = AppStage.Splash
  @State showLoginOverlay: boolean = false
  @State splashOpacity: number = 1
  @StorageLink('companyName') company: string = '发现科技'
  @StorageLink('appDisplayName') appName: string = '发现之旅'
  @StorageLink('appTagline') tagline: string = '让每一次出行，都成为发现之旅'

  aboutToAppear(): void {
    setTimeout(() => {
      this.splashOpacity = 0
      setTimeout(() => {
        this.refreshStage()
      }, 280)
    }, 1600)
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
        } else if (this.stage === AppStage.Main) {
          MainTabPage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            onOpenLogin: () => this.openLogin(),
            onLogout: () => this.refreshStage(),
            onRequireAuth: () => this.openLogin()
          })
        } else {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
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

      if (this.stage === AppStage.Splash || this.splashOpacity > 0) {
        Column({ space: 16 }) {
          Image($r('app.media.app_icon'))
            .width(88)
            .height(88)
            .borderRadius(24)
            .objectFit(ImageFit.Cover)
          Text('发现之旅')
            .fontSize(Theme.type.title1)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text('让每一次出行，都成为发现之旅。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .opacity(this.splashOpacity)
        .animation({ duration: 280, curve: Curve.EaseOut })
      }
    }
    .width('100%')
    .height('100%')
  }
}
