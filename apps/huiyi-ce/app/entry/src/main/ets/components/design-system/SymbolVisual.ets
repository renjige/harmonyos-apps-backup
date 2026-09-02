import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

export class CategoryVisual {
  iconName: AppIconName = 'bookmark'
  gradStart: string = '#1A6DF5'
  gradEnd: string = '#0B2A5C'
  iconTint: string = '#FFFFFF'
}

export class SymbolVisualUtil {
  static resolve(category: string): CategoryVisual {
    const v = new CategoryVisual()
    if (category === '工作') {
      v.iconName = 'biz'
      v.gradStart = '#1A6DF5'
      v.gradEnd = '#0B2A5C'
    } else if (category === '生活') {
      v.iconName = 'home'
      v.gradStart = '#2F6F5E'
      v.gradEnd = '#1A3D32'
    } else if (category === '灵感') {
      v.iconName = 'sparkle'
      v.gradStart = '#C48A1A'
      v.gradEnd = '#7A4E08'
    } else if (category === '旅行') {
      v.iconName = 'clock'
      v.gradStart = '#3D6FA8'
      v.gradEnd = '#1A335C'
    } else if (category === '阅读') {
      v.iconName = 'book'
      v.gradStart = '#6B4E3A'
      v.gradEnd = '#3D2C22'
    } else if (category === '美食') {
      v.iconName = 'heart'
      v.gradStart = '#B45309'
      v.gradEnd = '#7C2D12'
    } else {
      v.iconName = 'bookmark'
      v.gradStart = '#1A6DF5'
      v.gradEnd = '#0B2A5C'
    }
    return v
  }
}

@Component
export struct SymbolCover {
  @Prop category: string = '未分类'
  @Prop tileSize: number = 72

  build() {
    Column() {
      AppIcon({
        name: SymbolVisualUtil.resolve(this.category).iconName,
        iconSize: 22,
        color: '#FFFFFF'
      })
    }
    .width(this.tileSize)
    .height(this.tileSize)
    .justifyContent(FlexAlign.Center)
    .borderRadius(Theme.radius.sm)
    .linearGradient({
      angle: 135,
      colors: [
        [SymbolVisualUtil.resolve(this.category).gradStart, 0],
        [SymbolVisualUtil.resolve(this.category).gradEnd, 1]
      ]
    })
  }
}

@Component
export struct SymbolHero {
  @Prop category: string = '未分类'
  @Prop bannerHeight: number = 180
  @Prop overline: string = ''
  @Prop title: string = ''

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column() {
        AppIcon({
          name: SymbolVisualUtil.resolve(this.category).iconName,
          iconSize: 40,
          color: '#FFFFFF'
        })
      }
      .width('100%')
      .height(this.bannerHeight)
      .justifyContent(FlexAlign.Center)
      .linearGradient({
        angle: 160,
        colors: [
          [SymbolVisualUtil.resolve(this.category).gradStart, 0],
          [SymbolVisualUtil.resolve(this.category).gradEnd, 1]
        ]
      })

      Column({ space: 4 }) {
        if (this.overline.length > 0) {
          Text(this.overline)
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
        }
        if (this.title.length > 0) {
          Text(this.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .width('100%')
      .padding(Theme.space.s4)
      .linearGradient({
        angle: 180,
        colors: [['rgba(0,0,0,0)', 0], ['rgba(11,42,92,0.72)', 1]]
      })
    }
    .width('100%')
    .height(this.bannerHeight)
    .borderRadius(Theme.radius.md)
    .clip(true)
  }
}
