import { Theme } from '../components/design-system/Theme'
import { BrandIdentity } from '../config/BrandIdentity'

@Component
export struct SplashPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  build() {
    Column() {
      Blank().layoutWeight(1)
      Image($r('app.media.icon'))
        .width(88)
        .height(88)
        .borderRadius(20)
      Text(BrandIdentity.appName())
        .fontSize(Theme.type.title1)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .margin({ top: 16 })
      Text(BrandIdentity.tagline())
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.colors().textPrimary)
        .margin({ top: 8 })
      Blank().layoutWeight(1)
      Text(`版本 ${BrandIdentity.version()}`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .margin({ bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
