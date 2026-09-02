import { Theme } from './Theme'

export type AppButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger'

@Component
export struct AppButton {
  @Prop label: string = ''
  @Prop variant: AppButtonVariant = 'primary'
  @Prop disabled: boolean = false
  /** 行内按钮（不占满父容器宽度） */
  @Prop compact: boolean = false
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
    return 'transparent'
  }

  private fg(): string {
    const c = Theme.colors()
    if (this.variant === 'primary') {
      return c.brandOnPrimary
    }
    if (this.variant === 'danger') {
      return '#FFFFFF'
    }
    if (this.variant === 'secondary') {
      return c.brandPrimary
    }
    return c.brandPrimary
  }

  build() {
    Text(this.label)
      .fontSize(Theme.type.body)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.fg())
      .textAlign(TextAlign.Center)
      .width(this.compact ? undefined : '100%')
      .padding({ top: 12, bottom: 12, left: 16, right: 16 })
      .backgroundColor(this.bg())
      .borderRadius(Theme.radius.lg)
      .border({
        width: this.variant === 'ghost' ? 1 : 0,
        color: Theme.colors().strokeStrong
      })
      .opacity(this.disabled ? 0.45 : 1)
      .scale({ x: this.pressed ? 0.97 : 1, y: this.pressed ? 0.97 : 1 })
      .animation({ duration: Theme.motion.instant, curve: Curve.EaseOut })
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
