import { Theme } from './Theme'
import { SketchStyle } from './SketchStyle'

@Component
export struct SketchTitle {
  @Prop text: string = ''
  @Prop subtitle: string = ''
  @Prop large: boolean = false

  build() {
    Column({ space: Theme.space.s1 }) {
      Text(this.text)
        .fontSize(this.large ? Theme.type.title2 : Theme.type.title3)
        .fontWeight(SketchStyle.titleWeight())
        .fontStyle(SketchStyle.titleStyle())
        .fontColor(SketchStyle.ink())
        .letterSpacing(0.6)
        .width('100%')
      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(Theme.type.bodyS)
          .fontColor(SketchStyle.inkMuted())
          .width('100%')
          .lineHeight(20)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
