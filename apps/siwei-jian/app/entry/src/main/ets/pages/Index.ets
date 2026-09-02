import { Theme } from '../components/design-system/Theme'
import { PrivacyConsentOverlay } from '../components/privacy/PrivacyConsentOverlay'
import { MainTabPage } from './MainTabPage'
import { PrivacyService } from '../services/PrivacyService'

enum LaunchStage {
  Privacy = 0,
  Main = 1
}

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State stage: LaunchStage = LaunchStage.Privacy

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    const accepted = PrivacyService.isAccepted()
    this.stage = accepted ? LaunchStage.Main : LaunchStage.Privacy
  }

  build() {
    Stack() {
      if (this.stage === LaunchStage.Main) {
        MainTabPage({
          onPrivacyRevoked: (): void => { void this.handlePrivacyRevoked() }
        })
      } else {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().surfacePage)
      }

      if (this.stage === LaunchStage.Privacy) {
        PrivacyConsentOverlay({
          onAccept: (): void => { void this.handlePrivacyAccept() },
          onRefuse: (): void => { this.stage = LaunchStage.Privacy }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private async handlePrivacyAccept(): Promise<void> {
    await PrivacyService.acceptAndPersist()
    this.stage = LaunchStage.Main
  }

  private async handlePrivacyRevoked(): Promise<void> {
    this.stage = LaunchStage.Privacy
  }
}
