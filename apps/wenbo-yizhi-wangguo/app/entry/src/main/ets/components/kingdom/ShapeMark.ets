import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct ShapeMark {
  @Prop visualKey: string = ''
  @Prop fillColor: string = '#5B6ABF'

  build() {
    if (this.visualKey === 'circle' || this.visualKey === 'oval') {
      Circle()
        .width(this.visualKey === 'oval' ? 56 : 44)
        .height(this.visualKey === 'oval' ? 32 : 44)
        .fill(this.fillColor)
    } else if (this.visualKey === 'star') {
      AppIcon({ name: 'ai', iconSize: 36, color: this.fillColor })
    } else {
      Rect()
        .width(44)
        .height(44)
        .radius(this.visualKey === 'diamond' ? 4 : 8)
        .fill(this.fillColor)
        .rotate({ angle: this.visualKey === 'diamond' || this.visualKey === 'triangle' ? 45 : 0 })
    }
  }
}
