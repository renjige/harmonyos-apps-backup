import { Theme } from './Theme'
import { SketchStyle } from './SketchStyle'

export type SketchCardVariant = 'plain' | 'note' | 'accent'

/** 可交互便签容器 */
@Component
export struct SketchCard {
  @Prop noteIndex: number = 4
  @Prop variant: SketchCardVariant = 'plain'
  @Prop tilt: boolean = false
  @Prop pad: boolean = true
  onTap: () => void = () => {}
  @BuilderParam content: () => void = this.defaultContent

  @Builder
  defaultContent() {
  }

  private bg(): string {
    if (this.variant === 'note') {
      return SketchStyle.noteColor(this.noteIndex)
    }
    if (this.variant === 'accent') {
      return Theme.colors().brandPrimaryContainer
    }
    return Theme.colors().surfaceCard
  }

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(this.pad ? Theme.space.cardPadding : 0)
    .backgroundColor(this.bg())
    .borderRadius(Theme.sketchRadius())
    .border({ width: 2, color: SketchStyle.borderInk() })
    .shadow(Theme.sketchShadow(this.tilt ? 6 : 4))
    .rotate({ angle: this.tilt ? SketchStyle.tiltForIndex(this.noteIndex) : 0 })
    .onClick((): void => {
      this.onTap()
    })
  }
}
