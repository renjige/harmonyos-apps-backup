import { Theme } from './Theme'
import { SketchStyle } from './SketchStyle'

/** 便签卡片：微倾斜 + 硬边阴影 + 手绘边框 */
@Component
export struct SketchNote {
  @Prop noteIndex: number = 0
  @Prop fullWidth: boolean = true
  @Prop interactive: boolean = false
  @BuilderParam content: () => void = this.defaultContent

  @Builder
  defaultContent() {
  }

  build() {
    Column() {
      this.content()
    }
    .width(this.fullWidth ? '100%' : undefined)
    .padding(Theme.space.cardPadding)
    .backgroundColor(SketchStyle.noteColor(this.noteIndex))
    .borderRadius(Theme.sketchRadius())
    .border({ width: 2, color: SketchStyle.borderInk() })
    .shadow(Theme.sketchShadow(5))
    .rotate({ angle: SketchStyle.tiltForIndex(this.noteIndex) })
    .hitTestBehavior(this.interactive ? HitTestMode.Default : HitTestMode.None)
  }
}
