import { Theme } from './Theme'

@Component
export struct AppHeader {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop inverse: boolean = false
  @StorageLink('darkModeOn') darkModeOn: boolean = false

  build() {
    Column({ space: Theme.space.s1 }) {
      Text(this.title)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.inverse ? Theme.palette(this.darkModeOn).textOnInverse : Theme.palette(this.darkModeOn).textPrimary)
        .width('100%')
      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(Theme.type.footnote)
          .fontColor(this.inverse ? Theme.palette(this.darkModeOn).textOnInverse : Theme.palette(this.darkModeOn).textSecondary)
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
  }
}

@Component
export struct AppBrandHero {
  @Prop company: string = ''
  @Prop appName: string = ''
  @Prop tagline: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.company)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.palette(this.darkModeOn).textOnInverse)
        .opacity(0.8)
      Text(this.appName)
        .fontSize(Theme.type.title1)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.palette(this.darkModeOn).textOnInverse)
      if (this.tagline.length > 0) {
        Text(this.tagline)
          .fontSize(Theme.type.callout)
          .fontColor(Theme.palette(this.darkModeOn).textOnInverse)
          .opacity(0.9)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.s5)
    .backgroundColor(Theme.palette(this.darkModeOn).brandDeep)
    .borderRadius(Theme.radius.xl)
  }
}
