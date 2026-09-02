import { Theme } from './Theme'

export type AppButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger'

@Component
export struct AppButton {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop label: string = ''
  @Prop variant: AppButtonVariant = 'primary'
  @Prop disabled: boolean = false
  onTap: () => void = () => {}

  @State private pressed: boolean = false

  private bg(epoch: number, dark: boolean): string {
    if (this.variant === 'primary') {
      return this.pressed ? (dark ? '#D4BC9A' : '#736559') : Theme.brandInk(epoch, dark)
    }
    if (this.variant === 'danger') {
      return dark ? '#E08A8A' : '#A33B3B'
    }
    if (this.variant === 'secondary') {
      return Theme.brandBox(epoch, dark)
    }
    return 'transparent'
  }

  private fg(epoch: number, dark: boolean): string {
    if (this.variant === 'primary') {
      return dark ? '#1A1510' : '#FFFFFF'
    }
    if (this.variant === 'danger') {
      return '#FFFFFF'
    }
    return Theme.brandInk(epoch, dark)
  }

  build() {
    Text(this.label)
      .fontSize(Theme.type.body)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.fg(this.themeEpoch, this.darkModeOn))
      .textAlign(TextAlign.Center)
      .width('100%')
      .padding({ top: 12, bottom: 12, left: 16, right: 16 })
      .backgroundColor(this.bg(this.themeEpoch, this.darkModeOn))
      .borderRadius(Theme.radius.lg)
      .border({
        width: this.variant === 'ghost' ? 1 : 0,
        color: Theme.hairline(this.themeEpoch, this.darkModeOn)
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
