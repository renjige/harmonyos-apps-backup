import { Theme } from '../components/design-system/Theme'
import { PrivacyConsentOverlay } from '../components/privacy/PrivacyConsentOverlay'
import { PrivacyService } from '../services/PrivacyService'
import { MainTabPage } from './MainTabPage'

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State privacyReady: boolean = false
  @State showPrivacy: boolean = false
  @StorageLink('appDisplayName') appName: string = '积累日记'
  @StorageLink('appTagline') tagline: string = '轻量级智慧日记应用，每日积累文字与影像，见证成长轨迹'

  aboutToAppear(): void {
    Theme.applyBrandPrimary('#E8A87C')
    void this.checkPrivacy()
  }

  private async checkPrivacy(): Promise<void> {
    this.showPrivacy = !PrivacyService.isAccepted()
    this.privacyReady = true
  }

  private async onAcceptPrivacy(): Promise<void> {
    await PrivacyService.acceptAndPersist()
    this.showPrivacy = false
  }

  build() {
    Stack() {
      if (this.privacyReady) {
        MainTabPage({ appName: this.appName })
      }

      if (this.showPrivacy) {
        PrivacyConsentOverlay({
          onAccept: (): void => { void this.onAcceptPrivacy() },
          onRefuse: (): void => {
            // 用户文档要求：不同意则不可采集；本地日记可浏览空态
            this.showPrivacy = true
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
