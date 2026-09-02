import { Theme } from '../components/design-system/Theme'
import { MainTabPage } from './MainTabPage'

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('companyName') company: string = '拾意生活'
  @StorageLink('appDisplayName') appName: string = '手账拾意'
  @StorageLink('appTagline') tagline: string = '拾起生活里的小事，记录值得留下的心意。'

  build() {
    Column() {
      MainTabPage({
        company: this.company,
        appName: this.appName,
        tagline: this.tagline
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
