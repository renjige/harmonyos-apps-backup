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
  @StorageLink('appDisplayName') appName: string = '静时笺'
  @StorageLink('appTagline') tagline: string = '基于时间轴的生活记录与内心陪伴'

  aboutToAppear(): void {
    Theme.applyBrandPrimary('#8B6B4D')
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
        MainTabPage()
      }

      if (this.showPrivacy) {
        PrivacyConsentOverlay({
          onAccept: (): void => { void this.onAcceptPrivacy() },
          onRefuse: (): void => { this.showPrivacy = true }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
