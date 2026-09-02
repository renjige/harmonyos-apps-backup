import { Theme } from '../components/design-system/Theme'
import { MainTabPage } from './MainTabPage'

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0

  build() {
    Column() {
      MainTabPage()
        .layoutWeight(1)
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
