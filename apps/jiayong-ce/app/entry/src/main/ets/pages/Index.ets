import { Theme } from '../components/design-system/Theme'
import { MainTabPage } from './MainTabPage'

/**
 * 启动直进主功能。隐私声明走华为应用市场「标准化隐私声明托管」，
 * 不再弹出应用内隐私弹窗，避免与平台弹窗重复。
 */
@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('appDisplayName') appName: string = '家用册'

  build() {
    Column() {
      MainTabPage({
        appName: this.appName
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
