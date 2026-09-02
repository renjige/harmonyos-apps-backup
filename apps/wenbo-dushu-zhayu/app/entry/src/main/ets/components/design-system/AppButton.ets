import { Theme } from './Theme'

export type AppButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger'

@Component
export struct AppButton {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop variant: AppButtonVariant = 'primary'
  @Prop disabled: boolean = false
  /** false = 行内按钮（如输入框旁「添加」），不占满整行 */
  @Prop fullWidth: boolean = true
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
      return Theme.isDark() ? c.textPrimary : c.brandPrimary
    }
    if (this.variant === 'ghost') {
      return Theme.isDark() ? c.textPrimary : c.brandPrimary
    }
    return c.brandPrimary
  }

  build() {
    Text(this.label)
      .fontSize(Theme.type.body)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.fg())
      .textAlign(TextAlign.Center)
      .width(this.fullWidth ? '100%' : undefined)
      .padding({
        top: this.fullWidth ? 12 : 10,
        bottom: this.fullWidth ? 12 : 10,
        left: this.fullWidth ? 16 : 14,
        right: this.fullWidth ? 16 : 14
      })
      .constraintSize(this.fullWidth ? undefined : { minWidth: 64 })
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
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
