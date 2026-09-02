import { Theme } from '../components/design-system/Theme'
import { MainTabPage } from './MainTabPage'

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0

  aboutToAppear(): void {
    Theme.applyBrandPrimary('#F97316')
  }

  build() {
    Stack() {
      MainTabPage()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
