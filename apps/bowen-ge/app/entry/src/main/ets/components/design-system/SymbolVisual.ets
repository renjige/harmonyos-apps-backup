import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

export class CategoryVisual {
  iconName: AppIconName = 'book'
  gradStart: string = '#1E3A4C'
  gradEnd: string = '#3F6F72'
  iconTint: string = '#F6F1E8'
}

export class SymbolVisualUtil {
  static resolve(category: string, coverKey: string): CategoryVisual {
    const v = new CategoryVisual()
    if (category === 'reading' || coverKey === 'reading') {
      v.iconName = 'book'
      v.gradStart = '#1E3A4C'
      v.gradEnd = '#6F9B9E'
    } else if (category === 'spark' || coverKey === 'spark') {
      v.iconName = 'sparkle'
      v.gradStart = '#12262F'
      v.gradEnd = '#C4A574'
    } else if (category === 'theme' || coverKey === 'theme') {
      v.iconName = 'grid'
      v.gradStart = '#1E3A4C'
      v.gradEnd = '#5C6B76'
    } else {
      v.iconName = 'biz'
    }
    return v
  }
}

@Component
export struct SymbolCover {
  @Prop category: string = 'thought'
  @Prop coverKey: string = ''
  @Prop tileSize: number = 72

  private vis(): CategoryVisual {
    return SymbolVisualUtil.resolve(this.category, this.coverKey)
  }

  build() {
    Column() {
      AppIcon({ name: this.vis().iconName, iconSize: 28, color: this.vis().iconTint })
    }
    .width(this.tileSize)
    .height(this.tileSize)
    .justifyContent(FlexAlign.Center)
    .linearGradient({ angle: 135, colors: [[this.vis().gradStart, 0], [this.vis().gradEnd, 1]] })
    .borderRadius(16)
  }
}

@Component
export struct SymbolHero {
  @Prop category: string = 'thought'
  @Prop coverKey: string = ''
  @Prop bannerHeight: number = 200
  @Prop overline: string = ''

  private vis(): CategoryVisual {
    return SymbolVisualUtil.resolve(this.category, this.coverKey)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height(this.bannerHeight)
        .linearGradient({ angle: 160, colors: [[this.vis().gradStart, 0], [this.vis().gradEnd, 1]] })
      Column({ space: 8 }) {
        AppIcon({ name: this.vis().iconName, iconSize: 36, color: this.vis().iconTint })
        if (this.overline.length > 0) {
          Text(this.overline)
            .fontSize(12)
            .fontColor(this.vis().iconTint)
        }
      }
    }
    .width('100%')
    .height(this.bannerHeight)
    .clip(true)
    .borderRadius(16)
  }
}
