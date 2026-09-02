import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

export class CategoryVisual {
  iconName: AppIconName = 'book'
  gradStart: string = '#1A1A2E'
  gradEnd: string = '#3D4A9A'
  iconTint: string = '#C9A96E'
}

export class SymbolVisualUtil {
  static resolve(kind: string): CategoryVisual {
    const v = new CategoryVisual()
    if (kind === 'mood') {
      v.iconName = 'heart'
      v.gradStart = '#3D2A32'
      v.gradEnd = '#7A5560'
      return v
    }
    if (kind === 'scene') {
      v.iconName = 'grid'
      v.gradStart = '#1A1A2E'
      v.gradEnd = '#4A4A62'
      return v
    }
    if (kind === 'thought') {
      v.iconName = 'sparkle'
      v.gradStart = '#2D2D3F'
      v.gradEnd = '#8B7A4A'
      v.iconTint = '#E8DFD0'
      return v
    }
    if (kind === 'environment') {
      v.iconName = 'book'
      v.gradStart = '#2A3D38'
      v.gradEnd = '#5C7A72'
      return v
    }
    v.iconName = 'sparkle'
    return v
  }
}

@Component
export struct SymbolCover {
  @Prop kind: string = 'thought'
  @Prop tileSize: number = 72
  @Prop cornerRadius: number = Theme.radius.sm

  private visual(): CategoryVisual {
    return SymbolVisualUtil.resolve(this.kind)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [[this.visual().gradStart, 0], [this.visual().gradEnd, 1]]
        })
      AppIcon({
        name: this.visual().iconName,
        iconSize: Math.floor(this.tileSize * 0.36),
        color: this.visual().iconTint
      })
    }
    .width(this.tileSize)
    .height(this.tileSize)
    .borderRadius(this.cornerRadius)
    .clip(true)
  }
}
