import { Theme } from './Theme'

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
      .width('100%')
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
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}

@Component
export struct AppGradientButton {
  @Prop label: string = ''
  @Prop disabled: boolean = false
  onTap: () => void = () => {}

  @State private pressed: boolean = false

  build() {
    Row() {
      Text(this.label)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandOnPrimary)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 16, bottom: 16 })
    .borderRadius(Theme.radius.pill)
    .linearGradient({
      angle: 135,
      colors: [
        [Theme.colors().brandPrimary, 0.0],
        [Theme.colors().brandAccent, 1.0]
      ]
    })
    .opacity(this.disabled ? 0.45 : (this.pressed ? 0.92 : 1))
    .scale({ x: this.pressed ? 0.98 : 1, y: this.pressed ? 0.98 : 1 })
    .shadow({
      radius: 20,
      color: Theme.isDark() ? 'rgba(26,92,255,0.35)' : 'rgba(26,92,255,0.22)',
      offsetY: 8,
      offsetX: 0
    })
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
