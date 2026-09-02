import { Theme } from '../components/design-system/Theme'
import { PrivacyConsentOverlay } from '../components/privacy/PrivacyConsentOverlay'
import { PrivacyService } from '../services/PrivacyService'
import { VisitStatsService } from '../services/VisitStatsService'
import { MainTabPage } from './MainTabPage'

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State privacyReady: boolean = false
  @State showPrivacy: boolean = false

  aboutToAppear(): void {
    Theme.applyBrandPrimary('#2C3E6B')
    void this.checkPrivacy()
  }

  private async checkPrivacy(): Promise<void> {
    this.showPrivacy = !PrivacyService.isAccepted()
    this.privacyReady = true
  }

  private async onAcceptPrivacy(): Promise<void> {
    await PrivacyService.acceptAndPersist()
    await VisitStatsService.recordVisit()
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
