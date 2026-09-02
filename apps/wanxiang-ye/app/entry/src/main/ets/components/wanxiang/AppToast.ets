import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { WanXiangGradients } from '../../services/WanXiangGradients'

@Component
export struct AppToast {
  @Prop message: string = ''
  @Prop visible: boolean = false
  @Prop success: boolean = true

  build() {
    if (this.visible && this.message.length > 0) {
      Row({ space: Theme.space.s2 }) {
        AppIcon({
          name: this.success ? 'check' : 'alert',
          iconSize: Theme.icon.md,
          color: this.success ? '#34C759' : '#FF9500'
        })
        Text(this.message)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
      }
      .constraintSize({ maxWidth: '84%' })
      .padding({ left: 18, right: 18, top: 12, bottom: 12 })
      .backgroundColor(WanXiangGradients.toastBg())
      .borderRadius(Theme.radius.pill)
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.25)', offsetY: 8 })
      .position({ x: '8%', y: 56 })
      .zIndex(100)
      .opacity(this.visible ? 1 : 0)
      .scale({ x: this.visible ? 1 : 0.92, y: this.visible ? 1 : 0.92 })
      .animation({ duration: 240, curve: Curve.EaseOut })
    }
  }
}
