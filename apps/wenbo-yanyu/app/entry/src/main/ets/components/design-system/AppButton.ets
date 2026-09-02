import { Theme } from './Theme'

export type AppButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger'

@Component
export struct AppButton {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop label: string = ''
  @Prop variant: AppButtonVariant = 'primary'
  @Prop disabled: boolean = false
  onTap: () => void = () => {}

  @State private pressed: boolean = false

  build() {
    Text(this.label)
      .fontSize(Theme.type.body)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.variant === 'primary' ? Theme.of(this.darkModeOn).brandOnPrimary :
        (this.variant === 'danger' ? '#FFFFFF' : Theme.of(this.darkModeOn).brandPrimary))
      .textAlign(TextAlign.Center)
      .width('100%')
      .padding({ top: 12, bottom: 12, left: 16, right: 16 })
      .backgroundColor(this.variant === 'primary' ?
        (this.pressed ? Theme.of(this.darkModeOn).brandPrimaryPressed : Theme.of(this.darkModeOn).brandPrimary) :
        (this.variant === 'danger' ? Theme.of(this.darkModeOn).danger :
          (this.variant === 'secondary' ? Theme.of(this.darkModeOn).brandPrimaryContainer : 'transparent')))
      .borderRadius(Theme.radius.lg)
      .border({
        width: this.variant === 'ghost' ? 1 : 0,
        color: Theme.of(this.darkModeOn).strokeStrong
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
