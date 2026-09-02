import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

export class CategoryVisual {
  iconName: AppIconName = 'book'
  gradStart: string = '#3B2D8E'
  gradEnd: string = '#6C5CE7'
  iconTint: string = '#FFFFFF'
}

export class SymbolVisualUtil {
  static resolve(category: string, coverKey: string): CategoryVisual {
    const v = new CategoryVisual()
    if (category === 'work' || coverKey === 'nb_work') {
      v.iconName = 'biz'
    } else if (category === 'read' || coverKey === 'nb_read') {
      v.iconName = 'book'
    } else if (category === 'life' || coverKey === 'nb_life') {
      v.iconName = 'heart'
    } else {
      v.iconName = 'sparkle'
    }
    v.gradStart = '#3B2D8E'
    v.gradEnd = '#6C5CE7'
    v.iconTint = '#FFFFFF'
    return v
  }
}

@Component
export struct SymbolCover {
  @Prop category: string = ''
  @Prop coverKey: string = ''
  @Prop tileSize: number = 72

  private icon(): AppIconName {
    return SymbolVisualUtil.resolve(this.category, this.coverKey).iconName
  }

  build() {
    Column() {
      AppIcon({ name: this.icon(), iconSize: Theme.icon.lg, color: '#FFFFFF' })
    }
    .width(this.tileSize)
    .height(this.tileSize)
    .borderRadius(Theme.radius.md)
    .justifyContent(FlexAlign.Center)
    .linearGradient({ angle: 160, colors: [['#3B2D8E', 0], ['#6C5CE7', 1]] })
  }
}

@Component
export struct SymbolHero {
  @Prop category: string = ''
  @Prop coverKey: string = ''
  @Prop bannerHeight: number = 200

  private icon(): AppIconName {
    return SymbolVisualUtil.resolve(this.category, this.coverKey).iconName
  }

  build() {
    Column() {
      AppIcon({ name: this.icon(), iconSize: Theme.icon.xl, color: '#FFFFFF' })
    }
    .width('100%')
    .height(this.bannerHeight)
    .justifyContent(FlexAlign.Center)
    .linearGradient({ angle: 160, colors: [['#3B2D8E', 0], ['#6C5CE7', 1]] })
  }
}
