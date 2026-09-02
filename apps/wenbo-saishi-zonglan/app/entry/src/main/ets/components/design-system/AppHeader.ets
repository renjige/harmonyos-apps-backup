import { Theme, ThemeColors } from './Theme'

@Component
export struct AppHeader {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop inverse: boolean = false
  @StorageLink('themeColorMode') themeColorMode: string = 'light'

  private palette(): ThemeColors {
    return Theme.palette(this.themeColorMode === 'dark')
  }

  build() {
    Column({ space: Theme.space.s1 }) {
      Text(this.title)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.inverse ? this.palette().textOnInverse : this.palette().textPrimary)
        .width('100%')
      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(Theme.type.footnote)
          .fontColor(this.inverse ? this.palette().textOnInverse : this.palette().textSecondary)
          .width('100%')
          .opacity(0.85)
      }
    }
    .width('100%')
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      top: Theme.space.pageY,
      bottom: Theme.space.s3
    })
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}

@Component
export struct AppBrandHero {
  @Prop company: string = ''
  @Prop appName: string = ''
  @Prop tagline: string = ''

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.company)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textOnInverse)
        .opacity(0.8)
      Text(this.appName)
        .fontSize(Theme.type.title1)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textOnInverse)
      if (this.tagline.length > 0) {
        Text(this.tagline)
          .fontSize(Theme.type.callout)
          .fontColor(Theme.colors().textOnInverse)
          .opacity(0.9)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().brandDeep)
    .borderRadius(Theme.radius.xl)
  }
}
