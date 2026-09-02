import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { MainTabPage } from './MainTabPage'

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('appDisplayName') appName: string = '跃动新章'

  aboutToAppear(): void {
    Theme.applyBrandPrimary('#007DFF')
    const dark = AppStorage.get<boolean>('ydDarkInit') === true
    if (dark) {
      ThemeAppearance.apply('dark')
    }
  }

  build() {
    Stack() {
      MainTabPage({ appName: this.appName })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
