import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { PrivacyConsentOverlay } from '../components/privacy/PrivacyConsentOverlay'
import { PrivacyService } from '../services/PrivacyService'
import { MainTabPage } from './MainTabPage'

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State privacyReady: boolean = false
  @StorageLink('privacyAccepted') privacyAccepted: boolean = false
  @StorageLink('appDisplayName') appName: string = '生活剧本'

  aboutToAppear(): void {
    Theme.applyBrandPrimary('#E8A87C')
    if (PrivacyService.isAccepted()) {
      this.privacyAccepted = true
    }
    this.privacyReady = true
  }

  private async onAcceptPrivacy(): Promise<void> {
    await PrivacyService.acceptAndPersist()
    this.privacyAccepted = true
  }

  build() {
    Stack() {
      if (this.privacyReady) {
        MainTabPage({ appName: this.appName })
      }

      if (!this.privacyAccepted) {
        PrivacyConsentOverlay({
          onAccept: (): void => { void this.onAcceptPrivacy() },
          onRefuse: (): void => {
            const ctx = getContext(this) as common.UIAbilityContext
            ctx.terminateSelf()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
