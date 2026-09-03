import { Theme } from './Theme'
import { SketchStyle } from './SketchStyle'
import { SketchTitle } from './SketchTitle'

@Component
export struct AppHeader {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop inverse: boolean = false

  build() {
    Column({ space: Theme.space.s1 }) {
      if (this.inverse) {
        Text(this.title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnInverse)
          .width('100%')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textOnInverse)
            .width('100%')
        }
      } else {
        SketchTitle({
          text: this.title,
          subtitle: this.subtitle,
          large: true
        })
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

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.company)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textOnInverse)
        .fontStyle(FontStyle.Italic)
      Text(this.appName)
        .fontSize(Theme.type.title1)
        .fontWeight(SketchStyle.titleWeight())
        .fontStyle(SketchStyle.titleStyle())
        .fontColor(Theme.colors().textOnInverse)
      if (this.tagline.length > 0) {
        Text(this.tagline)
          .fontSize(Theme.type.callout)
          .fontColor(Theme.colors().textOnInverse)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().brandDeep)
    .borderRadius(Theme.sketchRadius())
    .border({ width: 2, color: SketchStyle.borderInk() })
    .shadow(Theme.sketchShadow(6))
    .rotate({ angle: -0.6 })
  }
}
