import { Theme } from '../components/design-system/Theme'
import { PrivacyConsentOverlay } from '../components/privacy/PrivacyConsentOverlay'
import { AppLockOverlay } from '../components/security/AppLockOverlay'
import { MainTabPage } from './MainTabPage'
import { PrivacyService } from '../services/PrivacyService'
import { AppLockService } from '../services/AppLockService'

enum LaunchStage {
  Privacy = 0,
  Lock = 1,
  Main = 2
}

/**
 * 私人日记启动流：
 * 1. 首次启动 → 隐私政策勾选弹窗（设计文档要求）
 * 2. 已同意且开启应用锁 → 解锁界面
 * 3. 进入主功能（纯本地，无需登录）
 */
@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State stage: LaunchStage = LaunchStage.Privacy
  @State privacyChecked: boolean = false

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    this.privacyChecked = PrivacyService.isAccepted()
    if (!this.privacyChecked) {
      this.stage = LaunchStage.Privacy
      return
    }
    const locked = await AppLockService.isEnabled()
    if (locked) {
      this.stage = LaunchStage.Lock
      return
    }
    this.stage = LaunchStage.Main
  }

  build() {
    Stack() {
      if (this.stage === LaunchStage.Main) {
        MainTabPage()
      } else {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.stage === LaunchStage.Privacy) {
        PrivacyConsentOverlay({
          onAccept: () => { void this.handlePrivacyAccept() },
          onRefuse: () => { this.stage = LaunchStage.Privacy }
        })
      }

      if (this.stage === LaunchStage.Lock) {
        AppLockOverlay({
          settingMode: false,
          onUnlocked: () => { this.stage = LaunchStage.Main },
          onCancel: () => { this.stage = LaunchStage.Lock }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private async handlePrivacyAccept(): Promise<void> {
    await PrivacyService.acceptAndPersist()
    this.privacyChecked = true
    const locked = await AppLockService.isEnabled()
    this.stage = locked ? LaunchStage.Lock : LaunchStage.Main
  }
}
