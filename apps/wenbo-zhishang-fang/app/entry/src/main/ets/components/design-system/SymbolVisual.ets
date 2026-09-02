import { Theme } from './Theme'
import { AppIcon, AppIconName } from './AppIcon'

export class CategoryVisual {
  iconName: AppIconName = 'book'
  gradStart: string = '#2C3E6B'
  gradEnd: string = '#1A2744'
  iconTint: string = '#FFFFFF'
}

export class SymbolVisualUtil {
  static resolve(category: string): CategoryVisual {
    const v = new CategoryVisual()
    if (category === '文学') {
      v.iconName = 'book'
      v.gradStart = '#6B4E3A'
      v.gradEnd = '#3D2C22'
    } else if (category === '哲学') {
      v.iconName = 'sparkle'
      v.gradStart = '#2C3E6B'
      v.gradEnd = '#1A2744'
    } else if (category === '商业') {
      v.iconName = 'biz'
      v.gradStart = '#3D5A40'
      v.gradEnd = '#1F3324'
    } else if (category === '科技') {
      v.iconName = 'chart'
      v.gradStart = '#3A4A6B'
      v.gradEnd = '#1A2744'
    } else if (category === '历史') {
      v.iconName = 'clock'
      v.gradStart = '#8A6A3A'
      v.gradEnd = '#4A3820'
    } else if (category === '心理') {
      v.iconName = 'heart'
      v.gradStart = '#6B3A4A'
      v.gradEnd = '#3A1F28'
    } else {
      v.iconName = 'bookmark'
      v.gradStart = '#2C3E6B'
      v.gradEnd = '#1A2744'
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
      Column()
        .width('100%')
        .height(this.bannerHeight)
        .linearGradient({
          angle: 135,
          colors: [
            [SymbolVisualUtil.resolve(this.category).gradStart, 0],
            [SymbolVisualUtil.resolve(this.category).gradEnd, 1]
          ]
        })
      Column({ space: 8 }) {
        AppIcon({
          name: SymbolVisualUtil.resolve(this.category).iconName,
          iconSize: 28,
          color: '#FFFFFF'
        })
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
        }
      }
      .width('100%')
      .padding(Theme.space.s4)
      .linearGradient({
        angle: 180,
        colors: [['rgba(0,0,0,0)', 0], ['rgba(26,39,68,0.72)', 1]]
      })
    }
    .width('100%')
    .height(this.bannerHeight)
    .clip(true)
  }
}
