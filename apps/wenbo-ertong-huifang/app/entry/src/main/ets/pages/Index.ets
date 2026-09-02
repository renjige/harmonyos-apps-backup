import { Theme } from '../components/design-system/Theme'
import { MainTabPage } from './MainTabPage'

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('appDisplayName') appName: string = '儿童绘坊'

  build() {
    Column() {
      MainTabPage()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
