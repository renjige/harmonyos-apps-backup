import { Theme } from '../components/design-system/Theme'
import { PrivacyConsentDialog } from '../components/privacy/PrivacyConsentDialog'
import { PrivacyService } from '../services/PrivacyService'
import { MainTabPage } from './MainTabPage'

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State privacyReady: boolean = false
  @State showConsent: boolean = false
  @StorageLink('appDisplayName') appName: string = '松岚札'

  aboutToAppear(): void {
    Theme.applyBrandPrimary('#2D5A4A')
    const accepted = PrivacyService.isAccepted()
    this.privacyReady = accepted
    this.showConsent = !accepted
  }

  private async handleAccept(): Promise<void> {
    await PrivacyService.acceptAndPersist()
    this.privacyReady = true
    this.showConsent = false
  }

  private handleRevoke(): void {
    this.privacyReady = false
    this.showConsent = true
  }

  build() {
    Stack() {
      if (this.privacyReady) {
        MainTabPage({
          appName: this.appName,
          onPrivacyRevoked: () => this.handleRevoke()
        })
      } else {
        Column() {
          Text('松岚札')
            .fontSize(Theme.type.title1)
            .fontColor(Theme.colors().brandPrimary)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.showConsent) {
        PrivacyConsentDialog({
          onAccepted: () => { void this.handleAccept() }
        })
          .zIndex(100)
      }
    }
    .width('100%')
    .height('100%')
  }
}
