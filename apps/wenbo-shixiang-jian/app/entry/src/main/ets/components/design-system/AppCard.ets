import { Theme } from './Theme'
import { SketchStyle } from './SketchStyle'

export type AppCardVariant = 'plain' | 'glass' | 'stat' | 'inverse' | 'outlined'

@Component
export struct AppCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop variant: AppCardVariant = 'plain'
  @Prop title: string = ''
  @Prop noteIndex: number = 4
  onTap: () => void = () => {}
  @BuilderParam content: () => void

  private bg(): string {
    const c = Theme.colors()
    if (this.variant === 'inverse') {
      return c.surfaceInverse
    }
    if (this.variant === 'glass') {
      return c.surfaceGlass
    }
    if (this.variant === 'stat') {
      return SketchStyle.noteColor(this.noteIndex)
    }
    return c.surfaceCard
  }

  build() {
    Column() {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(SketchStyle.titleWeight())
          .fontStyle(SketchStyle.titleStyle())
          .fontColor(this.variant === 'inverse' ? Theme.colors().textOnInverse : SketchStyle.ink())
          .width('100%')
          .margin({ bottom: Theme.space.s3 })
      }
      this.content()
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.bg())
    .borderRadius(Theme.sketchRadius())
    .border({ width: 2, color: SketchStyle.borderInk() })
    .shadow(Theme.sketchShadow(this.variant === 'stat' ? 6 : 4))
    .rotate({ angle: this.variant === 'stat' ? SketchStyle.tiltForIndex(this.noteIndex) : 0 })
    .onClick(() => this.onTap())
  }
}
