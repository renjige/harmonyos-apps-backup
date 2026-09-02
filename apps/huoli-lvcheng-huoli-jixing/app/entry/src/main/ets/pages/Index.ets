import { Theme } from '../components/design-system/Theme'
import { MainTabPage } from './MainTabPage'

/**
 * 隐私首屏由华为平台隐私托管服务负责，App 内不再弹出独立隐私授权层。
 * 协议全文仍可在「我的 → 设置与隐私」查看。
 */
@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0

  build() {
    Column() {
      MainTabPage()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
