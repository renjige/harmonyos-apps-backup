import { Theme } from '../components/design-system/Theme'
import { MainTabPage } from './MainTabPage'

/**
 * 首启隐私由 AppGallery Connect 平台隐私托管弹窗负责（50128），
 * 应用内不再展示自建 PrivacyConsentOverlay，避免双弹窗。
 * 协议全文仍可在「我的 → 设置与隐私」查看。
 */
@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0

  build() {
    Column() {
      MainTabPage()
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
