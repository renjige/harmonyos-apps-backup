import { Theme } from './Theme'
import { SketchStyle } from './SketchStyle'

export type AppButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger'

@Component
export struct AppButton {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop variant: AppButtonVariant = 'primary'
  @Prop disabled: boolean = false
  onTap: () => void = () => {}

  @State private pressed: boolean = false

  private bg(): string {
    const c = Theme.colors()
    if (this.variant === 'primary') {
      return this.pressed ? c.brandPrimaryPressed : c.brandPrimary
    }
    if (this.variant === 'danger') {
      return c.danger
    }
    if (this.variant === 'secondary') {
      return c.brandPrimaryContainer
    }
    return c.surfaceCard
  }

  private fg(): string {
    const c = Theme.colors()
    if (this.variant === 'primary') {
      return c.brandOnPrimary
    }
    if (this.variant === 'danger') {
      return '#FFFDF6'
    }
    if (this.variant === 'secondary') {
      return c.textOnBrandContainer
    }
    return c.textPrimary
  }

  build() {
    Text(this.label)
      .fontSize(Theme.type.body)
      .fontWeight(FontWeight.Bold)
      .fontStyle(FontStyle.Italic)
      .fontColor(this.fg())
      .textAlign(TextAlign.Center)
      .width('100%')
      .padding({ top: 12, bottom: 12, left: 16, right: 16 })
      .backgroundColor(this.bg())
      .borderRadius(Theme.sketchRadius())
      .border({ width: 2, color: SketchStyle.borderInk() })
      .shadow(this.pressed ? Theme.sketchShadow(2) : Theme.sketchShadow(5))
      .opacity(this.disabled ? 0.45 : 1)
      .scale({ x: this.pressed ? 0.96 : 1, y: this.pressed ? 0.96 : 1 })
      .translate({ y: this.pressed ? 2 : 0 })
      .animation({ duration: SketchStyle.motionMs, curve: Curve.EaseInOut })
      .onTouch((e: TouchEvent) => {
        if (this.disabled) {
          return
        }
        if (e.type === TouchType.Down) {
          this.pressed = true
        }
        if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
          this.pressed = false
        }
      })
      .onClick(() => {
        if (!this.disabled) {
          this.onTap()
        }
      })
  }
}
