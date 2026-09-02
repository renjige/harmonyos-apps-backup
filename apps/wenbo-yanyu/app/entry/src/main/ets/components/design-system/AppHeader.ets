import { Theme } from './Theme'

@Component
export struct AppHeader {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop inverse: boolean = false

  build() {
    Column({ space: Theme.space.s1 }) {
      Text(this.title)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.inverse ? Theme.of(this.darkModeOn).textOnInverse : Theme.of(this.darkModeOn).textPrimary)
        .width('100%')
      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(Theme.type.footnote)
          .fontColor(this.inverse ? Theme.of(this.darkModeOn).textOnInverse : Theme.of(this.darkModeOn).textSecondary)
          .width('100%')
      }
    }
    .width('100%')
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      top: Theme.space.pageY,
      bottom: Theme.space.s3
    })
  }
}

@Component
export struct AppBrandHero {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop company: string = ''
  @Prop appName: string = ''
  @Prop tagline: string = ''

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.company)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.of(this.darkModeOn).textOnInverse)
      Text(this.appName)
        .fontSize(Theme.type.title1)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.of(this.darkModeOn).textOnInverse)
      if (this.tagline.length > 0) {
        Text(this.tagline)
          .fontSize(Theme.type.callout)
          .fontColor(Theme.of(this.darkModeOn).textOnInverse)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.s5)
    .backgroundColor(Theme.of(this.darkModeOn).brandDeep)
    .borderRadius(Theme.radius.xl)
  }
}
