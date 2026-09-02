import { Theme } from '../components/design-system/Theme'
import { MainTabPage } from './MainTabPage'

/**
 * 本地探索 App：直进主 Tab，无登录墙。
 */
@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('appDisplayName') appName: string = '元素探索者'

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
