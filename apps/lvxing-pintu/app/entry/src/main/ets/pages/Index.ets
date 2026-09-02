import { Theme } from '../components/design-system/Theme'
import { MainTabPage } from './MainTabPage'
import { PrivacyConsentOverlay } from '../components/legal/PrivacyConsentOverlay'

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('companyName') company: string = '拼图记忆'
  @StorageLink('appDisplayName') appName: string = '旅行拼图'
  @StorageLink('appTagline') tagline: string = '将碎片化的旅行记忆拼合成完整的旅行故事'
  @StorageLink('privacyAccepted') privacyAccepted: boolean = false
  @State ready: boolean = false

  aboutToAppear(): void {
    this.ready = true
  }

  build() {
    Stack() {
      if (this.ready && this.privacyAccepted) {
        MainTabPage({
          appName: this.appName
        })
      }

      if (this.ready && !this.privacyAccepted) {
        PrivacyConsentOverlay({
          onAccepted: (): void => {}
        })
          .zIndex(100)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
